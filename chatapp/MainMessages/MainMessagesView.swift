//
//  MainMessagesView.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-04-04.
//

import SwiftUI
import SDWebImageSwiftUI


class MainMessaseViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser : ChatUser?
    
    init (){
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut =
            FirebaseManager.shared.auth.currentUser?.uid == nil 
        }
        fetchCurrentUser()
    }
    
    func fetchCurrentUser(){
        
        guard let uid = 
        FirebaseManager.shared.auth.currentUser?.uid else {return}
        self.errorMessage = "\(uid)"
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).getDocument{snapshot, err in
                if let err = err {
                    self.errorMessage = "Could not find user"
                    print("failed to fetch current user", err)
                    return
                }
                
                guard let data = snapshot?.data() else {
                    self.errorMessage = "no data found"
                    return
                }
                self.chatUser = .init(data: data)
               
            }
    }
    @Published var isUserCurrentlyLoggedOut = false
    
    func handleSignout () {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}

struct MainMessagesView: View {
    
    @State var shouldShowLogOut = false
    @State var shouldNavigateToChatLogView = false
    
    @ObservedObject private var vm = MainMessaseViewModel()
    
    var body: some View {
        NavigationView{
            //nav bar
            VStack{
                //Text("Current user id:  \(vm.chatUser?.email ?? "" )")
                customNavBar
                messagesView
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
                
            }
                .overlay(
                    newMessageButton, alignment: .bottom
                )
                .navigationBarHidden(true)
                
            }
        
        
    }
    
    private var customNavBar : some View {
        HStack(spacing: 14){
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)
            
            VStack (alignment: .leading, spacing: 4){
                Text("\(vm.chatUser?.email ?? "" )")
                    .font(.system(size: 24 , weight: .bold))
        
                
                HStack {
                    Text("Online")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.lightGray))
                    Circle()
                        .foregroundColor(Color(.green))
                        .frame(width: 10, height: 10)
                        
                }
            }
            Spacer()
            Button{
                shouldShowLogOut.toggle()
            }  label: {
                Image(systemName: "gear")
                    .foregroundColor(Color(.label))
                    .font(.system(size: 24, weight: .bold))
            }
            
        }
        .padding(.horizontal)
        .padding(.bottom)
        .actionSheet(isPresented: $shouldShowLogOut) {
            .init(title: Text("Settings"),
                  message:Text("What do you want to do?"),
                  buttons: [
                    .destructive(
                        Text("Sign out"),
                        action:{
                            print("signed out")
                            vm.handleSignout()
                            
                        }
                    ), .cancel()])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView(didCompleteLogin: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        }
    }
    
    @State var shouldShowNewMessageScreen = false
    
    @State var chatUser : ChatUser?
    
    private var newMessageButton : some View {
        Button{
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack (){
                Spacer()
                Text("+ New messages")
                    .font(.system(size: 16, weight: .bold))
                    
                Spacer()
            }
            .foregroundColor(Color.white)
            .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            NewMessageScreen(didSelectNewUser: {user in
                print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            })
            
        }
        
        //
    }

    
    private var messagesView : some View {
        ScrollView{
            ForEach(0..<10, id: \.self) { num in
                VStack{
                    NavigationLink{
                        Text("destination") }
                label: {
                    HStack (spacing: 16){
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1)
                            )
                        
                        VStack (alignment: .leading){
                            Text("UserName")
                            Text("message sent to the user")
                        }
                        Spacer()
                        
                        Text("22d")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    
                }
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
    }
    
    
}

struct ChatLogView : View {
    
    let chatUser : ChatUser?
    
    var body: some View {
        ScrollView{
            ForEach(0..<10) { nnum in
                Text("Test mesages")
            }
        }.navigationTitle(chatUser?.email ?? "")
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}
