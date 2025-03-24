//
//  HomeView.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 18/02/2025.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var session: UserSession
    
    @State private var categories: [String] = ["Meats", "Egg", "Dairy","Drinks","Frozen"]
    @State private var productsByCategory: [String: [Item]] = [:]
    @State private var isLoggedin = true
    @State private var selectedTab = 0
    @State private var searchText: String = ""
    
    @State private var isLoading = false
    
    let db = DatabaseHandling()
    let storeHandler = StoreHandler()
    
    var body: some View {
        NavigationStack {
            VStack() {
                VStack {
                    if let username = session.currentUser?.username {
                        Text("Welcome, " + username)
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    HStack {
                        TextField("Search", text: $searchText)
                            .padding(10)
                            .autocapitalization(.none)
                            .foregroundColor(.black)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        NavigationLink(destination: ScanItemView()) {
                            Image(systemName: "barcode.viewfinder")
                        }.padding()
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(storeHandler.stores) { store in
                                NavigationLink(destination: StoreView(storeName: store.Name ?? "")){
                                    StoreCardView(store: store)
                                }
                            }
                        }.padding()
                        NavigationLink(destination: addNewItem()) {
                            Text("add")
                        }
                    }
                }
                    .frame(height: UIScreen.main.bounds.height / 3)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.0, green: 0.7, blue: 0.0))
                    .foregroundColor(.white)
                Spacer()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        ForEach(categories, id: \.self) { category in
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
                    .onAppear(perform: loadProducts)
                }
            }
        }
        
    }
    private func loadProducts() {
        isLoading = true
        db.getAllDocumentsInCollection(fromCollection: "Products") { (result: Result<[Item], Error>) in
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
}
#Preview {
    HomeView()
}

struct StoreCardView: View {
    var store: Stores

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: store.imageURL ?? "https://via.placeholder.com/100")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                case .failure(_):
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
            Text(store.Name ?? "Unknown Store") // ✅ Default name
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(width: 120)
    }
}
