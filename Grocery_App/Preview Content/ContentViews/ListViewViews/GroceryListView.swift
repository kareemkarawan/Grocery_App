//
//  GroceryListView.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 18/03/2025.
//

import SwiftUI

struct GroceryListView: View {
    @EnvironmentObject var session: UserSession
    
    let UH = UserHandling()
    
    var groceryList: GroceryList
    
    @State private var groceryItems: [Item] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(groceryList.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                List(groceryItems, id: \.id) { item in
                    NavigationLink(destination: ItemDetView(item: item)){
                        GroceryItemRowView(item: item, onDelete: {
                            deleteItem(item)
                        })
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteItem(item)
                            } label : { Label("Delete", systemImage: "trash") }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .onAppear {
                fetchItems(for: groceryList)
            }
        }
    }
    private func fetchItems(for groceryList: GroceryList){
        guard let userId = session.currentUser?.id else { return }
        guard let listId = groceryList.id else { return }
        UH.getGroceryItemsFromList(for: userId, listId: listId) { items in
            self.groceryItems = items
        }
    }
    private func deleteItem(_ item: Item){
        guard let userId = session.currentUser?.id else { return }
        guard let listId = groceryList.id else { return }
        guard let itemId = item.id else { return }
        
        UH.deleteItemFromList(for: userId, listId: listId, itemId: itemId) { success in
            print("Deleted item: \(success)")
            fetchItems(for: groceryList)
        }
        
    }
}

struct GroceryItemRowView: View {
    var item: Item
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: item.image_url ?? "")) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .cornerRadius(5)
            } placeholder: {
                ProgressView()
            }
            Text(item.product_name ?? "")
                .font(.body)
            
            Spacer()
            
            Text(String("£ \(item.price ?? "0")"))
                .font(.body)
                .foregroundColor(Color.gray)
        }
        .padding()
    }
}

