//
//  ContentView.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-03-23.
//

import SwiftUI

struct ContentView: View {
    
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
                        
                    Button {
                        
                    } label: {
                    Image(systemName: "person.fill")
                            .font(.system(size: 64))
                            .padding()
                    }
                    
                    TextField("email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("password", text: $password)
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Spacer()
                            Text ("Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10 )
                            Spacer()
                        }.background(Color.blue)
                    }
                }.padding()
                
                
            }
            .navigationTitle("Create account")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
