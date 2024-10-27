//
//  Launcher.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/24/24.
//

import UIKit

final class Launcher {
    private let diContainer = DIContainer()
    private let coordinator: CoordinatorType
    
    init(window: UIWindow) {
        coordinator = Coordinator(window: window, diContainer: diContainer)
    }
    
    func launch() {
        coordinator.launch()
    }
}
