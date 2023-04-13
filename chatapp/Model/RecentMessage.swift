//
//  RecentMessage.swift
//  chatapp
//
//  Created by Jaden Lee on 2023-04-12.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct RecentMessage : Codable, Identifiable {
    
    @DocumentID var id: String?
//    var id: String {documentId}
    
//    let documentId : String
    let text,email: String
    let fromId , toId : String
    let profileImageUrl : String
    let timestamp : Date
    
    var userName: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAgo : String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
        
    }
    
//    init(documentId: String, data: [String : Any]) {
//        self.documentId = documentId
//        self.text = data["text"] as? String ?? ""
//        self.fromId = data["fromId"] as? String ?? ""
//        self.toId = data["toId"] as? String ?? ""
//        self.email = data["email"] as? String ?? ""
//        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
//        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
//    }
}
