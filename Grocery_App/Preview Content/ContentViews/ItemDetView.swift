//
//  ItemDetView.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 18/03/2025.
//

import SwiftUI

struct ItemDetView: View {
    @EnvironmentObject var session: UserSession
    
    var item: Item
    
    @State private var ShowListSelection = false
    @State private var userLists: [GroceryList] = []
    @State private var MainList: GroceryList?
    @State private var selectedList: String?
    @State private var isFavorite = false
    
    let db = DatabaseHandling()
    let UH = UserHandling()
    
    let storeColours: [String: Color] = [
        "Tesco": Color.blue.opacity(1),
        "Sainsbury's": Color.orange.opacity(1),
        "ALDI": Color.red.opacity(0.8),
        "Lidl": Color.yellow.opacity(0.8)
    ]
    
    let defaultColour = Color.gray.opacity(0.8)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                AsyncImage(url: URL(string: item.image_url ?? "")) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .cornerRadius(20)
                } placeholder: {
                    ProgressView()
                }.padding()
                Text(item.product_name ?? "Unkown Product")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
            }.frame(height: UIScreen.main.bounds.height / 4)
                .frame(maxWidth: .infinity)
                .background(storeColours[item.store ?? ""] ?? defaultColour)
                .foregroundColor(.white)
            Spacer()
            VStack(alignment: .leading, spacing: 8) {
                Text("Description: \(item.description ?? "No Description")")
                    .font(.caption)
                Text("£ \(item.price ?? "0")")
                    .font(.caption)
                Text("Store: \(item.store ?? "Unkown store")")
            }
            Spacer()
            HStack {
                Button(action: addToMainList) {
                    VStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(Color.white)
                        Text("Add to Main List")
                            .font(.headline)
                            .foregroundColor(Color.white)

                    }
                    
                }.background(Color.green)
                    .cornerRadius(8)
                    .frame(width: 50, height: 50)
                    .padding()
                Button(action: { ShowListSelection = true }) {
                    VStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(Color.white)
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(Color.white)

                    }
                }.background(storeColours[item.store ?? ""] ?? defaultColour)
                    .cornerRadius(8)
                    .frame(width: 50, height: 50)
                    .padding()
                Spacer()
                Button (action: toggleFav) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .black : .white)
                        .padding()
                        .background(isFavorite ? Color.gray : Color.green)
                        .clipShape(Circle())
                }
                .onAppear {
                    checkFav()
                }
            }
        }.onAppear(perform: getLists)
            .actionSheet(isPresented: $ShowListSelection) {
                ActionSheet(
                    title: Text("Select a List"),
                    buttons: userLists.map { list in
                            .default(Text(list.name)) {
                                addToList(list)
                            }
                    } + [.cancel()]
                        
                )
            }
    }
    private func getLists() {
        guard let userId = session.currentUser?.id else {return}
        UH.getAllGroceryLists(userId: userId) { lists in
            if let lists = lists {
                self.userLists = lists
            }
        }
    }
    private func addToMainList() {
        if let main = userLists.first(where: { $0.isMainList == true}) {
            MainList = main
        } else {
            print("Main list not found")
        }
        guard let userId = session.currentUser?.id else {return}
        guard let LId = MainList?.id else {return}
        UH.addItemToList(for: userId, item: item, listId: LId) { success in
            print(success ? "Added to Main List" : "Failed to add to Main List")
        }
    }
    
    private func addToList(_ glist: GroceryList) {
        guard let userId = session.currentUser?.id else {return}
        guard let LId = glist.id else {return}
        UH.addItemToList(for: userId, item: item, listId: LId) { success in
            print(success ? "Added to List" : "Failed to add to List")
        }
    }
    private func checkFav() {
        guard let userId = session.currentUser?.id else {return}
        guard let ItemId = item.id else {return}
        db.checkIfFavorite(for: userId, itemId: ItemId) { result in
            DispatchQueue.main.async {
                isFavorite = result
            }
        }
    }
    private func toggleFav() {
        guard let userId = session.currentUser?.id else {return}
        db.toggleFavorite(for: userId, item: item, isFavorite: isFavorite) { result in
            DispatchQueue.main.async {
                isFavorite = result
            }
        }
    }
}

