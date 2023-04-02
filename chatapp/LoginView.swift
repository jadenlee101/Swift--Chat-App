//
//  ContentView.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-03-23.
//

import SwiftUI
import FirebaseAuth
import Firebase

class FirebaseManager : NSObject {
    let auth: Auth
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        super.init()
    }
    
}

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
   //init() {
    //    FirebaseApp.configure()
    //}
    
    var body: some View {
        

        
        NavigationView {
            ScrollView {
                VStack{
                    Picker(selection: $isLoginMode, label: Text("picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                    Button {
                        
                    } label: {
                    Image(systemName: "person.fill")
                            .font(.system(size: 64))
                            .padding()
                    }
                    }
                    TextField("email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(Color.white)
                        
                    SecureField("password", text: $password)
                        .padding(12)
                        .background(Color.white)
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text (isLoginMode ? "Login" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10 )
                            
                            Spacer()
                        }.background(Color.blue)
                    }
                }
                .padding()
                Text (self.loginStatusMessage)
                    .foregroundColor(.red)
                
                
                
            }
            .navigationTitle(isLoginMode ? "Login" : "Create account")
            .background(Color(.init(white: 0, alpha: 0.05)))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    private func handleAction() {
        if isLoginMode {
            print("Should log into the firebase")
            loginUser()
        } else {
            print("Register a new account inside of Firebase Auth.")
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
            result, err in if let err = err {
                print("failed to loggin in user", err)
                self.loginStatusMessage = "failed to loggin user \(err)"
                return
            }
            print("success user login \(result?.user.uid ?? "")")
            self.loginStatusMessage = "success user login \(result?.user.uid ?? "")"
        }
    }
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, err in if let err = err {
                print("failed to create a new account", err)
                self.loginStatusMessage = "failed to create a new account \(err)"
                return
            }
            print("success user \(result?.user.uid ?? "")")
            self.loginStatusMessage = "success user \(result?.user.uid ?? "")"
        }
        //print (email, password)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
