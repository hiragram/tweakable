import Foundation
import OpenAI

/// OpenAIクライアントの実装
public struct OpenAIClient: OpenAIClientProtocol, Sendable {
    private let configurationService: ConfigurationServiceProtocol

    public init(configurationService: ConfigurationServiceProtocol) {
        self.configurationService = configurationService
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
            sourceURL: sourceURL,
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
        sourceURL: URL,
        model: String
    ) -> ChatQuery {
        ChatQuery(
            messages: [
                .system(.init(content: .textContent(systemPrompt))),
                .user(.init(content: .string("""
                    Extract the complete recipe from the following content. Include every ingredient with its exact amount, and all cooking steps without summarizing.

                    Source URL: \(sourceURL.absoluteString)

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
    /// - Parameter html: HTMLコンテンツ
    /// - Returns: JSON-LD文字列の配列
    private static func extractJsonLDScripts(from html: String) -> [String] {
        let pattern = #"<script[^>]*type\s*=\s*["\']application/ld\+json["\'][^>]*>([\s\S]*?)</script>"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
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
