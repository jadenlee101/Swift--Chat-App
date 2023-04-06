//
//  ChatLogView.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-04-06.
//

import SwiftUI

class ChatLogViewModel : ObservableObject {
    init(){
        
    }
    
    func handleSend(text: String){
        
    }
}

struct ChatLogView : View {
    
    @ObservedObject var vm = ChatLogViewModel()
    
    @State var chatText = ""
    let chatUser : ChatUser?
    
    var body: some View {
        ZStack{
            messagesView
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
                TextEditor(text: $chatText)
                    .opacity(chatText.isEmpty ? 0.5 : 1 )
            }
                .frame(height: 40)
           // TextField("Write something...", text: $chatText)
            Button{
                vm.handleSend(text: self.chatText)
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
        NavigationView{
            ChatLogView(chatUser: .init(data: ["uid": "real user", "email" : "giigke@gmail.com"]))
                
        }
    }
}
