//
//  FirebaseService.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 10/02/2025.
//

import Foundation
import FirebaseFirestore

public class FirestoreService: ObservableObject {
    @Published var items: [Item] = []
    
    private var db = Firestore.firestore()
    
//    func fetchItems() {
//        db.collection("items").getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error.localizedDescription)")
//                return
//            }
//            guard let documents = snapshot?.documents else {
//                print("No documents found in 'items' collection.")
//                return
//            }
//            
//            self.items = documents.map {docSnapshot -> Item in
//                let data = docSnapshot.data()
//                let name = data["name"] as? String ?? "Unnamed"
//                let description = data["description"] as? String ?? "No description"
//                return Item(id: docSnapshot.documentID, name: name, description: description,)
//            }
//            print("Fetched Items: \(self.items)")
//        }
//    }
}
