import Foundation
import OpenAI

/// OpenAIクライアントの実装
public struct OpenAIClient: OpenAIClientProtocol, Sendable {
    private let configurationService: ConfigurationServiceProtocol

    // MARK: - Static Properties

    /// sourceURLがnilの場合のフォールバックURL
    // swiftlint:disable:next force_unwrapping
    private static let fallbackSourceURL = URL(string: "about:blank")!

    /// 分量が指定されていない場合のプレースホルダー
    private static let amountNotSpecifiedPlaceholder = "(amount not specified)"

    /// JSON-LD抽出用の正規表現（関数呼び出しごとの再コンパイルを避けるためキャッシュ）
    ///
    /// パターン解説:
    /// - `<script[^>]*`: `<script`で始まり、`>`以外の任意の文字が続く（他の属性を許容）
    /// - `type\s*=\s*["\']application/ld\+json["\']`: type属性がapplication/ld+jsonであること
    /// - `[^>]*>`: `>`以外の任意の文字の後に`>`が来る
    /// - `([\s\S]*?)`: キャプチャグループ。`\s\S`は改行を含む任意の文字（`.`は改行にマッチしない）
    /// - `?`は非貪欲マッチ（最短一致）で、最初の`</script>`で停止
    /// - `</script>`: 終了タグ
    ///
    /// 対応例:
    /// - `<script type="application/ld+json">...</script>`
    /// - `<script id="schema" type="application/ld+json">...</script>`
    /// - `<script type='application/ld+json'>...</script>`（シングルクォート）
    private static let jsonLDRegex: NSRegularExpression? = {
        try? NSRegularExpression(
            pattern: #"<script[^>]*type\s*=\s*["\']application/ld\+json["\'][^>]*>([\s\S]*?)</script>"#,
            options: .caseInsensitive
        )
    }()

    public init(configurationService: ConfigurationServiceProtocol) {
        self.configurationService = configurationService
    }

    public func substituteRecipe(
        recipe: Recipe,
        target: SubstitutionTarget,
        prompt: String,
        targetLanguage: String
    ) async throws -> Recipe {
        // 1. API設定を取得
        let (openAI, model) = try await getOpenAIConfiguration()

        // 2. プロンプトを構築
        let systemPrompt = buildSubstitutionSystemPrompt(for: targetLanguage)
        let userContent = buildSubstitutionUserContent(recipe: recipe, target: target, prompt: prompt)

        // 3. デバッグログ出力
        #if DEBUG
        print("=== OpenAI Substitution Request ===")
        print("Model: \(model)")
        print("Target: \(target)")
        print("User prompt length: \(prompt.count) characters")
        print("===================================")
        #endif

        // 4. クエリを構築
        let query = ChatQuery(
            messages: [
                .system(.init(content: .textContent(systemPrompt))),
                .user(.init(content: .string(userContent)))
            ],
            model: model,
            responseFormat: .jsonSchema(
                .init(
                    name: "recipe-substitution",
                    schema: .derivedJsonSchema(RecipeResponse.self),
                    strict: true
                )
            )
        )

        // 5. API呼び出し
        let result = try await executeQuery(openAI: openAI, query: query)

        // 6. レスポンスをデコード（元のsourceURLを維持）
        return try decodeRecipe(from: result, sourceURL: recipe.sourceURL ?? Self.fallbackSourceURL)
    }

    // MARK: - Substitution Helpers

    /// 置き換え用のシステムプロンプトを構築
    private func buildSubstitutionSystemPrompt(for targetLanguage: String) -> String {
        let languageInstruction = buildLanguageInstruction(for: targetLanguage)

        return """
            You are a cooking expert. Modify the given recipe based on the user's request.

            IMPORTANT RULES:
            - Modify the specified ingredient or step according to the user's request
            - When an ingredient is changed, also adjust related cooking steps if necessary
            - Set isModified: true for any changed ingredients or steps
            - Keep isModified: false for unchanged items
            - Keep the recipe structure intact (all required fields)
            - Preserve ALL other ingredients and steps that are not affected by the change

            \(languageInstruction)
            """
    }

    /// 置き換え用のユーザーコンテンツを構築
    private func buildSubstitutionUserContent(recipe: Recipe, target: SubstitutionTarget, prompt: String) -> String {
        let recipeJson = serializeRecipeForPrompt(recipe)
        let targetDescription = describeSubstitutionTarget(target)

        return """
            ## Current Recipe
            \(recipeJson)

            ## Target to Modify
            \(targetDescription)

            ## User's Request
            \(prompt)

            Please modify the recipe according to the user's request. Remember to:
            1. Set isModified: true for changed items
            2. Adjust related cooking steps if the ingredient change affects them
            3. Keep all other items unchanged with isModified: false
            """
    }

    /// Recipeをテキスト形式にシリアライズ（プロンプト用）
    ///
    /// 配列に追加してjoinedで結合することで、ループ内での文字列連結によるO(n²)を回避
    private func serializeRecipeForPrompt(_ recipe: Recipe) -> String {
        var components: [String] = []
        components.append("Title: \(recipe.title)")

        if let description = recipe.description {
            components.append("Description: \(description)")
        }

        if let servings = recipe.ingredientsInfo.servings {
            components.append("Servings: \(servings)")
        }

        components.append("")
        components.append("Ingredients:")
        for ingredient in recipe.ingredientsInfo.items {
            let amount = ingredient.amount ?? Self.amountNotSpecifiedPlaceholder
            components.append("- \(ingredient.name): \(amount)")
        }

        components.append("")
        components.append("Steps:")
        for step in recipe.steps {
            components.append("\(step.stepNumber). \(step.instruction)")
        }

        return components.joined(separator: "\n")
    }

    /// 置き換え対象を説明する文字列を生成
    private func describeSubstitutionTarget(_ target: SubstitutionTarget) -> String {
        switch target {
        case .ingredient(let ingredient):
            let amount = ingredient.amount ?? Self.amountNotSpecifiedPlaceholder
            return "Type: Ingredient\nName: \(ingredient.name) (\(amount))"
        case .step(let step):
            return "Type: Cooking Step\nStep \(step.stepNumber): \(step.instruction)"
        }
    }

    public func extractRecipe(html: String, sourceURL: URL, targetLanguage: String) async throws -> Recipe {
        // 1. API設定を取得
        let (openAI, model) = try await getOpenAIConfiguration()

        // 2. コンテンツを準備（JSON-LD優先）
        let (content, contentType) = prepareContent(from: html)

        // 3. プロンプトを構築
        let systemPrompt = buildSystemPrompt(for: targetLanguage)

        // 4. デバッグログ出力
        logRequest(model: model, contentType: contentType, systemPrompt: systemPrompt, sourceURL: sourceURL)

        // 5. クエリを構築
        let query = buildChatQuery(
            systemPrompt: systemPrompt,
            content: content,
            model: model
        )

        // 6. API呼び出し
        let result = try await executeQuery(openAI: openAI, query: query)

        // 7. レスポンスをデコード
        return try decodeRecipe(from: result, sourceURL: sourceURL)
    }

    // MARK: - Extract Recipe Helpers

    /// OpenAI APIの設定を取得
    private func getOpenAIConfiguration() async throws -> (OpenAI, String) {
        guard let apiKey = await configurationService.getOpenAIAPIKey() else {
            throw OpenAIClientError.apiKeyNotConfigured
        }

        let model = await configurationService.getOpenAIModel()
        let configuration = OpenAI.Configuration(
            token: apiKey,
            timeoutInterval: 120.0
        )
        return (OpenAI(configuration: configuration), model)
    }

    /// HTMLからコンテンツを準備（JSON-LD優先）
    private func prepareContent(from html: String) -> (content: String, type: String) {
        if let jsonLD = Self.extractRecipeJsonLD(from: html) {
            return ("JSON-LD Recipe Data:\n\(jsonLD)", "JSON-LD")
        } else {
            return ("HTML:\n\(html)", "HTML")
        }
    }

    /// 言語に応じたシステムプロンプトを構築
    private func buildSystemPrompt(for targetLanguage: String) -> String {
        let languageInstruction = buildLanguageInstruction(for: targetLanguage)

        return """
            You are a recipe extraction assistant. Extract recipe information from HTML content.

            IMPORTANT RULES:
            - Extract ALL ingredients with their EXACT amounts (e.g., "2 cups flour", "1/2 teaspoon salt")
            - Extract ALL cooking steps - do not summarize or combine steps
            - Keep the original detail level of each step's instructions
            - If an ingredient has no amount specified, use the amount field as null

            \(languageInstruction)
            """
    }

    /// 言語に応じた指示文を生成
    private func buildLanguageInstruction(for targetLanguage: String) -> String {
        Self.testableBuildLanguageInstruction(for: targetLanguage)
    }

    /// デバッグ用のログ出力
    private func logRequest(model: String, contentType: String, systemPrompt: String, sourceURL: URL) {
        #if DEBUG
        print("=== OpenAI Request ===")
        print("Model: \(model)")
        print("Content type: \(contentType)")
        print("System prompt length: \(systemPrompt.count) characters")
        print("User prompt: Extract recipe from \(sourceURL.absoluteString)")
        print("======================")
        #endif
    }

    /// ChatQueryを構築
    private func buildChatQuery(
        systemPrompt: String,
        content: String,
        model: String
    ) -> ChatQuery {
        ChatQuery(
            messages: [
                .system(.init(content: .textContent(systemPrompt))),
                .user(.init(content: .string("""
                    Extract the complete recipe from the following content. Include every ingredient with its exact amount, and all cooking steps without summarizing.

                    \(content)
                    """
                )))
            ],
            model: model,
            responseFormat: .jsonSchema(
                .init(
                    name: "recipe-extraction",
                    schema: .derivedJsonSchema(RecipeResponse.self),
                    strict: true
                )
            )
        )
    }

    /// OpenAI APIを呼び出し
    private func executeQuery(openAI: OpenAI, query: ChatQuery) async throws -> ChatResult {
        do {
            return try await openAI.chats(query: query)
        } catch {
            #if DEBUG
            print("OpenAI API error: \(error)")
            print("OpenAI API error type: \(type(of: error))")
            #endif
            throw OpenAIClientError.networkError(error.localizedDescription)
        }
    }

    /// レスポンスをRecipeにデコード
    private func decodeRecipe(from result: ChatResult, sourceURL: URL) throws -> Recipe {
        guard let content = result.choices.first?.message.content else {
            throw OpenAIClientError.noResponseContent
        }

        let decoder = JSONDecoder()
        let response: RecipeResponse
        do {
            response = try decoder.decode(RecipeResponse.self, from: Data(content.utf8))
        } catch {
            throw OpenAIClientError.decodingError(error.localizedDescription)
        }

        return response.toRecipe(sourceURL: sourceURL)
    }

    // MARK: - JSON-LD Extraction Helpers

    /// HTMLからRecipe型のJSON-LDを抽出
    /// - Parameter html: HTMLコンテンツ
    /// - Returns: JSON-LD文字列（見つからない場合はnil）
    private static func extractRecipeJsonLD(from html: String) -> String? {
        let jsonStrings = extractJsonLDScripts(from: html)

        for jsonString in jsonStrings {
            if let recipeJson = findRecipeInJsonLD(jsonString) {
                return formatRecipeJson(recipeJson)
            }
        }

        return nil
    }

    /// HTMLからJSON-LDスクリプトの内容を抽出
    ///
    /// HTMLページ内のすべての`<script type="application/ld+json">`タグを検索し、
    /// その内容を文字列の配列として返す。
    ///
    /// 処理フロー:
    /// 1. 正規表現で`<script type="application/ld+json">...</script>`にマッチ
    /// 2. キャプチャグループ（スクリプトタグの内側）を抽出
    /// 3. 前後の空白をトリムして返す
    ///
    /// - Parameter html: HTMLコンテンツ
    /// - Returns: JSON-LD文字列の配列（見つからない場合は空配列）
    private static func extractJsonLDScripts(from html: String) -> [String] {
        guard let regex = jsonLDRegex else {
            return []
        }

        let range = NSRange(html.startIndex..., in: html)
        let matches = regex.matches(in: html, options: [], range: range)

        return matches.compactMap { match in
            guard let contentRange = Range(match.range(at: 1), in: html) else { return nil }
            return String(html[contentRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    /// JSON-LD文字列からRecipe型のオブジェクトを探す
    /// - Parameter jsonString: JSON-LD文字列
    /// - Returns: Recipe型のJSONオブジェクト（見つからない場合はnil）
    private static func findRecipeInJsonLD(_ jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }

        // 配列の場合
        if let array = json as? [[String: Any]] {
            return array.first { isRecipeType($0) }
        }

        // 単一オブジェクトの場合
        if let dict = json as? [String: Any] {
            if isRecipeType(dict) {
                return dict
            }
            // @graphの中にRecipeがある場合
            if let graph = dict["@graph"] as? [[String: Any]] {
                return graph.first { isRecipeType($0) }
            }
        }

        return nil
    }

    /// RecipeのJSONオブジェクトを整形して文字列に変換
    /// - Parameter recipeJson: Recipe型のJSONオブジェクト
    /// - Returns: 整形されたJSON文字列（変換失敗時はnil）
    private static func formatRecipeJson(_ recipeJson: [String: Any]) -> String? {
        guard let prettyData = try? JSONSerialization.data(withJSONObject: recipeJson, options: .prettyPrinted),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return nil
        }
        return prettyString
    }

    /// JSON-LDオブジェクトがRecipe型かどうか判定
    private static func isRecipeType(_ json: [String: Any]) -> Bool {
        if let type = json["@type"] as? String {
            return type == "Recipe"
        }
        if let types = json["@type"] as? [String] {
            return types.contains("Recipe")
        }
        return false
    }
}

// MARK: - Testing Support

extension OpenAIClient {
    /// テスト用: HTMLからRecipe型のJSON-LDを抽出（内部メソッドの公開）
    internal static func testableExtractRecipeJsonLD(from html: String) -> String? {
        extractRecipeJsonLD(from: html)
    }

    /// テスト用: HTMLからJSON-LDスクリプトの内容を抽出（内部メソッドの公開）
    internal static func testableExtractJsonLDScripts(from html: String) -> [String] {
        extractJsonLDScripts(from: html)
    }

    /// テスト用: JSON-LD文字列からRecipe型のオブジェクトを探す（内部メソッドの公開）
    internal static func testableFindRecipeInJsonLD(_ jsonString: String) -> [String: Any]? {
        findRecipeInJsonLD(jsonString)
    }

    /// テスト用: HTMLからコンテンツを準備（内部メソッドの公開）
    /// - Parameter html: HTMLコンテンツ
    /// - Returns: (content: 抽出されたコンテンツ, type: コンテンツタイプ "JSON-LD" または "HTML")
    internal static func testablePrepareContent(from html: String) -> (content: String, type: String) {
        if let jsonLD = extractRecipeJsonLD(from: html) {
            return ("JSON-LD Recipe Data:\n\(jsonLD)", "JSON-LD")
        } else {
            return ("HTML:\n\(html)", "HTML")
        }
    }

    /// テスト用: JSONコンテンツをRecipeにデコード（内部メソッドの公開）
    /// - Parameters:
    ///   - content: OpenAI APIからのJSONレスポンス（文字列）
    ///   - sourceURL: レシピのソースURL
    /// - Returns: デコードされたRecipe
    /// - Throws: noResponseContent（contentがnilの場合）、decodingError（JSONパースに失敗した場合）
    internal static func testableDecodeRecipe(content: String?, sourceURL: URL) throws -> Recipe {
        guard let content = content else {
            throw OpenAIClientError.noResponseContent
        }

        let decoder = JSONDecoder()
        let response: RecipeResponse
        do {
            response = try decoder.decode(RecipeResponse.self, from: Data(content.utf8))
        } catch {
            throw OpenAIClientError.decodingError(error.localizedDescription)
        }

        return response.toRecipe(sourceURL: sourceURL)
    }

    /// テスト用: 言語コードに応じた指示文を生成（内部メソッドの公開）
    /// - Parameter targetLanguage: ターゲット言語コード（例: "ja", "en"）
    /// - Returns: 言語に応じた指示文
    internal static func testableBuildLanguageInstruction(for targetLanguage: String) -> String {
        switch targetLanguage {
        case "ja":
            return """
                IMPORTANT: You MUST respond with ALL text fields (title, description, ingredient names, step instructions) translated into Japanese. Do not leave any text in English.
                Also, convert all measurements to metric units (grams, milliliters, etc.). For example: "2 oz" → "60g", "1 cup" → "240ml", "1 Tbsp" → "大さじ1", "1 tsp" → "小さじ1".
                """
        case "en":
            return "Respond in English. Keep the original measurement units."
        default:
            return "IMPORTANT: You MUST respond with ALL text fields translated into \(targetLanguage)."
        }
    }
}
