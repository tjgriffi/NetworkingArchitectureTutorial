//
//  Repository.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/12/26.
//

import Foundation

protocol NetworkClientProtocol {
//    func fetch<T: Decodable>(_ request: URLRequest) async throws -> T
    func fetch<E: Endpoint>(_ endpoint: E) async throws -> E.Response
}

struct NetworkClient: NetworkClientProtocol {
    
    let baseURL: URL
    
    init(baseURL: URL = URL(string: NTConstants.baseURLString)!) {
        self.baseURL = baseURL
    }
    
    @concurrent
    func fetch<E>(_ endpoint: E) async throws -> E.Response where E : Endpoint {
        
        let request = try endpoint.makeRequest(baseURL: baseURL)
        
        guard let requestURL = request.url else {
            throw RepositoryError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: requestURL)
            
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RepositoryError.invalidHttpResponse
            }
            
            guard (0...299).contains(httpResponse.statusCode) else {
                
                let serverError = try JSONDecoder().decode(ServerError.self, from: data)
                throw RepositoryError.badStatusCode(statusCode: httpResponse.statusCode, message: serverError.message)
                
                // 404 - does not exist
                // 401 - auth problems
                // 429 - rate limited
                // 500...599 server errors
            }
                        
            return try endpoint.map(data: data)
            
        } catch let error as URLError where error.code == .cancelled {
            throw RepositoryError.taskCancellation
        } catch is CancellationError {
            throw RepositoryError.taskCancellation
        } catch {
            debugPrint(error)
            throw RepositoryError.networkError(error: error)
        }
    }
}

enum RepositoryError: LocalizedError {
    case invalidHttpResponse
    case badStatusCode(statusCode: Int, message: String)
    case invalidURL
    case decodingFailed
    case taskCancellation
    case networkError(error: Error)
    
    var description: String {
        switch self {
        case .invalidHttpResponse:
            return "Invalid Http response"
        case .badStatusCode(let statusCode, let message):
            return "Status code of http response outside of 200 - 299 range"
        case .invalidURL:
            return "The url was invalid"
        case .decodingFailed:
            return "Decoding the response went wrong"
        case .taskCancellation:
            return "The background task was cancelled"
        case .networkError(error: let error):
            return "There was a network error: \(error.localizedDescription)"
        }
    }
}

struct ServerError: Decodable {
    let message: String
}
