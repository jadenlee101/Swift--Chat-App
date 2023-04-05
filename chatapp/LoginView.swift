//
//  ContentView.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-03-23.
//

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseStorage
import FirebaseFirestore



struct LoginView: View {
    let didCompleteLogin: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var shouldShowImagePicker = false
    
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
                        shouldShowImagePicker.toggle()
                    } label: {
                        VStack{
                            if let image = self.image{
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 128, height: 128)
                                    .scaledToFill()
                                    .cornerRadius(64)
                                
                                
                            }
                                else {
                                    Image(systemName: "person.fill")
                                            .font(.system(size: 64))
                                            .padding()
                                            .foregroundColor(Color(.label))
                                }
                            
                        }
                        .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        
                                            
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
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil ) {
            ImagePicker(image: $image)
            
        }
        
    }
    @State var image: UIImage?
    
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
            self.didCompleteLogin()
        }
    }
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        if self.image == nil {
            self.loginStatusMessage = "You must select an image"
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, err in if let err = err {
                print("failed to create a new account", err)
                self.loginStatusMessage = "failed to create a new account \(err)"
                return
            }
            print("success user \(result?.user.uid ?? "")")
            self.loginStatusMessage = "success user \(result?.user.uid ?? "")"
            
            self.persistImageToStorage()
        }
        //print (email, password)
    }
    
    private func persistImageToStorage() {
        //let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else {return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {return}
        ref.putData(imageData,metadata: nil) { metadata, err in
            if let err = err {
                self.loginStatusMessage = " Failed to push image to storage: \( err )"
                return
            }
            ref.downloadURL{url , err in
                if let err = err {
                    self.loginStatusMessage = "Failed tot retrieve download URL: \(err)"
                    return
                    
                }
                
                self.loginStatusMessage = "Sucessfully stored image with url: \(url?.absoluteString ?? "")"
                
                guard let url = url else {return}
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    private func storeUserInformation(imageProfileUrl : URL){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{
            return
        }
        let userData = ["email" : self.email, "uid" : uid, "profileImageUrl" : imageProfileUrl.absoluteString ]
        FirebaseManager.shared.firestore.collection("users").document(uid).setData(userData){
            err in if let err = err {
                print(err)
                self.loginStatusMessage = "\(err)"
                return
            }
            print("success")
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLogin: {})
    }
}
