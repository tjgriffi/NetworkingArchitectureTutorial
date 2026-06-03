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
        case .error(let _):
            true
        }
    }
}

enum FetchIntent: Equatable {
    case initial
    case searching
    case more
    case filter
    case retry
    
    var resetProducts: Bool {
        switch self {
        case .more:
            false
        default:
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
    
    private(set) var state: NetworkCallState = .initial
    
    private let productService: ProductService
    private var skipOffset = 0
    private let limit = 10
    private var total: Int = 0
    
    var configuration: ProductEndpoint.Configuration
    private var lastConfiguration: ProductEndpoint.Configuration?
    
    init(productService: ProductService = DefaultProductService(),
         configuration: ProductEndpoint.Configuration = ProductEndpoint.Configuration()) {
        
        self.productService = productService
        self.configuration = configuration
    }
    
    /// Queries the productService to grab products given an intent value
    /// - Parameter intent: A FetchIntent that determines which products should be returned from the backend
    func fetch(for intent: FetchIntent) async {
        guard state.canLoad, canLoad(for: intent) else { return }
        
        if intent == .searching {
            // Manual debounce
            try? await Task.sleep(for: .seconds(1))
            
            // Check if the task has been cancelled
            guard !Task.isCancelled else {
                return
            }
        }
        
        state = .loading
        
        // Check if we need to reset products for the intent
        products = intent.resetProducts ? [] : products
        skipOffset = products.count
        
        do {
            
            let productResponse = try await productService.fetch(skip: skipOffset, limit: limit, configuration: configuration)
            
            products.append(contentsOf: productResponse.products)
            total = productResponse.total
            lastConfiguration = configuration
            state = .loaded
        } catch let error as RepositoryError {
            state = .error(error.description)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    /// Determines if the FetchIntent can load more products at this time
    /// - Parameter intent: The FetchIntent used to determine which products are being fetched from the backend
    /// - Returns: A boolean of whether or not the products can be grabbed at this moment
    private func canLoad(for intent: FetchIntent) -> Bool {
        
        switch intent {
        case .initial:
            products.isEmpty
        case .searching:
            state != .initial
        case .more:
            state != .loading && products.count < total && lastConfiguration == configuration
        case .filter:
            true
        case .retry:
            true
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
