//
//  AddReceiptToExpenseConfirmationViewModel.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 12/5/24.
//

import Foundation
import AIReceiptScanner
import Observation
import SwiftUI

@Observable
class AddReceiptToExpenseConfirmationViewModel {
    let scanResult: SuccessScanResult
    var scanResultExpenses: [Expense] = []
    
    var date: Date
    var currencyCode: String {
        willSet {
            self.numberFormatter.currencyCode = newValue
        }
    }
    var expenses: [Expense] = []
    var isEdited: Bool {
        !(scanResult.receipt.date == date && expenses == scanResultExpenses)
    }
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    init(scanResult: SuccessScanResult) {
        self.scanResult = scanResult
        self.scanResultExpenses = scanResult.receipt.expenses
        self.date = scanResult.receipt.date ?? .now
        self.currencyCode = scanResult.receipt.currency ?? "EUR"
        self.expenses = self.scanResultExpenses // Initialize after scanResultExpenses is set
        self.numberFormatter.currencyCode = self.currencyCode
    }
    
    func save() {
        do {
            try AzureService.uploadImageToAzureBlob(image: scanResult.image, completion: { result in
                switch result {
                case .success(let url):
                    print("Uploaded image to Azure Blob: \(url)")
                    self.expenses.forEach { expense in
                        var _expense = expense
                        _expense.date = self.date
                        _expense.receiptUrl = url
                        Task {
                            do {
                                _ = try await AzureService.addExpense(_expense)
                                print("Added expense: \(_expense)")
                            } catch {
                                print(error)
                            }
                        }
                    }
                case .failure(let error):
                    print("Failed to upload image to Azure Blob: \(error)")
                    return
                }
            })
        } catch {
            print(error)
        }
    }
    
    func resetChanges() {
        self.expenses = self.scanResultExpenses
        self.date = scanResult.receipt.date ?? .now
        self.currencyCode = scanResult.receipt.currency ?? "EUR"
    }
    
}
