//
//  RecipesAPI.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/24/24.
//

import Foundation

protocol RecipesAPIType {
    func fetchRecipesList() async throws -> RecipesList
}

extension APIClient: RecipesAPIType {
    func fetchRecipesList() async throws -> RecipesList {
        guard let url = RecipesURLProvider.provideURL() else {
            throw Error.invalidURL
        }
        
        return try await request(url: url, method: .get)
    }
}

// MARK: - Recipes helpers
private enum RecipesURLProvider {
    /// In debug configuration, provides a correct URL with 80% probability, a URL with empty array with 10% probability,
    /// and URL with invalid data with 10% probability.
    /// In other configurations, always provides a correct URL.
    static func provideURL() -> URL? {
        #if DEBUG
        switch Int.random(in: 0...9) {
            case (0...7):
                URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")
            case 8:
                URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")
            default:
                URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")
        }
        #else
        URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")
        #endif
    }
}
