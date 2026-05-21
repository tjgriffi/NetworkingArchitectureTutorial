//
//  CategoriesVM.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/15/26.
//

import Foundation
import SwiftUI

@Observable
class CategoriesVM {
    
    var categories: [String]
    var state: NetworkCallState = .initial
    private var service: CategoriesService
    
    init(categories: [String], service: CategoriesService = DefaultCategoriesService()) {
        self.service = service
        self.categories = categories
    }
    
    func fetchProductCategories() async {
        
        guard state != .loading else {
            // Too early to make a fetch
            return
        }

        state = .loading
        
        do {
            categories = try await service.fetch()
            state = .loaded
        } catch let error as RepositoryError {
            state = .error(error.description)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

