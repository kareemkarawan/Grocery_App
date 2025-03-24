//
//  LoginView.swift
//  Grocery_App
//
//  Created by Kareem Karawan on 20/02/2025.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var session: UserSession
    @State private var isLoggedin = false;
    @State var email = "kkarawan9@gmail.com"
    @State var password = "123456"
    var body: some View {
        NavigationStack{
            ZStack {
                Image("LoginBackground")
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 7)
                
                VStack(spacing: 20){
                    Text("Login")
                        .foregroundColor(.white)
                    TextField("  Email", text: $email)
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
                    HStack{
                        Button(action: { login() }){
                            Text("Login")
                                .padding(9)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        NavigationLink(destination: Register()){
                            Text("Sign Up")
                                .padding(9)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)   
                        }
                    }
                }
                .padding()
                .fullScreenCover(isPresented: $isLoggedin) {
                    MainView()
                }
            }
        }
    }
    func login(){
        Auth.auth().signIn(withEmail: email, password: password){ (result, error) in
            if error != nil{
                print(error?.localizedDescription ?? "")
            }else{
                print("success")
                isLoggedin = true
                session.fetchUser()
            }
        }
    }
}
#Preview {
    LoginView()
}
