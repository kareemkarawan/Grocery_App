//
//  ProfileView.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 20/02/2025.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @EnvironmentObject var session: UserSession
    @State private var isLoggedOut = false
    @State private var profileImage: UIImage? = nil
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        
                    }else{
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(minWidth: 80, maxWidth: 80)
                            .foregroundColor(.gray)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        if let username = session.currentUser?.username {
                            Text(username)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding()
                List {
                    Section {
                        NavigationLink(destination: Text("Settings")) {
                            Label("Settings", systemImage: "gearshape")
                        }
                        NavigationLink(destination: ProfileEditView()){
                            Label("Edit Profile", systemImage: "pencil")
                        }
                        Toggle(isOn: $isDarkMode) {
                            Label("Dark Mode", systemImage: "moon.fill")
                        }
                        NavigationLink(destination: Text("Privacy Policy")){
                            Label("Privacy Policy", systemImage: "lock.shield")
                        }
                        NavigationLink(destination: Text("Help")){
                            Label("Help", systemImage: "questionmark.circle")
                        }
                    }
                    Section {
                        Button(action: {logout()}) {
                            Label("Logout", systemImage: "power")
                                .foregroundColor(.red)
                        }.fullScreenCover(isPresented: $isLoggedOut) {
                            LoginView()
                        }
                    }
                }.preferredColorScheme(isDarkMode ? .dark : .light)
            }
        }
    }
        
    func logout(){
        do {
            try Auth.auth().signOut()
            session.currentUser = nil
            isLoggedOut = true
            
        }catch{
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProfileView()
}
