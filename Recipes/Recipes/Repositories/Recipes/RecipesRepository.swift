//
//  RecipesRepository.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/24/24.
//

import Foundation

protocol RecipesRepositoryType {
    func getRecipes() async throws -> [RecipeDTO]
}

final class RecipesRepository: RecipesRepositoryType {
    private let recipesAPI: RecipesAPIType
    
    init(recipesAPI: RecipesAPIType) {
        self.recipesAPI = recipesAPI
    }
    
    func getRecipes() async throws -> [RecipeDTO] {
        let recipesList = try await recipesAPI.fetchRecipesList()
        return recipesList.recipes.map(RecipeDTO.init)
    }
}
