//
//  RecipesListErrorInfoViewModel.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/26/24.
//

import UIKit

struct RecipesListErrorInfoViewModel: RecipesListInfoViewModelType {
    let image = UIImage.error
    let description = NSLocalizedString("RecipesList.Error.Description", comment: "")
    let buttonTitle = NSLocalizedString("RecipesList.Error.ButtonTitle", comment: "")
    
    private let onButtonTapHandler: () -> Void
    
    init(onButtonTap: @escaping () -> Void) {
        onButtonTapHandler = onButtonTap
    }
    
    func onButtonTap() {
        onButtonTapHandler()
    }
}
