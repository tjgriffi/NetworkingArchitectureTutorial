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
            if isSuspensionNeeded {
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
            continuation?.resume()
        }
    }
    
    class MockProductServiceTest: ProductService {
        
        var result: Result<[Product], Error>
        
        init(result: Result<[Product], Error>) {
            self.result = result
        }
        
        func fetch(skip: Int, limit: Int) async throws -> [NetworkingTutorial.Product] {
            switch result {
            case .success(let success):
                
                return success
            case .failure(let failure):
                throw failure
            }
        }
    }

    @Test func fetch_product_from_backend_success() async throws {
        
        // Given
        let mockResults = [Product.example]
        
        let mockProductService = MockProductServiceTest(result: .success(mockResults))
        let productStore = ProductStore(productService: mockProductService)
        
        #expect(productStore.products.count == 0, "There should not be any products initially") 
        
        // When
        await productStore.initialFetchProducts()
        
        // Then
        #expect(productStore.products.count == 1, "There is an incorrect number of products that was added")
        #expect(productStore.products[0] == Product.example)
    }
    
    @Test func fetch_product_from_backend_badStatusCode_failure() async {
        
        // Given
        let mockResults = RepositoryError.badStatusCode(statusCode: 401, message: "does not exist")
        
        let mockProductService = MockProductServiceTest(result: .failure(mockResults))
        let productStore = ProductStore(productService: mockProductService)
        
        // When
        await productStore.initialFetchProducts()
        
        // Then
        #expect(productStore.state == .error(mockResults.description))
        #expect(productStore.products.isEmpty)
    }
    
    @Test func fetch_product_from_backend_decodingFailed_failure() async {
        
        // Given
        let mockResults = RepositoryError.decodingFailed
        
        let mockProductService = MockProductServiceTest(result: .failure(mockResults))
        let productStore = ProductStore(productService: mockProductService)
        
        // When
        await productStore.initialFetchProducts()
        
        // Then
        #expect(productStore.state == .error(mockResults.description))
        #expect(productStore.products.isEmpty)
    }
    
    @Test func fetch_product_from_backend_invalidHttpResponse_failure() async {
        
        // Given
        let mockResults = RepositoryError.invalidHttpResponse
        
        let mockProductService = MockProductServiceTest(result: .failure(mockResults))
        let productStore = ProductStore(productService: mockProductService)
        
        // When
        await productStore.initialFetchProducts()
        
        // Then
        #expect(productStore.state == .error(mockResults.description))
        #expect(productStore.products.isEmpty)
    }
    
    @Test func fetch_product_from_backend_invalidURL_failure() async {
        
        // Given
        let mockResults = RepositoryError.invalidURL
        
        let mockProductService = MockProductServiceTest(result: .failure(mockResults))
        let productStore = ProductStore(productService: mockProductService)
        
        // When
        await productStore.initialFetchProducts()
        
        // Then
        #expect(productStore.state == .error(mockResults.description))
        #expect(productStore.products.isEmpty)
    }
    
//    @Test func fetch_product_from_backend_loading_state() async throws {
//        
//        // Given
//        let mockResult = RepositoryError.badStatusCode(statusCode: 401, message: "does not exist")
//        let mockProductService = MockProductService(result:.failure(mockResult), isSuspensionNeeded: true)
//        let productStore = ProductStore(productService: mockProductService)
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
