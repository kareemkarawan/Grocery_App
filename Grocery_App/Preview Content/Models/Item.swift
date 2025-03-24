//
//  Item.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 10/02/2025.
//

import Foundation
import FirebaseFirestore

class Item: Identifiable, Codable {
    @DocumentID var id: String?
    var product_name: String?
    var description: String?
    var category: String?
    var store: String?
    var price: String?
    var image_url: String?
    
    init(product_name: String?, description: String?, category: String?, store: String?, price: String?, image_url: String?) {
            self.product_name = product_name
            self.description = description
            self.category = category
            self.store = store
            self.price = price
            self.image_url = image_url
        }
}
