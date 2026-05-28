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
    
    var canLoad: Bool {
        switch self {
        case .initial:
            true
        case .loading:
            false
        case .loaded:
            true
        case .error(let string):
            true
        }
    }
}

enum ProductStoreError: LocalizedError {
    case currentlyLoading
    case networkError
}

@Observable class ProductStore {
    
    private(set) var products: [Product] = []
    // MARK: Filtering products addon
//    private var totalProducts: [Product] = []
//    private var filteredProducts: [Product] = []
    
    private(set) var state: NetworkCallState = .initial
    
    private let productService: ProductService
    private var skipOffset = 0
    private let limit = 10
    private var total: Int = 0
    
    private var lastSearchedQuery: String?
    
    init(productService: ProductService = DefaultProductService()) {
        
        self.productService = productService
    }
    
    func initialFetchProducts() async {
        
        guard state.canLoad && products.isEmpty else {
            // Too early to make a fetch
            return
        }

        state = .loading
        
        do {
            
            let productResponse = try await productService.fetch(skip: skipOffset,
                                                                 limit: limit,
                                                                 query: nil)
            
            products = productResponse.products
            total = productResponse.total
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
        
        guard state.canLoad && products.count < total else {
            return
        }
        
        state = .loading
        
        do {
            
            let productResponse = try await productService.fetch(skip: skipOffset, limit: limit, query: lastSearchedQuery)
            let nextProducts = productResponse.products
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
    
//    func filter(by searchText: String) {
//        
//        guard !searchText.isEmpty else {
//            products = totalProducts
//            return
//        }
//        
//        filteredProducts = products.filter({ product in
//            product.title.contains(searchText)
//        })
//        
//        products = filteredProducts
//    }
    
    func fetch(for query: String) async {
        
        // TODO: Exception: load more during paging
//        guard !query.isEmpty else {
//            // Too early to make a fetch
//            return
//        }
        guard state.canLoad else { return }
        print("Fetch for search")
        state = .loading
        products = []
        skipOffset = 0
        
        do {
            
            let productResponse = try await productService.fetch(skip: skipOffset,
                                                                 limit: limit,
                                                                 query: query)
            
            products = productResponse.products
            total = productResponse.total
            lastSearchedQuery = query
            incrementSkipOffset()
            state = .loaded
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
