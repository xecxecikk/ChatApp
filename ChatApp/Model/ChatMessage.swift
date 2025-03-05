//
//  ChatMessage.swift
//  ChatApp
//
//  Created by XECE on 9.03.2025.
//

import Foundation
struct ChatMessage {
    let inboxKey: String
    let senderUid: String
    let senderName: String
    let senderPhotoUrl: String
    let recipientUid: String
    let message: String
    let timestamp: TimeInterval
    let lastMessage: String
    
    init(dictionary: [String: Any]) {
        self.inboxKey = dictionary["inboxKey"] as? String ?? ""
        self.senderUid = dictionary["senderUid"] as? String ?? ""
        self.senderName = dictionary["senderName"] as? String ?? "Bilinmeyen"
        self.senderPhotoUrl = dictionary["senderPhotoUrl"] as? String ?? ""
        self.recipientUid = dictionary["recipientUid"] as? String ?? ""
        self.message = dictionary["message"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? TimeInterval ?? 0
        self.lastMessage = dictionary["lastMessage"] as? String ?? "Mesaj yok"
    }
    
}
