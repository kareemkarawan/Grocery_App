//
//  MainView.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 20/02/2025.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @EnvironmentObject var session: UserSession
    @State private var isLoggedIn = false
    var body: some View {
        VStack(spacing: 0) {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text("Home")
                    }
                ListMainView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text("My Lists")
                    }
                FavoritesView()
                    .tabItem {
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text("Favorites")
                    }
                DealsAndCompView()
                    .tabItem {
                        Image(systemName: "dollarsign.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text("Deals & Comp")
                    }
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text("Profile")
                    }
                
            }
        }
    }
}
#Preview {
    MainView()
}


struct TabButton: View {
    var icon: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(isSelected ? .green : .gray)
        }
    }
}
