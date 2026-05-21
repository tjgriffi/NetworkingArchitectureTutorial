//
//  ProductService.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/18/26.
//

import Foundation


protocol ProductService {
    func fetch(skip: Int, limit: Int) async throws -> [Product]
}

struct DefaultProductService: ProductService {
    
    let client = NetworkClient()
    
    func fetch(skip: Int, limit: Int) async throws -> [Product] {
        
        let productEndpoint = ProductEndpoint(limit: limit, skip: skip)
        
        let productResponse = try await client.fetch(productEndpoint)
        return productResponse.products
    }
}

struct MockProductService: ProductService {
    
    let error: RepositoryError?
    let result: [Product]
    
    init(error: RepositoryError? = nil, result: [Product] = [Product.example]) {
        self.error = error
        self.result = result
    }
    
    func fetch(skip: Int, limit: Int) async throws -> [Product] {
        
        if let _ = error {
            throw error!
        }
        
        return [Product.example]
    }
}
