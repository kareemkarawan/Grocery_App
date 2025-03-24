//
//  GroceryList.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 21/02/2025.
//

import Foundation
import FirebaseFirestore

class GroceryList: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var isMainList: Bool
    var items: [Item]
        
    init(name: String, isMainList: Bool) {
        self.name = name
        self.items = []
        self.isMainList = isMainList
    }
    
    init(id: String, name: String, isMainList: Bool) {
        self.name = name
        self.items = []
        self.isMainList = isMainList
    }
}
