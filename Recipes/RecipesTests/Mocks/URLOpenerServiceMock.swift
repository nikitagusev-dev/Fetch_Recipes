//
//  URLOpenerServiceMock.swift
//  RecipesTests
//
//  Created by Personal on 10/27/24.
//

@testable import Recipes
import Foundation

final class URLOpenerServiceMock: URLOpenerServiceType {
    var openedURL: URL?
    
    func open(url: URL) {
        openedURL = url
    }
}
