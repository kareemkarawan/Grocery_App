//
//  Grocery_AppApp.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 27/01/2025.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore

@main
struct Grocery_AppApp: App {
    @StateObject var session = UserSession()
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(session)
        }
    }
}
