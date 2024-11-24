//
//  AddExpenseViewModel.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/20/24.
//

import Foundation
import Alamofire

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
    func addAndUploadReceipt(imageURL: URL)
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
                let result = try await addExpense()
                print(result)
                await MainActor.run {
                    isLoading = false
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
    
    func addAndUploadReceipt(imageURL: URL) {
        uploadImageToAzureBlob(imageURL: imageURL)
    }
    
    private func addReceipt() async throws {
        // TODO: Add receipt to MySQL database
    }
    
    private func uploadImageToAzureBlob(imageURL: URL) {
        // Your Azure Blob Storage SAS URL
        let blobURL = "https://expensinatorstorage.blob.core.windows.net/expensinator-receipts"
        
        do {
            // Convert the image to Data
            let imageData = try Data(contentsOf: imageURL)
            
            // Use Alamofire to upload the image
            AF.upload(
                imageData,
                to: blobURL,
                method: .put,
                headers: [
                    "x-ms-blob-type": "BlockBlob",
                    "Content-Type": "image/jpeg" // Adjust based on the image type
                ]
            )
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    print("Image uploaded successfully!")
                    self.uploadStatus = "Image uploaded successfully!"
                    
                case .failure(let error):
                    print("Upload failed: \(error.localizedDescription)")
                    self.uploadStatus = "Upload failed: \(error.localizedDescription)"
                }
            }
        } catch {
            print("Failed to read image data: \(error.localizedDescription)")
            uploadStatus = "Failed to read image data: \(error.localizedDescription)"
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

    // Function to add an expense
    private func addExpense() async throws -> String {
        guard let expense = createExpense() else {
            print("Invalid expense data.")
            throw CustomError.invalidExpenseData
        }
        
        // Define the URL of your cloud function
        let url = "https://FunctionAppCCB2.azurewebsites.net/api/add_expense"

        // Prepare the JSON encoder
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set to UTC
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        print("Right before encoding")

        // Convert the Expense object to JSON data
        let expenseData = try encoder.encode(expense)

        // Create a URLRequest
        var request = URLRequest(url: URL(string: url)!)
        request.method = .post
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = expenseData
        
        print("Right before sending request")

        // Use Alamofire's async request
        let dataTask = AF.request(request).serializingString()
        print("Right after sending request")

        // Await the response
        let response = await dataTask.response
        print("Right after awaiting response: ", response)

        // Check for errors
        if let error = response.error {
            print("Error when adding expense: \(error.localizedDescription)")
            throw error
        }

        // Check the status code
        guard let statusCode = response.response?.statusCode else {
            throw URLError(.badServerResponse)
        }
        print("Status code: \(statusCode)")

        if statusCode == 201 {
            // Expense added successfully
            print("Expense added successfully.")
            await MainActor.run {
                NotificationCenter.default.post(name: .didAddExpense, object: nil)
                showSuccessAlert = true
            }
            return "Expense added successfully."
        } else {
            // Handle different status codes and errors
            print("An error occurred. Status code: \(statusCode)")
            let serverMessage = response.value ?? "An error occurred."
            throw NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: serverMessage])
        }
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
