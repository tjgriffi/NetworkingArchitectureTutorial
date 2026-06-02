//
//  Endpoint.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/19/26.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

protocol Endpoint {
    associatedtype Response: Decodable
    
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    func makeRequest(baseURL: URL) throws -> URLRequest
    func map(data: Data) throws -> Response
}

extension Endpoint {
    
    func makeRequest(baseURL: URL) throws -> URLRequest {
        
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path),
                                          resolvingAgainstBaseURL: true)
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw RepositoryError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        return request
    }
    
    func map(data: Data) throws -> Response {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(Response.self, from: data)
    }
}

struct ProductEndpoint: Endpoint {
    typealias Response = ProductResponse
    
    struct Configuration: Equatable {
        var searchText: String?
        var category: String?
        var sortField: SortField?
        var sortOrder: SortOrder?
    }
    
    var path: String {
        
        if configuration.searchText != nil {
            "/products/search"
        } else if let category = configuration.category {
            "/products/category/\(category)"
        } else {
            "/products"
        }
        
    }
    let method: HTTPMethod = .get
    
    var limit: Int
    var skip: Int
    var configuration: Configuration
    
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "skip", value: "\(skip)")
        ]
        
        if let searchQuery = configuration.searchText, configuration.category == nil {
            // If it has a search value it cant have a category
            items.append(.init(name: "q", value: searchQuery))
        }
        
        switch configuration.sortField {
        case .priceAsc, .priceDesc:
            items.append(URLQueryItem(name: "sortBy", value: configuration.sortField?.queryValue))
            items.append(URLQueryItem(name: "order", value: configuration.sortOrder?.rawValue))
        default:
            items.append(URLQueryItem(name: "sortBy", value: configuration.sortField?.queryValue))
        }
        
        return items
    }
}

struct CategoriesEndpoint: Endpoint {
    typealias Response = [String]
    
    
    var path: String = "/products/category-list"
    let method: HTTPMethod = .get
    
    var queryItems: [URLQueryItem] { [] }
}
