//
//  CategoriesService.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/20/26.
//

import Foundation

protocol CategoriesService {
    func fetch() async throws -> [String]
}

struct DefaultCategoriesService: CategoriesService {
    
    let client = NetworkClient()
    
    func fetch() async throws -> [String] {
        
        let categoriesEndpoint = CategoriesEndpoint()
                
        let categories: [String] = try await client.fetch(categoriesEndpoint)
        
        return categories
    }
}

struct MockCategoriesService: CategoriesService {
    
    let result: Result<[String], Error>
    
    func fetch() async throws -> [String] {
        
        switch result {
        case .success(let success):
            return success
        case .failure(let failure):
            throw failure
        }
    }
}
