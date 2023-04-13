//
//  ChatUser.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-04-05.
//

import FirebaseFirestoreSwift

struct ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    let uid, email, profileImageUrl: String
}
