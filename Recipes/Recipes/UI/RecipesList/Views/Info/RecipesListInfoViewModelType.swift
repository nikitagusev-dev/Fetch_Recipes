//
//  RecipesListInfoViewModelType.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/26/24.
//

import UIKit

protocol RecipesListInfoViewModelType {
    var image: UIImage { get }
    var description: String { get }
    var buttonTitle: String { get }
    
    func onButtonTap()
}
