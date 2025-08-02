//
//  AddExpenseViewModel.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/20/24.
//

import Foundation
import Alamofire
import AIReceiptScanner

protocol AddExpenseViewModelType: ObservableObject {
    var isLoading: Bool { get set }
    var description: String { get set }
    var merchat: String { get set }
    var amount: String { get set }
    var date: Date { get set }
    var categories: [Category] { get set }
    var selectedCategory: Category? { get set }
    var categoryId: Int { get set }
    var receiptUrl: String? { get set }
    var errorMessage: String? { get set }
    func addExpense()
}

class AddExpenseViewModel: AddExpenseViewModelType {
    @Published var isLoading = true
    @Published var description: String = ""
    @Published var merchat: String = ""
    @Published var amount: String = ""
    @Published var date = Date()
    @Published var categories: [Category] = []
    @Published var selectedCategory: Category?
    var categoryId: Int {
        get {
            selectedCategory?.categoryId ?? 0
        }
        set {
            selectedCategory = categories.first { $0.categoryId == newValue }
        }
    }
    @Published var receiptUrl: String?
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    @Published var uploadStatus = ""
    
    init() {
        Task {
            await setCategories()
            await MainActor.run { isLoading = false }
        }
    }
    
    func addExpense() {
        Task {
            await MainActor.run { isLoading = true }
            do {
                print("Adding expense...")
                guard let expense = createExpense() else {
                    print("Invalid expense data.")
                    throw CustomError.invalidExpenseData
                }
                let result = try await AzureService.addExpense(expense)
                print(result)
                await MainActor.run {
                    isLoading = false
                    showSuccessAlert = true
                }
            } catch let error as CustomError {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func createExpense() -> Expense? {
        guard let amount = Decimal(string: amount) else {
            print("Invalid amount.")
            return nil
        }
        return Expense(
            userId: 1,
            amount: amount,
            categoryId: categoryId,
            description: description,
            receiptUrl: receiptUrl,
            date: date
        )
    }
    
    private func setCategories() async {
        let categories = CategoryService.shared.categories
        await MainActor.run {
            self.categories = categories
            self.selectedCategory = categories.first
        }
    }
}


enum CustomError: Error {
    case invalidExpenseData
    
    var localizedDescription: String {
        switch self {
        case .invalidExpenseData:
            return "Invalid expense data. Please fill in all Fields"
        }
    }
}
