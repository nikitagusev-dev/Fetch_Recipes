//
//  RecipesListEmptyInfoViewModel.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/26/24.
//

import UIKit

struct RecipesListEmptyInfoViewModel: RecipesListInfoViewModelType {
    let image = UIImage.empty
    let description = NSLocalizedString("RecipesList.Empty.Description", comment: "")
    let buttonTitle = NSLocalizedString("RecipesList.Empty.ButtonTitle", comment: "")
    
    private let onButtonTapHandler: () -> Void
    
    init(onButtonTap: @escaping () -> Void) {
        onButtonTapHandler = onButtonTap
    }
    
    func onButtonTap() {
        onButtonTapHandler()
    }
}
