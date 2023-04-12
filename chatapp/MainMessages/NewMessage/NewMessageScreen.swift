//
//  NewMessageScreen.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-04-05.
//

import SwiftUI
import SDWebImageSwiftUI


class CreateNewMessageViewModel : ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    init (){
        fetchAllUsers()
    }
    
    private func fetchAllUsers(){
        FirebaseManager.shared.firestore
            .collection("users")
            .getDocuments {
                documentSnapshot, err in
                if let err = err {
                    self.errorMessage = "failed to fetch"
                    print("failed to fetch users \(err)")
                    return
                }
                documentSnapshot?.documents.forEach({snapshot in
                    let data = snapshot.data()
                    self.users.append(.init(data: data))
                })
                self.errorMessage = "fetched success "
            }
    }
    
}

struct NewMessageScreen: View {
    
    let didSelectNewUser : (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        
        NavigationView{
            
            ScrollView {
                Text(vm.errorMessage)
                ForEach(vm.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    } label: {
                        
                        
                        HStack(spacing: 16){
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                            Text(user.email)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }
                        .padding(.horizontal)
                        Divider()
                    }
                }
            }.navigationTitle("New message")
                .toolbar{
                    ToolbarItemGroup (
                    placement: .navigationBarLeading
                    ) {
                        Button{
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }

                }
        }
    }
}

struct NewMessageScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}
