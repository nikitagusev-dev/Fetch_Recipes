//
//  URLOpenerService.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/26/24.
//

import Foundation
import UIKit

protocol URLOpenerServiceType {
    func open(url: URL)
}

final class URLOpenerService: URLOpenerServiceType {
    func open(url: URL) {
        guard UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url)
    }
}
