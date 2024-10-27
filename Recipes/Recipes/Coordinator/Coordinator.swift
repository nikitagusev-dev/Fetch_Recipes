//
//  Coordinator.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/24/24.
//

import UIKit

protocol CoordinatorType {
    func launch()
}

final class Coordinator: CoordinatorType {
    private weak var window: UIWindow?
    private weak var navigationController: UINavigationController?
    
    private let diContainer: DIContainer
    
    init(window: UIWindow, diContainer: DIContainer) {
        self.window = window
        self.diContainer = diContainer
        
        let navigationController = UINavigationController()
        
        self.navigationController = navigationController
        window.rootViewController = navigationController
    }
    
    func launch() {
        let recipesListViewModel = RecipesListViewModel(
            recipesRepository: diContainer.recipesRepository,
            urlOpenerService: diContainer.urlOpenerService
        )
        let recipesListViewController = RecipesListViewController(viewModel: recipesListViewModel)
        
        navigationController?.pushViewController(recipesListViewController, animated: false)
    }
}
