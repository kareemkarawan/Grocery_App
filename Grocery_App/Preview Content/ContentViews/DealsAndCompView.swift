//
//  DealsAndCompView.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 17/03/2025.
//

import SwiftUI

struct DealsAndCompView: View {
    @State private var searchQuery: String = ""
        @State private var deals: [Item] = []
        @State private var priceComparisons: [String: [Item]] = [:] // Dictionary mapping product names to store prices
        @State private var isLoading = true
        @State private var errorMessage: String? = nil
        
        let db = DatabaseHandling()
        
        var body: some View {
            NavigationView {
                VStack {
                    // Search Bar
                    TextField("Search for a product...", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    if isLoading {
                        ProgressView("Loading deals and prices...")
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    } else {
                        // Display Deals
                        List {
                            Section(header: Text("Best Deals")) {
                                ForEach(deals) { item in
                                    DealRowView(item: item)
                                }
                            }
                            
                            // Display Price Comparison
                            Section(header: Text("Price Comparison")) {
                                ForEach(priceComparisons.keys.sorted(), id: \.self) { productName in
                                    if let items = priceComparisons[productName] {
                                        PriceComparisonRowView(productName: productName, items: items)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Deals & Price Comparison")
                .onAppear {
                    fetchDealsAndPrices()
                }
            }
        }
        
        // Fetch deals and price comparisons from Firestore
        func fetchDealsAndPrices() {
            isLoading = true
            errorMessage = nil
            
            db.fetchDeals { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedDeals):
                        self.deals = fetchedDeals
                        fetchPriceComparisons()
                    case .failure(let error):
                        self.errorMessage = "Error loading deals: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
            }
        }
        
        func fetchPriceComparisons() {
            db.getAllDocumentsInCollection(fromCollection: "Products") { (result: Result<[Item], Error>) in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let products):
                        var comparisonDict = [String: [Item]]()
                        for product in products {
                            comparisonDict[product.product_name ?? "Unknown", default: []].append(product)
                        }
                        self.priceComparisons = comparisonDict
                    case .failure(let error):
                        self.errorMessage = "Error loading price comparisons: \(error.localizedDescription)"
                    }
                }
            }
        }
}

struct DealRowView: View {
    var item: Item
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: item.image_url ?? "")) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 50)
            .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(item.product_name ?? "Unknown Product")
                    .font(.headline)
                Text("Price: \(item.price ?? "N/A")")
                    .foregroundColor(.secondary)
                Text("Store: \(item.store ?? "Unknown")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

// View for displaying price comparison for a single product
struct PriceComparisonRowView: View {
    var productName: String
    var items: [Item]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(productName)
                .font(.headline)
            
            ForEach(items) { item in
                HStack {
                    Text("\(item.store ?? "Unknown Store"):")
                        .font(.subheadline)
                    Spacer()
                    Text("Price: \(item.price ?? "N/A")")
                        .foregroundColor(.green)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(.vertical, 5)
    }
}
