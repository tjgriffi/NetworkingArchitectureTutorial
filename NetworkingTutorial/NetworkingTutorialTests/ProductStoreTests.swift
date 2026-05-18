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
        private var continuation: CheckedContinuation<Void, Never>?
        private var isSuspensionNeeded: Bool
                
        init(result: Result<Any, Error> = .success([]),
            isSuspensionNeeded: Bool = false) {
                self.result = result
                self.isSuspensionNeeded = isSuspensionNeeded
        }
        
        func fetch<T>(_ urlString: String) async throws -> T where T : Decodable {
            print("loading_state: inside of fetch for mock repo")
            if isSuspensionNeeded {
                print("loading_state: isSuspensionNeeded")
                await withCheckedContinuation {[weak self] continuation in
                    self?.continuation = continuation
                }
            }
            
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
        
        func complete() {
            print("loading_state: resumed completion")
            continuation?.resume()
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
        let mockResults = RepositoryError.badStatusCode(statusCode: 401, message: "does not exist")
        
        let mockRepo = MockNetworkClient(result: .failure(mockResults))
        let productStore = ProductStore(repository: mockRepo)
        
        // When
        await productStore.fetchProducts()
        
        // Then
        #expect(productStore.state == .error(mockResults.description))
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
        #expect(productStore.state == .error(mockResults.description))
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
        #expect(productStore.state == .error(mockResults.description))
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
        #expect(productStore.state == .error(mockResults.description))
        #expect(productStore.products.isEmpty)
    }
    
//    @Test func fetch_product_from_backend_loading_state() async throws {
//        
//        // Given
//        let mockResult = RepositoryError.badStatusCode(statusCode: 401, message: "does not exist")
//        let mockRepo = MockNetworkClient(result: .failure(mockResult), isSuspensionNeeded: true)
//        let productStore = ProductStore(repository: mockRepo)
//        
//        #expect(productStore.state == .initial)
//        
//        // When
//        let task = Task {
//            print("loading_state: Inside of Task")
//            await productStore.fetchProducts()
//        }
//        print("loading_state: before Task.yield")
//        await Task.yield()
//        print("loading_state: after Task.yield")
//        #expect(productStore.state == .loading)
//        
//        mockRepo.complete()
//        await task.value
//        
//        #expect(productStore.state == .error(mockResult.description))
//    }

}
