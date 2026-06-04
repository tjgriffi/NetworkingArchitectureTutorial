//
//  SortOrder.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/29/26.
//

import Foundation

enum SortField: String, CaseIterable, Identifiable {
    case title
    case priceAsc
    case priceDesc
    case rating
    case stock
    case discount
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .title:
            "Title"
        case .priceAsc:
            "Lowest Price"
        case .priceDesc:
            "Highest Price"
        case .rating:
            "Rating"
        case .stock:
            "Stock"
        case .discount:
            "Discount"
        }
    }
    
    var queryValue: String {
        switch self {
        case .title:
            "title"
        case .priceAsc, .priceDesc:
            "price"
        case .rating:
            "rating"
        case .stock:
            "stock"
        case .discount:
            "discount"
        }
    }
}

enum SortOrder: String, CaseIterable, Identifiable {
    case asc
    case desc
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .asc:
            "Low to High"
        case .desc:
            "High to Low"
        }
    }
}
