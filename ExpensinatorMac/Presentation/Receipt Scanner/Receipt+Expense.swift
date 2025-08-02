//
//  File.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 12/5/24.
//

import AIReceiptScanner
import Foundation

extension Receipt {
    var expenses: [Expense] {
        (items ?? []).compactMap { item in
            // Normalize the category name to handle case sensitivity and whitespace
            let normalizedCategoryName = item.category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            // Find the matching category ID
            let categoryId = categoryMapping.first { key, _ in
                key.lowercased() == normalizedCategoryName
            }?.value ?? 0 // Use 0 or another default ID if not found

            // Create the Expense instance
            return Expense(
                userId: 1,    // TODO: Replace with actual user ID
                amount: Decimal(item.price),
                categoryId: categoryId,
                description: "\(item.quantity > 1 ? "\(Int(item.quantity)) x " : "")\(item.name)",
                date: date ?? .now
            )
        }
    }
}

// Define the category mapping in your code
let categoryMapping: [String: Int] = [
    "Accounting and legal fees": 1,
    "Bank fees": 2,
    "Consultants and professional services": 3,
    "Depreciation": 4,
    "Employee benefits": 5,
    "Employee expenses": 6,
    "Entertainment": 7,
    "Food": 8,
    "Gifts": 9,
    "Health": 10,
    "Insurance": 11,
    "Interest": 12,
    "Learning": 13,
    "Licensing fees": 14,
    "Marketing": 15,
    "Membership fees": 16,
    "Office supplies": 17,
    "Payroll": 18,
    "Repairs": 19,
    "Rent": 20,
    "Rent or mortgage payments": 21,
    "Software": 22,
    "Tax": 23,
    "Travel": 24,
    "Utilities": 25
]

