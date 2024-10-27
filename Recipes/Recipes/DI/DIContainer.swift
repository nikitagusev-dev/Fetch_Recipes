//
//  DIContainer.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/25/24.
//

final class DIContainer {
    let recipesRepository: RecipesRepositoryType
    let urlOpenerService: URLOpenerServiceType
    
    init() {
        let apiClient = APIClient()
        
        recipesRepository = RecipesRepository(recipesAPI: apiClient)
        urlOpenerService = URLOpenerService()
    }
}
