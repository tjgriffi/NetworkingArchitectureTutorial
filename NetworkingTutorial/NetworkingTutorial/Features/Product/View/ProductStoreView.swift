//
//  ProductStoreView.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/15/26.
//

import SwiftUI

struct ProductStoreView: View {
    @State var productStore: ProductStore
    @State private var isFilterShown: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                ProductStoreListView(productStore: productStore)
                    .navigationTitle("Products")
                    .toolbar {
                        Button {
                            isFilterShown.toggle()
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }

                    }
                    .onTriggerLoadAt(triggerDistance: 300) {
                        productStore.fetch(for: .more)
                    }
                    .sheet(isPresented: $isFilterShown) {
                        FilterProductsView( isFilterViewShown: $isFilterShown, productStore: productStore)
                    }
                    .onAppear {
                        productStore.fetch(for: .initial)
                    }
            }
        }
    }
}

struct ProductStoreListView: View {
    @State private var searchText: String = ""
    @Bindable var productStore: ProductStore
    
    var body: some View {
        List(productStore.products) { product in
            ProductRow(product: product)
        }
        .overlay {
            
            switch productStore.state {
            case .initial, .loading:
                ProgressView()
                    .controlSize(.large)
            case .loaded:
                if productStore.products.isEmpty {
                    ContentUnavailableView("Nothing Found", systemImage: "basket")
                }
            case .error(let message):
                Text(message)
                    .foregroundStyle(.red)
            }
        }
        .searchable(text: $productStore.configuration.searchText, prompt: "Search")
        .onChange(of: productStore.configuration.searchText) { oldValue, newValue in
            productStore.fetch(for: .searching)
        }
    }
}

struct ProductRow: View {
    var product: Product
    
    var body: some View {
        HStack {
            // Image
            AsyncImage(url: URL(string: product.thumbnail)) { phase in
                switch phase {
                case .empty:
                    Color.gray
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure(let error):
                    Color.gray
                @unknown default:
                    fatalError()
                }
            }
            .frame(width: 100, height: 100)
            VStack(alignment: .leading) {
                // Title
                Text(product.title)
                    .bold()
                // Category
                Text(product.category.capitalized)
                    .foregroundStyle(.gray)
                HStack {
                    // price
                    Text("$ \(product.price, specifier: "%.2f")")
                        .bold()
                    // discount
                    Text("\(product.discountPercentage, specifier: "%.2f")% off")
                        .foregroundStyle(.mint)
                }
                
            }
            // Star + rating
            Label(product.rating.description, systemImage: "star.fill")
        }
    }
}

extension View {
    
    func onTriggerLoadAt(triggerDistance: CGFloat, of transform: @escaping () -> Void) -> some View {
        
        return self
            .onScrollGeometryChange(for: Bool.self) { geometry in
                // Check that this isn't the initial rendering of the list
                guard geometry.contentSize.height > 0 else { return false }
                
                let maxOffset = geometry.contentSize.height - geometry.containerSize.height
                
                let currentOffset = geometry.contentOffset.y
                                
                return currentOffset >= maxOffset - triggerDistance
            } action : { wasNearBottom, isNearBottom in
                // Action only fires when bool changes
                if isNearBottom && !wasNearBottom {
                    transform()
                }
            }
    }
}

#Preview("Items") {
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
