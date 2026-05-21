//
//  ProductStore.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/12/26.
//

import Foundation

enum NetworkCallState: Equatable {
    case initial
    case loading
    case loaded
    case error(String)
}

enum ProductStoreError: LocalizedError {
    case currentlyLoading
    case networkError
}

@Observable class ProductStore {
    
    var products: [Product] = []
    private let productService: ProductService
    var state: NetworkCallState = .initial
    var errorMessage: String = ""
    
    init(productService: ProductService = DefaultProductService()) {
        
        self.productService = productService
    }
    
    func fetchProducts() async {
        
        guard state != .loading else {
            // Too early to make a fetch
            return
        }

        state = .loading
        
        do {
            
            products = try await productService.fetch(skip: 0, limit: 0)
            state = .loaded
        } catch let error as RepositoryError {
            errorMessage = error.description
            state = .error(error.description)
        } catch {
            errorMessage = error.localizedDescription
            state = .error(error.localizedDescription)
            
        }
    }
}



//import Playgrounds
//
//#Playground {
//    let repository = Repository()
//    let productStore = ProductStore(repository: repository)
//    
//    await productStore.fetchProducts()
//    await productStore.fetchProductCategories()
//}
