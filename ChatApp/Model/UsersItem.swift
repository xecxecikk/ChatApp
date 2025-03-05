//
//  User.swift
//  ChatApp
//
//  Created by XECE on 9.03.2025.
//

import Foundation

struct User {
    
    let uid: String
    let name: String
    let email: String
    let photoUrl: String

    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? "Bilinmeyen"
        self.email = dictionary["mail"] as? String ?? ""
        self.photoUrl = dictionary["photoUrl"] as? String ?? ""
    }
}
