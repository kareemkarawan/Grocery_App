//
//  Stores.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 26/02/2025.
//

import Foundation
import FirebaseFirestore

class Stores: Identifiable, Codable {
    @DocumentID var id: String?
    var Name: String?
    var imageURL: String?
}
