//
//  Receipt.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/21/24.
//

import Foundation

struct Receipt {
    var id = UUID()
    var receiptId: UUID
    var expenseId: UUID
    var receiptUrl: URL
    var createdAt: Date
    
    init(receiptId: UUID, expenseId: UUID, receiptUrl: URL, createdAt: Date) {
        self.receiptId = receiptId
        self.expenseId = expenseId
        self.receiptUrl = receiptUrl
        self.createdAt = createdAt
    }
}
