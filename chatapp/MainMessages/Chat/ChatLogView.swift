//
//  ChatLogView.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-04-06.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ChatLogViewModel : ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    let chatUser : ChatUser?
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
    }
    
    func handleSend(){
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        guard let toId = chatUser?.uid else {return}
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = ["fromId" : fromId , "toId" : toId , "text" : self.chatText , "timeStamp" : Timestamp()] as [String : Any]
        
        document.setData(messageData) { err in
            if let err = err  {
                self.errorMessage = "failed to store message into Firestore\(err)"
                return
            }
        }
        
        let recipientdocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientdocument.setData(messageData) { err in
            if let err = err  {
                self.errorMessage = "failed to store message into Firestore\(err)"
                return
            }
            self.chatText = ""
            
        }
    }
}

struct ChatLogView : View {
    
    let chatUser : ChatUser?
    
    init(chatUser : ChatUser?){
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    @ObservedObject var vm : ChatLogViewModel
    
    var body: some View {
        ZStack{
            messagesView
            Text(vm.errorMessage)
            VStack{
                Spacer()
                chatBottomBar
                    .background(Color.white.ignoresSafeArea())
            }
            
            
            
        }
    }
    
    private var messagesView : some View {
        ScrollView{
            ForEach(0..<15) { num in
                
                HStack{
                    Spacer()
                    HStack{
                        Text("Test mesages")
                            .foregroundColor(Color.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 6)
            }
            HStack{
                Spacer()
                
            }
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.init(white: 0.95, alpha: 1)))
        .safeAreaInset(edge: .bottom){
            chatBottomBar
                .background(Color(.systemBackground).ignoresSafeArea())
        }
    }
    
    private var chatBottomBar : some View {
        HStack(spacing: 12){
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            
            ZStack{
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1 )
            }
                .frame(height: 40)
           // TextField("Write something...", text: $chatText)
            Button{
                vm.handleSend()
            } label: {
                Text("Send")
            }
            
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
        
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Write something...")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}
