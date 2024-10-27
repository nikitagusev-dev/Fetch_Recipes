//
//  URLOpenerServiceMock.swift
//  RecipesTests
//
//  Created by Nikita Gusev on 10/27/24.
//

@testable import Recipes
import Foundation

final class URLOpenerServiceMock: URLOpenerServiceType {
    var openedURL: URL?
    
    func open(url: URL) {
        openedURL = url
    }
}
