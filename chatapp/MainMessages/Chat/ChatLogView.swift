//
//  ChatLogView.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-04-06.
//

import SwiftUI

struct ChatLogView : View {
    
    @State var chatText = ""
    let chatUser : ChatUser?
    
    var body: some View {
        VStack{
            ScrollView{
                ForEach(0..<10) { nnum in
                    
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
            
            HStack(spacing: 12){
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.darkGray))
                TextField("Write something...", text: $chatText)
                Button{
                    
                } label: {
                    Text("Send")
                }
                
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
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
