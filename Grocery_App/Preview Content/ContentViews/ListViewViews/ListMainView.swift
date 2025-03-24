//
//  ListMainView.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 05/03/2025.
//

import SwiftUI

struct ListMainView: View {
    
    @EnvironmentObject var session: UserSession
    
    @State var searchText: String = ""
    @State private var groceryLists: [GroceryList] = []
    @State private var isLoading = false
    
    @State private var showAddListForm = false
    @State private var newListName: String = ""
    
    let UH = UserHandling()
    
    var filteredLists: [GroceryList] {
        if searchText.isEmpty {
            return groceryLists
        } else {
            return groceryLists.filter { $0.name.localizedCaseInsensitiveContains(searchText)}
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("My Grocery Lists")
                    .font(.headline)
                    .padding()
                TextField("Search Lists...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                } else {
                    List {
                        if let mainList = groceryLists.first(where: { $0.isMainList == true }) {
                            Section(header: Text("Main List").font(.headline)) {
                                GroceryListRow(list: mainList, deleteAction: deleteList)
                            }
                        }
                        Section(header: Text("Other Lists").font(.headline)) {
                            ForEach(filteredLists.filter { $0.isMainList == false }) { list in
                                GroceryListRow(list: list, deleteAction: deleteList)
                            }
                        }
                    }
                }
                Button(action: {showAddListForm.toggle()}) {
                    Label("Add New List", systemImage: "plus")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(1))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding(.horizontal)
                }
                .padding()
            }
            .onAppear(perform: getLists)
            .sheet(isPresented: $showAddListForm) {
                Text("Enter List Name")
                    .font(.headline)
                TextField("List Name", text: $newListName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                HStack {
                    Button("Add List") {
                        addNewList(name: newListName)
                        showAddListForm.toggle()
                    }
                    .padding()
                    .background(Color.green.opacity(1))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                    Button("Cancel") {
                        showAddListForm = false
                    }
                    .foregroundColor(.red)
                    .padding()
                }
            }
        }
    }
    private func addNewList(name: String) {
        guard let userId = session.currentUser?.id else {return}
        UH.addGroceryList(for: userId, listName: name) { success in
            print("Added new List")
        }
        getLists()
    }
    private func deleteList(_ list: GroceryList) {
        guard let userId = session.currentUser?.id else {return}
        guard let listId = list.id else {return}
        UH.deleteGroceryList(for: userId, listId: listId) { success in
            print("Deleted List")
        }
    }
    private func getLists() {
        guard let userId = session.currentUser?.id else {return}
        self.isLoading = true
        UH.getAllGroceryLists(userId: userId) { lists in
            if let lists = lists {
                self.groceryLists = lists
            }
            self.isLoading = false
        }
    }
}
#Preview {
    ListMainView()
}

struct GroceryListRow: View {
    var list: GroceryList
    var deleteAction: (GroceryList) -> Void?
    
    var body: some View {
        HStack {
            Text(list.name)
                .font(.headline)
            NavigationLink(destination: GroceryListView(groceryList: list)) {
            }
        }
        .padding(.vertical, 5)
    }
}

struct GroceryListDetailView: View {
    var list: GroceryList
    var deleteAction: (GroceryList) -> Void?
    
    @State private var showAlert = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Viewing: \(list.name)")
                .font(.largeTitle)
                .navigationTitle(list.name)
            if list.isMainList == false{
                Button(action: { showAlert = true} ) {
                    Label("Delete List", systemImage: "trash")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Capsule())
                        .padding(.horizontal)
                }
            }
        }.alert("Are you sure?", isPresented: $showAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAction(list)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
        
    }
}
