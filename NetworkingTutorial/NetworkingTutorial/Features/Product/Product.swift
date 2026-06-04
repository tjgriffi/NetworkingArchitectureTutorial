//
//  Product.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/12/26.
//

import Foundation

struct Product: Decodable, Identifiable, Equatable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let brand: String?
    let thumbnail: String
    let images: [String]
}

extension Product {
    /**
     {
       "id": 1,
       "title": "Essence Mascara Lash Princess",
       "description": "The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects. Achieve dramatic lashes with this long-lasting and cruelty-free formula.",
       "category": "beauty",
       "price": 9.99,
       "discountPercentage": 7.17,
       "rating": 4.94,
       "stock": 5,
       "tags": [
         "beauty",
         "mascara"
       ],
       "brand": "Essence",
       "sku": "RCH45Q1A",
       "weight": 2,
       "dimensions": {
         "width": 23.17,
         "height": 14.43,
         "depth": 28.01
       },
       "warrantyInformation": "1 month warranty",
       "shippingInformation": "Ships in 1 month",
       "availabilityStatus": "Low Stock",
       "reviews": [
         {
           "rating": 2,
           "comment": "Very unhappy with my purchase!",
           "date": "2024-05-23T08:56:21.618Z",
           "reviewerName": "John Doe",
           "reviewerEmail": "john.doe@x.dummyjson.com"
         },
         {
           "rating": 2,
           "comment": "Not as described!",
           "date": "2024-05-23T08:56:21.618Z",
           "reviewerName": "Nolan Gonzalez",
           "reviewerEmail": "nolan.gonzalez@x.dummyjson.com"
         },
         {
           "rating": 5,
           "comment": "Very satisfied!",
           "date": "2024-05-23T08:56:21.618Z",
           "reviewerName": "Scarlett Wright",
           "reviewerEmail": "scarlett.wright@x.dummyjson.com"
         }
       ],
       "returnPolicy": "30 days return policy",
       "minimumOrderQuantity": 24,
       "meta": {
         "createdAt": "2024-05-23T08:56:21.618Z",
         "updatedAt": "2024-05-23T08:56:21.618Z",
         "barcode": "9164035109868",
         "qrCode": "..."
       },
       "thumbnail": "...",
       "images": ["...", "...", "..."]
     }
     */
    static let example = Product(
        id: 1,
        title: "Essence Mascara Lash Princess",
        description: "The Essence Mascara Lash Princess is a popular mascara known for its volumizing and lengthening effects. Achieve dramatic lashes with this long-lasting and cruelty-free formula.",
        category: "beauty",
        price: 100,
        discountPercentage: 0.5,
        rating: 5.0,
        stock: 1,
        brand: "Essence",
        thumbnail: "https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp",
        images: ["https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/1.webp"])
}

struct ProductResponse: Decodable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
    
    static let example = ProductResponse(
        products: [Product.example],
        total: 1,
        skip: 0,
        limit: 1)
}
