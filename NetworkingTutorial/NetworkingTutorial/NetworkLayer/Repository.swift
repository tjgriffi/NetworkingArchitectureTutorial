//
//  Repository.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/12/26.
//

import Foundation

protocol NetworkClientProtocol {
    func fetch<T: Decodable>(_ urlString: String) async throws -> T
}

enum RepositoryError: String, LocalizedError {
    case invalidHttpResponse
    case badStatusCode
    case invalidURL
    case decodingFailed
    
    var description: String {
        switch self {
        case .invalidHttpResponse:
            return "Invalid Http response"
        case .badStatusCode:
            return "Status code of http response outside of 200 - 299 range"
        case .invalidURL:
            return "The url was invalid"
        case .decodingFailed:
            return "Decoding the response went wrong"
        }
    }
}

class Repository: NetworkClientProtocol {
    
    func fetch<T>(_ urlString: String) async throws -> T where T : Decodable {
        let urlComponents = URLComponents(string: urlString)
        guard let url = urlComponents?.url else {
            throw RepositoryError.invalidURL
        }
        
        let request = URLRequest(url: url)
        
        guard let requestURL = request.url else {
            throw RepositoryError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: requestURL)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RepositoryError.invalidHttpResponse
        }
        
        guard (0...299).contains(httpResponse.statusCode) else {
            throw RepositoryError.badStatusCode
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            
            return decodedResponse
        } catch {
            throw RepositoryError.decodingFailed
        }
        
    }
}
