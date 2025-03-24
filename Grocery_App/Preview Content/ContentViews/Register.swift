//
//  Register.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 17/02/2025.
//

import SwiftUI
import FirebaseAuth

struct Register: View {
    @State private var isRegistered = false
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""
    let DB = UserHandling()
    var body: some View {
        NavigationStack {
            ZStack  {
                Image("RegisterBackground")
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 7)
                VStack(spacing: 20)  {
                    Text("Register")
                        .foregroundColor(.white)
                    TextField("  Email", text: $email)
                        .autocapitalization(.none)
                        .frame(width: 300, height: 35)
                        .background(Color.white)
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                    TextField("  Username", text: $username)
                        .autocapitalization(.none)
                        .frame(width: 300, height: 35)
                        .background(Color.white)
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                    SecureField("  Password", text: $password)
                        .autocapitalization(.none)
                        .frame(width: 300, height: 35)
                        .background(Color.white)
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                    Button(action: {register()}){
                        Text("Register")
                            .padding(9)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.padding().navigationDestination(isPresented: $isRegistered){LoginView()}
                }
            }
            
        }
    }
    func register() {
        Auth.auth().createUser(withEmail: email, password: password){ (result, error) in
            if error != nil{
                print(error?.localizedDescription ?? "")
            }
            if let user = result?.user{
                let newUser = User(id: user.uid, username: self.username, email: self.email)
                DB.addNewUser(newUser: newUser)
                print("success")
                isRegistered = true
            }
        }
    }
}

#Preview {
    Register()
}
