//
//  DatabaseHandling.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 18/02/2025.
//

import Foundation
import FirebaseFirestore

public class DatabaseHandling: ObservableObject {
    private var db = Firestore.firestore()
    
    func addDocument<T: Encodable>(toCollection collection: String, document: T, documentID: String? = nil, completion: @escaping (Result<String, Error>) -> Void ) {
        let collectionRef = db.collection(collection)
        
        let documentRef = documentID != nil ? collectionRef.document(documentID!) : collectionRef.document()
        
        do {
            let data = try Firestore.Encoder().encode(document)
            documentRef.setData(data) {error in
                if let error = error{
                    completion(.failure(error))
                }else{
                    completion(.success(documentRef.documentID))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func getAllDocumentsInCollection<T: Decodable>(fromCollection collection: String, completion: @escaping (Result<[T], Error>) -> Void ) {
        let db = Firestore.firestore()
        
        db.collection(collection).getDocuments() { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = querySnapshot?.documents else {
                completion(.success([]))
                return
            }
            do {
                let decodedDocuments = try documents.map { try $0.data(as: T.self)}
                completion(.success(decodedDocuments))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func getDocumentbyID<T: Decodable>(fromCollection collection: String, documentID: String, completion: @escaping (Result<T, Error>) -> Void ) {
        let db = Firestore.firestore()
        let docRef = db.collection(collection).document(documentID)
        
        docRef.getDocument() { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found"])))
                return
            }
            do {
                let data = try document.data(as: T.self)
                completion(.success(data))
            }catch{
                completion(.failure(error))
            }
        }
        
    }
    
    func editById<T: Codable & Identifiable>(inCollection collection: String, object: T, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let documentID = object.id as? String else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid ID"])))
            return
        }
        do {
            let data = try Firestore.Encoder().encode(object)
            db.collection(collection).document(documentID).setData(data, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchItemFromBarcode(by barcode: String, completion: @escaping(Result<Item, Error>) -> Void) {
        db.collection("items").document(barcode).getDocument { (document, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let document = document, document.exists {
                do {
                    let product = try document.data(as: Item.self)
                    completion(.success(product))
                    return
                } catch {
                    print(error)
                }
            } else {
                print("Product not found!")
            }
        }
    }
    
    func fetchDeals(completion: @escaping (Result<[Item], Error>) -> Void) {
            db.collection("items")
                .whereField("discount", isGreaterThan: 0) // Assuming 'discount' field exists
                .getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    let items = snapshot?.documents.compactMap { document -> Item? in
                        try? document.data(as: Item.self)
                    } ?? []
                    completion(.success(items))
                }
        }
    
    func checkIfFavorite(for userId: String, itemId: String, completion: @escaping (Bool) -> Void) {
        db.collection("Users").document(userId).collection("Favorites").document(itemId).getDocument { document, error in
            if let document = document, document.exists {
                let favorite = true
                completion(favorite)
                return
            } else {
                let favorite = false
                completion(favorite)
                return
            }
        }
    }
    
    func toggleFavorite(for userId: String, item: Item, isFavorite: Bool, completion: @escaping (Bool) -> Void) {
        let favoriteRef = db.collection("Users").document(userId).collection("Favorites").document(item.id ?? "")
        
        if isFavorite {
            favoriteRef.delete { error in
                if error == nil {
                    let isFavorite = false
                    completion(isFavorite)
                    return
                }
            }
        } else {
            do {
                try favoriteRef.setData(from: item) { error in
                    if error == nil {
                        let isFavorite = true
                        completion(isFavorite)
                        return
                        
                    }
                }
            } catch {
                print("Error adding to favorites: \(error)")
            }
        }
    }
    
    func fetchFavorites(for userId: String, completion: @escaping ([Item]) -> Void) {
        db.collection("Users").document(userId).collection("Favorites").getDocuments { snapshot, error in
            if let error = error {
                print("Error loading favorites: \(error)")
                completion([])
            } else if let documents = snapshot?.documents {
                let favoriteItems = documents.compactMap { doc in
                    try? doc.data(as: Item.self)
                }
                completion(favoriteItems)
                return
            }
        }
    }
    
    func removeFromFavorites(for userId:String, itemId: String, completion: @escaping (Bool) -> Void) {
        db.collection("Users").document(userId).collection("Favorites").document(itemId).delete() { error in
            if let error = error {
                print("Error removing item from favorites: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
