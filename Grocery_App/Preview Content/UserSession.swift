//
//  UserSession.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 20/02/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class UserSession: ObservableObject {
    @Published var currentUser: User?
    let DB = UserHandling()
    func fetchUser() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No authenticated user")
            return
        }
        DB.getUserbyID(userID: userID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.currentUser = user
                    print("User data loaded: \(user.username)")
                case .failure(let error):
                    print("Error fetching user: \(error)")
                }
            }
        }
    }
}
