//
//  UserHandling.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 18/02/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


public class UserHandling {
    let DB = DatabaseHandling()
    let df = Firestore.firestore()
    
    func addNewUser(newUser: User) {
        
        DB.addDocument(toCollection: "Users", document: newUser, documentID: newUser.id) { result in
            switch result {
                case .success(let docID):
                print("User added successfully with ID: \(docID)")
            case .failure(let error):
                print("Error adding user: \(error.localizedDescription)")
                
            }
        }
    }
    func getUserbyID(userID: String, completion: @escaping (Result<User, Error>) -> Void) {
        DB.getDocumentbyID(fromCollection: "Users", documentID: userID, completion: completion)
    }
    func editUser(user: User, completion: @escaping (Bool) -> Void) {
        DB.editById(inCollection: "Users", object: user) { result in
            switch result {
            case .success(_):
                print("User edited successfully")
            case .failure(let error):
                print("Error editing user: \(error.localizedDescription)")
            }
        }
    }
    
    func getAllGroceryLists(userId: String, completion: @escaping ([GroceryList]?) -> Void) {
        let db = Firestore.firestore()
        db.collection("Users").document(userId).collection("groceryLists")
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    completion(nil)
                    return
                }
                let groceryLists = documents.compactMap { try? $0.data(as: GroceryList.self)}
                completion(groceryLists)
            }
    }
    
    func addGroceryList(for userId: String, listName: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let newListRef = db.collection("Users").document(userId).collection("groceryLists").document()
        let newGroceryList = GroceryList(
            id: newListRef.documentID,
            name: listName,
            isMainList: false
        )
        do {
            try newListRef.setData(from: newGroceryList) { error in
                completion(error == nil)
            }
        } catch {
            completion(false)
        }
    }
    
    func deleteGroceryList(for userId: String, listId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("Users").document(userId).collection("groceryLists").document(listId)
            .delete { error in
                completion(error == nil)
            }
    }
    
    func editGroceryListName(for userId: String, groceryList: GroceryList, completion: @escaping (Bool) -> Void) {
        guard let listId = groceryList.id else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let listRef = db.collection("Users").document(userId).collection("groceryLists").document(listId)
        do {
            try listRef.setData(from: groceryList, merge: true) { error in
                completion(error == nil)
            }
        } catch {
            completion(false)
        }
    }
    func addItemToList(for userId: String, item: Item, listId: String, completion: @escaping (Bool) -> Void) {
        let listRef = df.collection("Users").document(userId).collection("groceryLists").document(listId)
        
        let newItem: [String: Any] = [
            "product_name": item.product_name ?? "",
            "category": item.category ?? "",
            "image_url": item.image_url ?? "",
            "price": item.price ?? "",
            "store": item.store ?? ""
        ]
        
        listRef.collection("items").addDocument(data: newItem) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(false)
            } else {
                completion(true)
            }
            
        }
    }
    
    func deleteItemFromList(for userId: String, listId: String, itemId: String, completion: @escaping (Bool) -> Void) {
        let listRef = df.collection("Users").document(userId).collection("groceryLists").document(listId).collection("items").document(itemId)
        listRef.delete { error in
            if let error = error {
                print("Error deleting item: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func getGroceryItemsFromList(for userId: String, listId: String, completion: @escaping ([Item]) -> Void) {
        let listRef = df.collection("Users").document(userId).collection("groceryLists").document(listId)
        
        listRef.collection("items").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion([])
                return
            }
            var items: [Item] = []
            for document in querySnapshot?.documents ?? [] {
                do {
                    let item = try document.data(as: Item.self)
                    items.append(item)
                } catch {
                    print("Error decoding item: \(error)")
                }
            }
            completion(items)
        }
    }
}
