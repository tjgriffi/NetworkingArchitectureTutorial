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
    private var skipOffset = 0
    private let limit = 10
    
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
            
            products = try await productService.fetch(skip: skipOffset, limit: limit)
            incrementSkipOffset()
            state = .loaded
        } catch let error as RepositoryError {
            state = .error(error.description)
        } catch {
            state = .error(error.localizedDescription)
            
        }
    }
    
    // Fetch more product when we reach the bottom of the list
    func fetchMore() async {
        
        guard state != .loading else {
            return
        }
        
        print("loadMore")
        
        state = .loading
        
        do {
            let nextProducts = try await productService.fetch(skip: skipOffset, limit: limit)
            products.append(contentsOf: nextProducts)
            incrementSkipOffset()
            state = .loaded
        } catch let error as RepositoryError {
            state = .error(error.description)
        } catch {
            state = .error(error.localizedDescription)
            
        }
    }
    
    private func incrementSkipOffset() {
        skipOffset += 10
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
