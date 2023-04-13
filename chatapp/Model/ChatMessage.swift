//
//  ChatMessage.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-04-13.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
}
