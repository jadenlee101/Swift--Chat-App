//
//  ChatUser.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-04-05.
//

import Foundation

struct ChatUser {
    let uid, email, profileImageUrl : String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}
