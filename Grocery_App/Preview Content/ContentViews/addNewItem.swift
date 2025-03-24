//
//  addNewItem.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 14/03/2025.
//

import SwiftUI
import FirebaseFirestore

struct addNewItem: View {
    @State private var productName: String = ""
    @State private var category: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var imageURL: String = ""
    @State private var selectedStore: String = "Lidl"
    
    @ObservedObject var databaseHandler = DatabaseHandling()
    
    // Stores available for selection
    private let stores = ["Lidl", "Tesco", "ALDI", "Sainsbury's"]
    
    var body: some View {
        VStack {
            Text("Add New Product")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            // Form fields to input product information
            Form {
                Section(header: Text("Product Information")) {
                    TextField("Product Name", text: $productName)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description", text: $description)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Category", text: $category)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Price", text: $price)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Image URL", text: $imageURL)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Select Store")) {
                    Picker("Store", selection: $selectedStore) {
                        ForEach(stores, id: \.self) { store in
                            Text(store).tag(store)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Button(action: {
                    addProduct()
                }) {
                    Text("Add Product")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
    
    // Add the new product to Firestore
    private func addProduct() {
        let newItem = Item(product_name: productName, description: description, category: category, store: selectedStore, price: price, image_url: imageURL)
        
        // Adding the item to the selected store's "products" subcollection
        databaseHandler.addDocument(toCollection: "Stores/\(selectedStore)/products", document: newItem) { result in
            switch result {
            case .success(let documentID):
                print("Product added successfully with ID: \(documentID)")
            case .failure(let error):
                print("Error adding product: \(error.localizedDescription)")
            }
        }
        databaseHandler.addDocument(toCollection: "Products", document: newItem) { result in
            switch result {
            case .success(let documentID):
                print("Product added successfully with ID: \(documentID)")
            case .failure(let error):
                print("Error adding product: \(error.localizedDescription)")
            }
        }
    }
}
