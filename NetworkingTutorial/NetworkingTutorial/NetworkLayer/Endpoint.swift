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
    
    
    var path: String {
        if searchQuery != nil {
            "/products/search"
        } else {
            "/products"
        }
    }
    let method: HTTPMethod = .get
    
    var limit: Int
    var skip: Int
    var searchQuery: String?
    
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "skip", value: "\(skip)")
        ]
        
        if let searchQuery {
            items.append(.init(name: "q", value: searchQuery))
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
