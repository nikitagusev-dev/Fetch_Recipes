//
//  Recipe.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/24/24.
//

struct RecipesList: Decodable {
    let recipes: [Recipe]
}

struct Recipe {
    let id: String
    let cuisine: String
    let name: String
    let largePhotoURL: String?
    let smallPhotoURL: String?
    let sourceURL: String?
    let youtubeURL: String?
}

extension Recipe: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case cuisine
        case name
        case largePhotoURL = "photo_url_large"
        case smallPhotoURL = "photo_url_small"
        case sourceURL = "source_url"
        case youtubeURL = "youtube_url"
    }
}
