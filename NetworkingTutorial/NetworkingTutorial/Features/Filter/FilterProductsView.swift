//
//  FilterProductsView.swift
//  NetworkingTutorial
//
//  Created by Terrance Griffith on 5/28/26.
//

import SwiftUI

struct FilterProductsView: View {
    
    @State var categoryVM: CategoriesVM = CategoriesVM()
    @Binding var isFilterViewShown: Bool
    
    @State private var sortField = SortField.title
    @State private var sortOrder: SortOrder?
    @State private var selectedCategory: String?
    
    @Bindable var productStore: ProductStore
        
    var body: some View {
        NavigationStack {
            List {
                
                Picker("Sort By", selection: $productStore.configuration.sortField) {
                    ForEach(SortField.allCases) { sortFieldCase in
                        Text(sortFieldCase.displayName)
                            .tag(sortFieldCase)
                    }
                }
                .pickerStyle(.inline)
                
                Picker("Order", selection: $productStore.configuration.sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { sortOrderCase in
                        Text(sortOrderCase.displayName)
                            .tag(sortOrderCase)
                    }
                }
                .pickerStyle(.inline)
                
                Picker("Category", selection: $productStore.configuration.category) {
                    ForEach(categoryVM.categories, id: \.self) { category in
                        Text(category)
                            .tag(category)
                    }
                }
                .pickerStyle(.inline)
            }
            .task(id: "categoryFetch") {
                await categoryVM.fetchProductCategories()
            }
            .navigationTitle("Search for Products")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done", role: .close) {
                        productStore.fetch(for: .filter)
                        isFilterViewShown.toggle()
                    }
                }
                
                ToolbarItem(id: "Cancel", placement: .topBarTrailing) {
                    Button("Clear", role: .destructive) {
                        isFilterViewShown.toggle()
                    }
                    .bold()
                }
            }
        }
    }
    
}

#Preview {
    FilterProductsView(categoryVM:
                        CategoriesVM(service:
                                        MockCategoriesService(
                                            result: .success(["Beauty",
                                                              "Fragrances",
                                                              "Furniture",
                                                              "Groceries",
                                                              "Home-Decoration"]))),
                       isFilterViewShown: .constant(true),
                       productStore: ProductStore(productService: MockProductService(error: nil, result: .example)))
}
