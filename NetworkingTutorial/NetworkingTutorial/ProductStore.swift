//
//  ProductStore.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/12/26.
//

import Foundation

enum ProductStoreState: Equatable {
    case initial
    case loading
    case loaded
    case error(String)
}

@Observable class ProductStore {
    
    var products: [Product]
    private let repository: NetworkClientProtocol
    var state: ProductStoreState = .initial
    
    init(products: [Product] = [], repository: NetworkClientProtocol = Repository()) {
        self.products = products
        self.repository = repository
    }
    
    func fetchProducts() async {
        
        guard state != .loading else {
            // Too early to make a fetch
            return
        }
        
        state = .loading
        
        do {
            let productResponse: ProductResponse = try await repository.fetch("https://dummyjson.com/products/1")
            
            products = productResponse.products
            state = .loaded
        } catch let error as RepositoryError {
            state = .error(error.rawValue)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func fetchProductCategories() async {
        
    }
}
