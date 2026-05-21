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
    @State private var receivedProductStoreError: Bool = false
    
    var body: some View {
        ZStack {
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
                    .task {
                        await productStore.fetchProducts()
                    }
            }
            .searchable(text: $searchText, prompt: "Search")
        }
    }
}

struct ProductStoreListView: View {
    @Binding var productStore: ProductStore
    
    var body: some View {
        List(productStore.products) { product in
            ProductRow(product: product)
        }
        .overlay {
            if case .error(let message) = productStore.state {
                Text(message)
                    .foregroundStyle(.red)
            }
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

#Preview("1 item") {
//    @State @Previewable var productStore = ProductStore()
//    ProductStoreView(productStore: productStore)
    ProductStoreView(
        productStore: ProductStore(
            productService: MockProductService()))
}

#Preview("Error") {
    ProductStoreView(
        productStore: ProductStore(
            productService: MockProductService(
                error: RepositoryError.badStatusCode(
                    statusCode: 404, message: "does not exist"))))
}
