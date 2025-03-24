//
//  StoreView.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 13/03/2025.
//

import SwiftUI

struct StoreView: View {
    var storeName: String
    
    @State private var categories: [String] = ["Meats", "Egg", "Dairy","Drinks","Frozen"]
    @State private var selectedCategory: String? = nil
    @State private var productsByCategory: [String: [Item]] = [:]
    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    
    let db = DatabaseHandling()
    
    let storeColours: [String: Color] = [
        "Tesco": Color.blue.opacity(1),
        "Sainsbury's": Color.orange.opacity(1),
        "ALDI": Color.red.opacity(0.8),
        "Lidl": Color.yellow.opacity(0.8)
    ]
    
    let defaultColour = Color.gray.opacity(0.8)
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Text(storeName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    TextField("Search", text: $searchText)
                        .padding(10)
                        .autocapitalization(.none)
                        .foregroundColor(.black)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                    .frame(height: UIScreen.main.bounds.height / 3)
                    .frame(maxWidth: .infinity)
                    .background(storeColours[storeName] ?? defaultColour)
                    .foregroundColor(.white)
                Spacer()
                
                if isLoading {
                    ProgressView("Loading categories...")
                } else {
                    ScrollView (.vertical, showsIndicators: false){
                        VStack {
                            ForEach($categories, id: \.self) { $category in
                                HStack {
                                    Text(category)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding()
                                    Spacer()
                                }
                                if let items = productsByCategory[category] {
                                    // Show first 7 items in a ScrollView
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(items.prefix(7), id: \.id) { item in
                                                NavigationLink(destination: ItemDetView(item: item)){
                                                    ItemRowView(item: item)
                                                }
                                            }
                                        }
                                    }
                                    HStack {
                                        Spacer()
                                        // Button to see all items in the category
                                        Button(action: {
                                            // Navigate to the category detail view
                                            //navigateToCategoryDetailView(category)
                                        }) {
                                            Text("See All")
                                                .foregroundColor(.blue)
                                                .font(.body)
                                        }.padding()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onAppear { loadProducts() }
        }
        
    }
    
    private func loadProducts() {
        isLoading = true
        db.getAllDocumentsInCollection(fromCollection: "Stores/\(storeName)/products") { (result: Result<[Item], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    // Group items by category
                    let groupedItems = Dictionary(grouping: items, by: { $0.category ?? "Unknown" })
                    self.productsByCategory = groupedItems
                case .failure(let error):
                    print("Error fetching products: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        }
    }
    
    private func categoryHeader(category: String) -> some View {
        HStack {
            Text(category)
                .font(.headline)
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(5)
    }

    private func navigateToCategoryDetailView(category: String) {
        // Navigation to the category detail view
        // Assuming `CategoryDetailView` is a new SwiftUI view that displays all items in the category
    }
}

struct ItemRowView: View {
    var item: Item
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: item.image_url ?? "")) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
            } placeholder: {
                ProgressView()
            }

            Text(item.product_name ?? "")
                .font(.caption)
                .lineLimit(1)
            Text("£\(item.price ?? "0.00")")
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 100)
        .padding(5)
    }
}

struct CategoryDetailView: View {
    var category: String
    @State private var products: [Item] = []
    @State private var isLoading: Bool = true
    
    let db = DatabaseHandling()

    var body: some View {
        VStack {
            Text("\(category) Products")
                .font(.largeTitle)
                .padding()
            
            if isLoading {
                ProgressView("Loading products...")
            } else {
                List(products, id: \.id) { item in
                    ItemRowView(item: item)
                }
            }
        }
        .onAppear { loadProducts() }
    }

    private func loadProducts() {
        db.getAllDocumentsInCollection(fromCollection: "Stores/YourStoreName/products") { (result: Result<[Item], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    // Filter products by category
                    self.products = items.filter { $0.category == category }
                case .failure(let error):
                    print("Error fetching products: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        }
    }
}
