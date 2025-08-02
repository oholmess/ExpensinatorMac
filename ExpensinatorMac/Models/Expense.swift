//
//  Expense.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/20/24.
//

import Foundation

struct Expense: Identifiable, Codable, Equatable {
    var id: UUID = UUID()      // Use expenseId as the identifier
    var expenseId: Int?             // Optional because it may not be set initially
    var userId: Int
    var amount: Decimal
    var categoryId: Int
    var description: String
    var receiptUrl: String?
    var date: Date
    var createdAt: Date

    init(expenseId: Int? = nil, userId: Int, amount: Decimal, categoryId: Int, description: String, receiptUrl: String? = nil, date: Date) {
        self.expenseId = expenseId   // Initially nil; set after database insertion
        self.userId = userId
        self.amount = amount
        self.categoryId = categoryId
        self.description = description
        self.receiptUrl = receiptUrl
        self.date = date
        self.createdAt = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case expenseId, userId, amount, categoryId, description, receiptUrl, date, createdAt
    }

    // Custom initializer for Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        expenseId = try container.decodeIfPresent(Int.self, forKey: .expenseId)
        userId = try container.decode(Int.self, forKey: .userId)
        
        // Decode `amount` from String and convert to Decimal
        let amountString = try container.decode(String.self, forKey: .amount)
        guard let amountDecimal = Decimal(string: amountString) else {
            throw DecodingError.dataCorruptedError(forKey: .amount, in: container, debugDescription: "Amount is not a valid decimal")
        }
        amount = amountDecimal
        
        categoryId = try container.decode(Int.self, forKey: .categoryId)
        description = try container.decode(String.self, forKey: .description)
        receiptUrl = try container.decodeIfPresent(String.self, forKey: .receiptUrl)
        
        // Decode `date` and `createdAt` with custom formats
        let dateString = try container.decode(String.self, forKey: .date)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let parsedDate = dateFormatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date format is invalid")
        }
        date = parsedDate

        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let parsedCreatedAt = dateFormatter.date(from: createdAtString) else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "CreatedAt format is invalid")
        }
        createdAt = parsedCreatedAt
    }
}

extension Expense {
    // Sample default expenses
    enum DefaultExpenses {
        static var sample: [Expense] {
            [
                Expense(userId: 1, amount: 100.00, categoryId: 1, description: "Carrefour", date: Date()),
                Expense(userId: 1, amount: 1000.00, categoryId: 2, description: "Rent", date: Date()),
                Expense(userId: 1, amount: 50.00, categoryId: 3, description: "Internet", date: Date()),
                Expense(userId: 1, amount: 40.00, categoryId: 4, description: "Gas", date: Date()),
                Expense(userId: 1, amount: 100.00, categoryId: 5, description: "Car Insurance", date: Date()),
            ]
        }
    }
}
