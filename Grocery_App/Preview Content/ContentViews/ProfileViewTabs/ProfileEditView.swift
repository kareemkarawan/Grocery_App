//
//  ProfileEditView.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 21/02/2025.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject var session: UserSession
    
    @State private var selectedImage: UIImage? = nil
    @State private var photoPickerItem: PhotosPickerItem? = nil
    
    @State private var userName: String = ""
    @State private var email: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let UH = UserHandling()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    VStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        }else{
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            VStack() {
                Text("User Name")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity ,alignment: .leading)
                    .padding(.horizontal)
                TextField("User Name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Text("Email")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity ,alignment: .leading)
                    .padding(.horizontal)
                TextField("Email ", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button(action: saveUserInfo) {
                    Text("Save Changes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .padding(.horizontal)
                }.padding(.vertical)
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear(perform: loadUserInfo)
        .navigationTitle("Edit Profile")
    }
    private func loadUserInfo() {
        if let currentUser = session.currentUser {
            userName = currentUser.username
            email = currentUser.email
        }
    }
    private func saveUserInfo() {
        guard !userName.isEmpty, !email.isEmpty else {
            return
        }
        session.currentUser?.username = userName
        session.currentUser?.email = email
        
        let newUser = User(id: session.currentUser?.id ?? "", username: session.currentUser?.username ?? "", email: session.currentUser?.email ?? "")
        UH.editUser(user: newUser) { success in
            if success {
                alertMessage = "User saved successfully"
            } else {
                alertMessage = "Failed to save user"
            }
            showAlert = true
        }
    }
}

#Preview {
    ProfileEditView()
}
