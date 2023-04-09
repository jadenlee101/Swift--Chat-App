//
//  ChatLogView.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-04-06.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
}

struct ChatMessage : Identifiable {
    
    var id: String { documentId }
    
    let fromId , toId , text : String
    let documentId : String
    
    init(documentId : String, data : [String : Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}

class ChatLogViewModel : ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    
    
    let chatUser : ChatUser?
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        fetchMessages()
    }
    
    private func fetchMessages(){
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else {return}
        guard let toId = chatUser?.uid else {return}
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .addSnapshotListener{querySnapshot, err in
                if let err = err {
                    self.errorMessage = "failed to listen for the mesage"
                    print(err)
                    return
                }
                
                querySnapshot?.documents.forEach({ querySnapshot in
                    let data = querySnapshot.data()
                    let docId = querySnapshot.documentID
                    let chatMessage = ChatMessage(documentId: docId, data: data)
                    self.chatMessages.append(chatMessage)
                    
                })
            }
            
        
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
        
        let messageData = [FirebaseConstants.fromId : fromId , FirebaseConstants.toId : toId , FirebaseConstants.text : self.chatText , "timeStamp" : Timestamp()] as [String : Any]
        
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
            ForEach(vm.chatMessages) { message in
            
                HStack{
                    Spacer()
                    HStack{
                        Text(message.text)
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
