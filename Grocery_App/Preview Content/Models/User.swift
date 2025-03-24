//
//  User.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 18/02/2025.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var email: String
    
    init(id: String, username: String, email: String) {
            self.id = id
            self.username = username
            self.email = email
        }
}
