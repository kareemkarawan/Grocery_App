//
//  StoreHandler.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 04/03/2025.
//

import Foundation

class StoreHandler: ObservableObject {
    @Published var stores: [Stores] = []
    var dh = DatabaseHandling()
    
    init() {
        fetchStores(from: "Stores")
    }
    
    func fetchStores(from collection: String) {
        dh.getAllDocumentsInCollection(fromCollection: collection) { (result: Result<[Stores], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let items = data as? [Stores] {
                        self.stores = items
                        print("Fetched Stores: \(items)")
                    }
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            }
        }
    }
}
