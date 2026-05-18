//
//  ProductStoreView.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/15/26.
//

import SwiftUI

struct ProductStoreView: View {
    @State private var searchText: String = ""
    @State var productStore: ProductStore
    
    var body: some View {
        NavigationStack {
            ProductStoreListView(productStore: $productStore)
                .navigationTitle("Products")
                .toolbar {
                    NavigationLink {
                        Text("Filtered Button view!!")
                    } label: {
                        Image(systemName: "line.horizontal.3")
                    }
                }
        }
        .searchable(text: $searchText, prompt: "Search")
    }
}

struct ProductStoreListView: View {
    @Binding var productStore: ProductStore
    
    var body: some View {
        List(productStore.products) { product in
            ProductRow(product: product)
        }
    }
}

struct ProductRow: View {
    var product: Product
    
    var body: some View {
        HStack {
            // Image
            Rectangle()
                .fill(.gray)
                .frame(width: 50, height: 100)
            VStack {
                // Title
                Text(product.title)
                    .bold()
                // Category
                Text(product.category)
                    .foregroundStyle(.gray)
                HStack {
                    // price
                    Text("$" + product.price.description)
                        .bold()
                    // discount
                    HStack {
                        Text(product.discountPercentage.description)
                            .foregroundStyle(.mint)
                        Text("% off")
                            .foregroundStyle(.mint)
                    }
                }
                
            }
            // Star + rating
            Label(product.rating.description, systemImage: "star.fill")
        }
    }
}

#Preview {
    ProductStoreView(productStore: ProductStore(products: [Product.example]))
}
