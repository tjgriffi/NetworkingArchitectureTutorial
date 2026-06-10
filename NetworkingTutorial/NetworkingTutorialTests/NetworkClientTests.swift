//
//  NetworkClientTests.swift
//  NetworkingTutorialTests
//
//  Created by Terrance Griffith on 6/6/26.
//

import Foundation
import Testing
@testable import NetworkingTutorial

@Suite(.serialized)
@MainActor
class NetworkClientTests {
    
    struct MockEndpoint: Endpoint {
        typealias Response = [String: String]
        
        let path: String
        
        let method: NetworkingTutorial.HTTPMethod
        
        let queryItems: [URLQueryItem]
        let urlRequest: URLRequest?
        let error: Error?
        
        func makeRequest(baseURL: URL) throws -> URLRequest {
            
            guard urlRequest != nil else {
                throw RepositoryError.invalidURL
            }
            
            return urlRequest!
        }
        
        func map(data: Data) throws -> [String: String] {
            if let _ = error {
                throw error!
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            do {
                let response = try decoder.decode(Response.self, from: data)
                
                return response
            } catch {
                throw RepositoryError.decodingFailed
            }
        }
    }
    
    class MockURLProtocol: URLProtocol {
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        static var requestHandler: ((URLRequest) throws -> (URLResponse, Data))?
        
        override func startLoading() {
            guard let handler = MockURLProtocol.requestHandler else {
                Issue.record("No request handler was set", severity: .error)
                #expect(MockURLProtocol.requestHandler != nil)
                return
            }
            
            do {
                let (response, data) = try handler(request)
                
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                Issue.record("Error handling request: \(error)")
            }
        }
        
        override func stopLoading() { }
    }
    
    var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }()
    
    lazy var mockURLRequest: URLRequest = {
        URLRequest(url: URL(string: "path")!)
    }()
    
    var mockDataString: String {
        """
            { 
                "key": "success" 
            }
        """
    }
    
    var mockDataStringServerError: String {
        """
            { 
                "message": "Server error message" 
            }
        """
    }

    @Test func fetch_with_endpoint_invalidURL() async throws {
        // Given
        let mockEndpoint = MockEndpoint(path: "", method: .get, queryItems: [], urlRequest: nil, error: nil)
        let sutNetworkClient = NetworkClient(session: session)
        
        // When
        let error = await #expect(throws: RepositoryError.self) {
            
            try await sutNetworkClient.fetch(mockEndpoint)
        }
        
        // Then
        #expect(error?.description == RepositoryError.invalidURL.description)
    }
    
    @Test func fetch_with_endpoint_invalidHttpResponse() async throws {
        
        // Given
        let data = mockDataString.data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            
            let response = URLResponse()
            return (response, data)
        }
        
        let mockEndpoint = MockEndpoint(path: "", method: .get, queryItems: [], urlRequest: mockURLRequest, error: nil)
        let sutNetworkClient = NetworkClient(session: session)
        
        // When
        let error = await #expect(throws: RepositoryError.self) {
            
            try await sutNetworkClient.fetch(mockEndpoint)
        }
        
        // Then
        #expect(error?.description == RepositoryError.invalidHttpResponse.description)
    }
    
    @Test func fetch_with_endpoint_badStatus() async throws {
        // Given
        let data = mockDataStringServerError.data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            
            let response = HTTPURLResponse(
                url: URL(string:"path")!,
                statusCode: 404,
                httpVersion: "",
                headerFields: nil)!
            
            return (response, data)
        }
        
        let mockEndpoint = MockEndpoint(path: "", method: .get, queryItems: [], urlRequest: mockURLRequest, error: nil)
        let sutNetworkClient = NetworkClient(session: session)
        
        // When
        let error = await #expect(throws: RepositoryError.self) {
            
            try await sutNetworkClient.fetch(mockEndpoint)
        }
        
        // Then
        switch error! {
        case .badStatusCode(let _, let _):
            #expect(error?.description == "Status code of http response outside of 200 - 299 range")
        default:
            Issue.record("Should see a badStatus error")
        }
        
    }
    
    @Test func fetch_with_endpoint_taskCancellation() async throws {
        
        // Given
        let data = mockDataString.data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: URL(string:"path")!,
                statusCode: 200,
                httpVersion: "",
                headerFields: nil)!
            
            return (response, data)
        }
        
        let mockEndpoint = MockEndpoint(path: "", method: .get, queryItems: [], urlRequest: mockURLRequest, error: nil)
        let sutNetworkClient = NetworkClient(session: session)
        
        var task: Task<Void, Never>?
        
        // When
        var error: RepositoryError?
        task = Task {
            error = await #expect(throws: RepositoryError.self) {
                
                async let result = sutNetworkClient.fetch(mockEndpoint)
                async let result2 = Task.sleep(for: .seconds(1))
                
                try await [result, result2]
            }
        }
        
        task?.cancel()
        try await Task.sleep(for: .seconds(1))  // Sleep so we can wait for the error to be set inside of the local task
        
        // Then
        #expect(error?.description == RepositoryError.taskCancellation.description)
    }
    
    @Test func fetch_with_endpoint_decodingFailed() async throws {
        // Given
        let data = "Corrupted data".data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            
            let response = HTTPURLResponse(
                url: URL(string:"path")!,
                statusCode: 200,
                httpVersion: "",
                headerFields: nil)!
            
            return (response, data)
        }
        let mockEndpoint = MockEndpoint(path: "", method: .get, queryItems: [], urlRequest: mockURLRequest, error: nil)
        let sutNetworkClient = NetworkClient(session: session)
        
        // When
        let error = await #expect(throws: RepositoryError.self) {
            
            try await sutNetworkClient.fetch(mockEndpoint)
        }
        
        // Then
        #expect(error?.description == RepositoryError.decodingFailed.description)
    }
    
    @Test func fetch_with_endpoint_networkError() async throws {
        // Given
        let data = mockDataString.data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            
            let response = HTTPURLResponse(
                url: URL(string:"path")!,
                statusCode: 200,
                httpVersion: "",
                headerFields: nil)!
            
            return (response, data)
        }
        let mockEndpoint = MockEndpoint(path: "", method: .get, queryItems: [], urlRequest: mockURLRequest, error: PredicateError.forceCastFailure )
        let sutNetworkClient = NetworkClient(session: session)
        
        // When
        let error = await #expect(throws: RepositoryError.self) {
            
            try await sutNetworkClient.fetch(mockEndpoint)
        }
        
        // Then
        switch error! {
        case .networkError(let errorMsg):
            #expect(error?.description == "There was a network error: \(errorMsg.localizedDescription)")
        default:
            Issue.record("Should see a network error")
        }
        
    }
    
    @Test func fetch_with_endpoint_response_success() async throws {
        // Given
        let data = mockDataString.data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            
            let response = HTTPURLResponse(
                url: URL(string:"path")!,
                statusCode: 201,
                httpVersion: "",
                headerFields: nil)!
            
            return (response, data)
        }
        
        let mockEndpoint = MockEndpoint(path: "", method: .get, queryItems: [], urlRequest: mockURLRequest, error: nil)
        let sutNetworkClient = NetworkClient(session: session)
        
        // When
        let response = try await sutNetworkClient.fetch(mockEndpoint)
        
        // Then
        #expect(response.count == 1)
        #expect(response["key"] == "success")
    }
    
//
//    @Test mutating func fetch_with_endpoint_invalidHttpResponse() async throws {
//        
//    }

}
