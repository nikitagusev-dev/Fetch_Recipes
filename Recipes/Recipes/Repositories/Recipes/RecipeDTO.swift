//
//  RecipeDTO.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/24/24.
//

struct RecipeDTO {
    let id: String
    let cuisine: String
    let name: String
    let largePhotoURL: String?
    let smallPhotoURL: String?
    let sourceURL: String?
    let youtubeURL: String?
}

extension RecipeDTO {
    init(recipe: Recipe) {
        id = recipe.id
        cuisine = recipe.cuisine
        name = recipe.name
        largePhotoURL = recipe.largePhotoURL
        smallPhotoURL = recipe.smallPhotoURL
        sourceURL = recipe.sourceURL
        youtubeURL = recipe.youtubeURL
    }
}
