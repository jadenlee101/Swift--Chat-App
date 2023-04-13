//
//  MainMessagesView.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-04-04.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth

class MainMessageViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser : ChatUser?
    
    init (){
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut =
            FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    @Published var recentMessages = [RecentMessage]()
    
    private var firestoreListener: ListenerRegistration?
    
     func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
         
         firestoreListener?.remove()
         self.recentMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    do {
                        if let rm = try? change.document.data(as: RecentMessage.self) {
                            self.recentMessages.insert(rm, at: 0)
                        }

                    } catch{
                        print(error)
                    }
                   // self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
                    
                    
                    //self.recentMessages.append()
                })
            }
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
    
    @ObservedObject private var vm = MainMessageViewModel()
    
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
                self.vm.fetchRecentMessages()
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
            ForEach(vm.recentMessages) { recentMessage in
                VStack{
                    NavigationLink{
                        Text("destination") }
                label: {
                    HStack (spacing: 16){
                        WebImage(url: URL(string:
                                            recentMessage.profileImageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipped()
                        .cornerRadius(64)
//                        .overlay(RoundedRectangle(cornerSize: 64)
//                            .stroke(Color.black, lineWidth: 1))
//                        .shadow(radius: 5)
                        //                        Image(systemName: "person.fill")
                        //                            .font(.system(size: 32))
                        //                            .padding(8)
                        //                            .overlay(RoundedRectangle(cornerRadius: 44)
                        //                                .stroke(Color(.label), lineWidth: 1)
                        //                            )
                        
                        VStack (alignment: .leading, spacing: 8){
                            Text(recentMessage.userName)
                                .font(.system(size: 18))
                                .foregroundColor(Color(.label))
                                .multilineTextAlignment(.leading)
                            Text(recentMessage.text)
                                .font(.system(size: 14))
                                .foregroundColor(Color(.darkGray))
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        
                        Text(recentMessage.timeAgo)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(.label))
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



struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}
