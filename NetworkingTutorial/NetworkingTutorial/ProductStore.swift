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
    
    var products: [Product]
    private let repository: NetworkClientProtocol
    var state: NetworkCallState = .initial
    
    init(products: [Product] = [],
         repository: NetworkClientProtocol = Repository()) {
        
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
            let productResponse: ProductResponse = try await repository.fetch(NTConstants.productURLString)
            
            state = .loaded
            products = productResponse.products
        } catch let error as RepositoryError {
            state = .error(error.description)
        } catch {
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
