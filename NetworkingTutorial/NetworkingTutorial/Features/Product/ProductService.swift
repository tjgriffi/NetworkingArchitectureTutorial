//
//  ProductService.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/18/26.
//

import Foundation


protocol ProductService {
    func fetch(skip: Int, limit: Int, query: String?) async throws -> ProductResponse
}

struct DefaultProductService: ProductService {
    
    let client = NetworkClient()
    
    func fetch(skip: Int, limit: Int, query: String? = nil) async throws -> ProductResponse {
        
        let productEndpoint = ProductEndpoint(limit: limit, skip: skip, searchQuery: query)
        
        let productResponse = try await client.fetch(productEndpoint)
        return productResponse
    }
}

struct MockProductService: ProductService {
    
    let error: RepositoryError?
    let result: ProductResponse
    
    init(error: RepositoryError? = nil, result: ProductResponse = .example) {
        self.error = error
        self.result = result
    }
    
    func fetch(skip: Int, limit: Int, query: String? = nil) async throws -> ProductResponse {
        
        if let _ = error {
            throw error!
        }
        
        return result
    }
}
