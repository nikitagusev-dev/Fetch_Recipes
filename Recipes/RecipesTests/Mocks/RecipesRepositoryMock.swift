//
//  RecipesRepositoryMock.swift
//  RecipesTests
//
//  Created by Nikita Gusev on 10/27/24.
//

@testable import Recipes

final class RecipesRepositoryMock: RecipesRepositoryType {
    var recipesResult: Result<[RecipeDTO], Error>?
    var delay: UInt64?
    var onGetRecipesRequest: (() -> Void)?
    
    func getRecipes() async throws -> [RecipeDTO] {
        onGetRecipesRequest?()
        
        guard let recipesResult else {
            fatalError()
        }
        
        if let delay {
            try await Task.sleep(nanoseconds: delay)
        }
        
        switch recipesResult {
            case let .success(recipes):
                return recipes
            case let .failure(error):
                throw error
        }
    }
}
