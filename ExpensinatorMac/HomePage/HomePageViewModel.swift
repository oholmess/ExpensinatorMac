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

import PythonKit

class HomePageViewModel: HomePageViewModelType {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var expenses: [Expense] = []
    @Published var categories: [Category] = []
    
    init() {
        Task {
            await setCategories()
            await getExpenses()
        }
    }

    func getExpenses() async {
        await MainActor.run {
            isLoading = true
        }
        // Replace with your actual Azure Function URL
        let url = "https://FunctionAppCCB2.azurewebsites.net/api/get_expenses"
        
        do {
            // Make an asynchronous request to the Azure Function
            let data = try await AF.request(url)
                .validate(statusCode: 200..<300)
                .serializingData()
                .value
            
            // Decode the JSON data into an array of Expense objects
            let decoder = JSONDecoder()
            
            // Decode JSON into Expense array
            let expenses = try decoder.decode([Expense].self, from: data)
            
            await MainActor.run {
                self.expenses = expenses
                isLoading = false
            }
            print("Expenses: ", expenses.map { $0.description })
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
    
    private func setCategories() async {
        let categories = CategoryService.shared.categories
        await MainActor.run {
            self.categories = categories
        }
    }
}

