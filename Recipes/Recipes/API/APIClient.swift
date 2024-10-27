//
//  APIClient.swift
//  Recipes
//
//  Created by Nikita Gusev on 10/24/24.
//

import Foundation

final class APIClient {
    // Can be extended on demand
    enum Method: String {
        case get = "GET"
    }
    
    enum Error: Swift.Error {
        case decodingFailure
        case invalidURL
    }
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func request<T: Decodable>(url: URL, method: Method) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Data handling for different methods can be added on demand
        let (data, _) = try await urlSession.data(for: request)
        
        do {
            // JSONDecoder configuration can be added on demand
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw Error.decodingFailure
        }
    }
}
