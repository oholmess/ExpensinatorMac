//
//  HomePageViewModel.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/20/24.
//

import Foundation
import Alamofire

protocol HomePageViewModelType: ObservableObject {
    func getExpenses() async
}

class HomePageViewModel: HomePageViewModelType {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var expenses: [Expense] = []
    @Published var categories: [Category] = []
    @Published var selectedExpenses: [Expense] = []
    
    init() {
        Task {
            await setCategories()
            await getExpenses()
        }
    }

    func getExpenses() async {
        await MainActor.run { isLoading = true }
        do {
            // Make an asynchronous request to the Azure Function
            let expenses = try await AzureService.getExpenses()
            await MainActor.run {
                self.expenses = expenses
                isLoading = false
            }
        } catch let error as AFError {
            await MainActor.run {
                isLoading = false
                errorMessage = "Error fetching expenses. Please try again later."
            }
            print("AFError: Error fetching expenses: \(error.localizedDescription)")
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Error fetching expenses. Please try again later."
            }
            print("Error fetching expenses: \(error.localizedDescription)")
        }
    }
    
    func deleteExpenses() async {
        await MainActor.run { isLoading = true }
        do {
            _ = try await AzureService.deleteExpenses(selectedExpenses)
        } catch let error as AFError {
            await MainActor.run {
                isLoading = false
                errorMessage = "Error deleting expenses. Please try again later."
            }
            print("AFError: Error deleting expenses: \(error.localizedDescription)")
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Error deleting expenses. Please try again later."
            }
            print("Error deleting expenses: \(error.localizedDescription)")
        }
    }
    
    func getTotalSpent() -> Decimal {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    func saveEditedExpenses(oldExpenseIDs: [Int], newExpenses: [Expense]) async {
        await MainActor.run { isLoading = true }
        do {
            _ = try await AzureService.updateExpenses(oldExpenseIDs: oldExpenseIDs, newExpenses: newExpenses)
        } catch let error as AFError {
            await MainActor.run {
                isLoading = false
                errorMessage = "Error saving edited expenses. Please try again later."
            }
            print("AFError: Error saving edited expenses: \(error.localizedDescription)")
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Error saving edited expenses. Please try again later."
            }
            print("Error saving edited expenses: \(error.localizedDescription)")
        }
    }
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        return formatter
    }()
    
    private func setCategories() async {
        let categories = CategoryService.shared.categories
        await MainActor.run {
            self.categories = categories
        }
    }
}

