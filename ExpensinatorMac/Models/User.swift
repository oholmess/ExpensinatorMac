//
//  User.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/21/24.
//

import Foundation

struct User {
    var id = UUID()
    var userId: UUID
    var name: String
    
    init(userId: UUID, name: String) {
        self.userId = userId
        self.name = name
    }
}
