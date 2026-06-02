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
    
    var lastConfiguration: ProductEndpoint.Configuration
    
    init(productService: ProductService = DefaultProductService(),
         lastConfiguration: ProductEndpoint.Configuration = ProductEndpoint.Configuration()) {
        
        self.productService = productService
        self.lastConfiguration = lastConfiguration
    }
    
    // Fetch more product when we reach the bottom of the list
    func fetchMore() async {
        
        guard state.canLoad && products.count < total else {
            return
        }
        
        state = .loading
        
        do {
            
            let productResponse = try await productService.fetch(skip: skipOffset, limit: limit, configuration: lastConfiguration)
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
            
    func fetch(searchText: String?, sortField: SortField?, sortOrder: SortOrder?, category: String?) async {
        
        guard state.canLoad else { return }
        
        state = .loading
        products = []
        skipOffset = 0
        
        let configuration = ProductEndpoint.Configuration(searchText: searchText, category: category, sortField: sortField, sortOrder: sortOrder)
        
        
        do {
            let productResponse = try await productService.fetch(skip: skipOffset, limit: limit, configuration: configuration)
            
            products = productResponse.products
            total = productResponse.total
            lastConfiguration = configuration
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
