//
//  ContentView.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-03-23.
//

import SwiftUI

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
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
                
                
                
            }
            .navigationTitle(isLoginMode ? "Login" : "Create account")
            .background(Color(.init(white: 0, alpha: 0.05)))
        }
        
    }
    
    private func handleAction() {
        if isLoginMode {
            print("Should log into the firebase")
        } else {
            print("Register a new account inside of Firebase Auth")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
