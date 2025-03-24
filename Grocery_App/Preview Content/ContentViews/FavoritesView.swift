//
//  FavoritesView.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 17/03/2025.
//

import SwiftUI

struct FavoritesView: View {
    
    @EnvironmentObject var session: UserSession
    
    @State var favorites: [Item] = []
    @State var isLoading = false
    @State var errorMessage: String? = nil
    
    let UH = UserHandling()
    let db = DatabaseHandling()
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading{
                    ProgressView("Loading favorites...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if favorites.isEmpty {
                    Text("No favorites yet!")
                        .foregroundColor(.gray)
                } else {
                    List {
                        ForEach(favorites) { item in
                            HStack {
                                VStack(alignment: .leading) {

                                    Text(item.product_name ?? "")
                                        .font(.headline)
                                    let itemPrice = item.price ?? ""
                                    let itemStore = item.store ?? ""
                                    
                                    Text("Price: \(itemPrice) - Store: \(itemPrice)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                let itemId = item.id ?? ""
                                Button(action: {remove(for: itemId)}){
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }.onAppear(perform: loadFavorites)
        }
    }
    private func loadFavorites() {
        isLoading = true
        errorMessage = nil
        
        let userId = session.currentUser?.id ?? ""
            db.fetchFavorites(for: userId) { result in
                DispatchQueue.main.async{
                    favorites = result
                    isLoading = false
                }
            }
    }
    
    private func remove(for itemId: String) {
        let userId = session.currentUser?.id ?? ""
        db.removeFromFavorites(for: userId, itemId: itemId) { result in
            if result {
                DispatchQueue.main.async{
                    loadFavorites()
                }
            }
        }
    }
}

#Preview {
    FavoritesView()
}
