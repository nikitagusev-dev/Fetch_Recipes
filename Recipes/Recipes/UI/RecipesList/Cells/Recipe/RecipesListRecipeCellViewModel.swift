//
//  RecipesListRecipeCellViewModel.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/25/24.
//

import Foundation

struct RecipesListRecipeCellViewModel {
    let imageURL: URL?
    let name: String
    let cuisine: String
    let externalResourceButtonIsVisible: Bool
    
    private let sourceURL: URL?
    private let youtubeURL: URL?
    
    private let urlOpenerService: URLOpenerServiceType
    
    init(
        imageURL: URL?,
        name: String,
        cuisine: String,
        sourceURL: URL? = nil,
        youtubeURL: URL? = nil,
        urlOpenerService: URLOpenerServiceType
    ) {
        self.imageURL = imageURL
        self.name = name
        self.cuisine = cuisine
        self.sourceURL = sourceURL
        self.youtubeURL = youtubeURL
        self.urlOpenerService = urlOpenerService
        
        externalResourceButtonIsVisible = sourceURL != nil || youtubeURL != nil
    }
    
    func onExternalResourceButtonTap() {
        if let sourceURL {
            urlOpenerService.open(url: sourceURL)
        } else if let youtubeURL {
            urlOpenerService.open(url: youtubeURL)
        }
    }
}

extension RecipesListRecipeCellViewModel: Hashable {
    static func == (lhs: RecipesListRecipeCellViewModel, rhs: RecipesListRecipeCellViewModel) -> Bool {
        lhs.imageURL == rhs.imageURL
            && lhs.name == rhs.name
            && lhs.cuisine == rhs.cuisine
            && lhs.externalResourceButtonIsVisible == rhs.externalResourceButtonIsVisible
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(imageURL)
        hasher.combine(name)
        hasher.combine(cuisine)
        hasher.combine(externalResourceButtonIsVisible)
    }
}
