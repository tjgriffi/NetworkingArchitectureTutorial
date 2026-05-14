//
//  ProductStoreTests.swift
//  NetworkingTutorialTests
//
//  Created by Terrance Griffith on 5/12/26.
//

import Testing
@testable import NetworkingTutorial

struct ProductStoreTests {
    
    class MockNetworkClient: NetworkClientProtocol {
        
        var result: Result<Any, Error>
        
        var lastURL: String?
        
        init(result: Result<Any, Error> = .success([])) {
            self.result = result
        }
        
        func fetch<T>(_ urlString: String) async throws -> T where T : Decodable {
            
            lastURL = urlString
            
            switch result {
            case .success(let success):
                guard let typedValue = success as? T else {
                    throw RepositoryError.decodingFailed
                }
                
                return typedValue
            case .failure(let failure):
                throw failure
            }
        }
    }

    @Test func fetch_product_from_backend_success() async throws {
        
        // Given
        let mockResults = ProductResponse(
            products: [
                Product.example
            ],
            total: 1,
            skip: 11,
            limit: 10
        )
        
        let mockRepo = MockNetworkClient(result: .success(mockResults))
        let productStore = ProductStore(repository: mockRepo)
        
        #expect(productStore.products.count == 0, "There should not be any products initially") 
        
        // When
        await productStore.fetchProducts()
        
        // Then
        #expect(productStore.products.count == 1, "There is an incorrect number of products that was added")
        #expect(productStore.products[0] == Product.example)
    }
    
    @Test func fetch_product_from_backend_badStatusCode_failure() async {
        
        // Given
        let mockResults = RepositoryError.badStatusCode
        
        let mockRepo = MockNetworkClient(result: .failure(mockResults))
        let productStore = ProductStore(repository: mockRepo)
        
        // When
        await productStore.fetchProducts()
        
        // Then
        #expect(productStore.state == .error(mockResults.rawValue))
        #expect(productStore.products.isEmpty)
    }
    
    @Test func fetch_product_from_backend_decodingFailed_failure() async {
        
        // Given
        let mockResults = RepositoryError.decodingFailed
        
        let mockRepo = MockNetworkClient(result: .failure(mockResults))
        let productStore = ProductStore(repository: mockRepo)
        
        // When
        await productStore.fetchProducts()
        
        // Then
        #expect(productStore.state == .error(mockResults.rawValue))
        #expect(productStore.products.isEmpty)
    }
    
    @Test func fetch_product_from_backend_invalidHttpResponse_failure() async {
        
        // Given
        let mockResults = RepositoryError.invalidHttpResponse
        
        let mockRepo = MockNetworkClient(result: .failure(mockResults))
        let productStore = ProductStore(repository: mockRepo)
        
        // When
        await productStore.fetchProducts()
        
        // Then
        #expect(productStore.state == .error(mockResults.rawValue))
        #expect(productStore.products.isEmpty)
    }
    
    @Test func fetch_product_from_backend_invalidURL_failure() async {
        
        // Given
        let mockResults = RepositoryError.invalidURL
        
        let mockRepo = MockNetworkClient(result: .failure(mockResults))
        let productStore = ProductStore(repository: mockRepo)
        
        // When
        await productStore.fetchProducts()
        
        // Then
        #expect(productStore.state == .error(mockResults.rawValue))
        #expect(productStore.products.isEmpty)
    }

}
