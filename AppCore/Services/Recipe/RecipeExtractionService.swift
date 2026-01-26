import Foundation

/// レシピ抽出サービスの実装
public struct RecipeExtractionService: RecipeExtractionServiceProtocol, Sendable {
    private let htmlFetcher: HTMLFetcherProtocol
    private let openAIClient: OpenAIClientProtocol
    private let configurationService: ConfigurationServiceProtocol

    public init(
        htmlFetcher: HTMLFetcherProtocol,
        openAIClient: OpenAIClientProtocol,
        configurationService: ConfigurationServiceProtocol
    ) {
        self.htmlFetcher = htmlFetcher
        self.openAIClient = openAIClient
        self.configurationService = configurationService
    }

    public func extractRecipe(from url: URL) async throws -> Recipe {
        // 1. HTMLを取得
        let html: String
        do {
            html = try await htmlFetcher.fetchHTML(from: url)
        } catch {
            throw RecipeExtractionError.htmlFetchFailed(error.localizedDescription)
        }

        // 2. 端末の言語設定を取得
        let targetLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        print("Target language: \(targetLanguage)")

        // 3. OpenAI APIでレシピを抽出
        do {
            return try await openAIClient.extractRecipe(
                html: html,
                sourceURL: url,
                targetLanguage: targetLanguage
            )
        } catch let error as OpenAIClientError where error == .apiKeyNotConfigured {
            throw RecipeExtractionError.apiKeyNotConfigured
        } catch {
            throw RecipeExtractionError.extractionFailed(error.localizedDescription)
        }
    }

    public func substituteRecipe(
        recipe: Recipe,
        target: SubstitutionTarget,
        prompt: String
    ) async throws -> Recipe {
        // 端末の言語設定を取得
        let targetLanguage = Locale.current.language.languageCode?.identifier ?? "en"

        do {
            return try await openAIClient.substituteRecipe(
                recipe: recipe,
                target: target,
                prompt: prompt,
                targetLanguage: targetLanguage
            )
        } catch let error as OpenAIClientError where error == .apiKeyNotConfigured {
            throw RecipeExtractionError.apiKeyNotConfigured
        } catch {
            throw RecipeExtractionError.extractionFailed(error.localizedDescription)
        }
    }
}
