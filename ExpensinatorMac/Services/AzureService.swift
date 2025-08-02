//
//  ExpenseService.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 12/5/24.
//

import Foundation
import Alamofire
import SwiftUI
import AppKit
import AIReceiptScanner

class AzureService {
    // MARK: - METHOD: GET -
    static func getExpenses() async throws -> [Expense] {
        // Replace with your actual Azure Function URL
        let route = NetworkRoutes.getExpenses
        guard let url = route.url else {
            print("Failed to create/find URL")
            throw ConfigurationError.nilObject
        }
        
        // Make an asynchronous request to the Azure Function
        let data = try await AF.request(url)
            .validate(statusCode: 200..<300)
            .serializingData()
            .value
        
        // Decode the JSON data into an array of Expense objects
        let decoder = JSONDecoder()
        
        // Decode JSON into Expense array
        let expenses = try decoder.decode([Expense].self, from: data)
        
        return expenses
    }
    
    struct UpdateRequest: Codable {
        let oldExpenseIDs: [Int]
        let newExpenses: [Expense]
    }

    static func updateExpenses(oldExpenseIDs: [Int], newExpenses: [Expense]) async throws -> String {
        let route = NetworkRoutes.updateExpenses
        guard let url = route.url else {
            print("Failed to create/find URL")
            throw ConfigurationError.nilObject
        }
        print("DEBUG: oldExpenseIDs: \(oldExpenseIDs)")
        print("DEBUG: newExpenses: \(newExpenses)")
        
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        // Create the encodable struct and encode it
        let updateRequest = UpdateRequest(oldExpenseIDs: oldExpenseIDs, newExpenses: newExpenses)
        let updateData = try encoder.encode(updateRequest)
        print("DEBUG: Update data: \(String(data: updateData, encoding: .utf8) ?? "nil")")
        
        var request = URLRequest(url: url)
        request.method = .put
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = updateData
        print("DEBUG: Request: \(request)")
        
        let dataTask = AF.request(request).serializingString()
        let response = await dataTask.response
        print("DEBUG: Response: \(response)")
        
        if let error = response.error {
            print("Error when updating expenses: \(error.localizedDescription)")
            throw error
        }
        
        guard let statusCode = response.response?.statusCode else {
            throw URLError(.badServerResponse)
        }
        print("DEBUG: Status code: \(statusCode)")
        
        if statusCode == 200 {
            print("Expenses updated successfully.")
            await MainActor.run {
                NotificationCenter.default.post(name: .didAddExpense, object: nil)
            }
            return "Expenses updated successfully."
        } else {
            print("An error occurred. Status code: \(statusCode)")
            let serverMessage = response.value ?? "An error occurred."
            throw NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: serverMessage])
        }
    }


    
    
    // Function to add an expense
    static func addExpense(_ expense: Expense) async throws -> String {
        // Define the URL of your cloud function
        let route = NetworkRoutes.addExpense
        guard let url = route.url else {
            print("Failed to create/find URL")
            throw ConfigurationError.nilObject
        }

        // Prepare the JSON encoder
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set to UTC
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        // Convert the Expense object to JSON data
        let expenseData = try encoder.encode(expense)

        // Create a URLRequest
        var request = URLRequest(url: url)
        request.method = .post
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = expenseData

        // Use Alamofire's async request
        let dataTask = AF.request(request).serializingString()

        // Await the response
        let response = await dataTask.response

        // Check for errors
        if let error = response.error {
            print("Error when adding expense: \(error.localizedDescription)")
            throw error
        }

        // Check the status code
        guard let statusCode = response.response?.statusCode else {
            throw URLError(.badServerResponse)
        }

        if statusCode == 201 {
            // Expense added successfully
            print("Expense added successfully. ")
            await MainActor.run {
                NotificationCenter.default.post(name: .didAddExpense, object: nil)
                
            }
            return "Expense added successfully."
        } else {
            // Handle different status codes and errors
            print("An error occurred. Status code: \(statusCode)")
            let serverMessage = response.value ?? "An error occurred."
            throw NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: serverMessage])
        }
    }
    
    static func deleteExpenses(_ expenses: [Expense]) async throws -> String {
        let route = NetworkRoutes.deleteExpenses
        guard let url = route.url else {
            print("Failed to create/find URL")
            throw ConfigurationError.nilObject
        }
        
        // Prepare the JSON encoder
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set to UTC
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        // Convert the Expense object to JSON data
        let expenseData = try encoder.encode(expenses)
        
        // Create a URLRequest
        var request = URLRequest(url: url)
        request.method = .delete
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = expenseData
        
        // Use Alamofire's async request
        let dataTask = AF.request(request).serializingString()
        
        // Await the response
        let response = await dataTask.response
        
        // Check for errors
        if let error = response.error {
            print("Error when deleting expenses: \(error.localizedDescription)")
            throw error
        }
        
        // Check the status code
        guard let statusCode = response.response?.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        if statusCode == 200 {
            // Expense added successfully
            print("Expenses deleted successfully.")
            await MainActor.run {
                NotificationCenter.default.post(name: .didDeleteExpense, object: nil)
            }
            return "Expenses deleted successfully."
        } else {
            // Handle different status codes and errors
            print("An error occurred. Status code: \(statusCode)")
            let serverMessage = response.value ?? "An error occurred."
            throw NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: serverMessage])
        }
    }
    
    static func uploadImageToAzureBlob(image: ReceiptImage, completion: @escaping (Result<String, Error>) -> Void) throws {
        let route = NetworkRoutes.addReceiptToBlob
        guard let url = route.url else {
            print("Failed to create/find URL")
            throw ConfigurationError.nilObject
        }

        guard let imageData = image.tiffRepresentation else {
            print("Failed to get image data")
            return
        }

        AF.upload(
            imageData,
            to: url,
            method: .post,
            headers: [
                "Content-Type": "image/png"
            ]
        )
        .validate()
        .responseDecodable(of: UploadResponse.self) { response in
            switch response.result {
            case .success(let uploadResponse):
                print("Image uploaded successfully, URL: \(uploadResponse.blobUrl)")
                completion(.success(uploadResponse.blobUrl))
            case .failure(let error):
                print("Upload failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }



    
//    
//    static func uploadImageToAzureBlob(imageURL: URL) -> Void {
//        // Your Azure Blob Storage SAS URL
//        let blobURL = "https://expensinatorstorage.blob.core.windows.net/expensinator-receipts"
//        
//        // Get image data
//        let imageData: Data
//        do {
//            // Convert the image to Data
//            imageData = try Data(contentsOf: imageURL)
//        } catch {
//            print("Failed to read image data: \(error.localizedDescription)")
//            return
//        }
//        
//        // Use Alamofire to upload the image. TODO: get the url from blob and use it to add entries.
//        AF.upload(
//            imageData,
//            to: blobURL,
//            method: .put,
//            headers: [
//                "x-ms-blob-type": "BlockBlob",
//                "Content-Type": "image/jpeg" // Adjust based on the image type
//            ]
//        )
//        .validate()
//        .response { response in
//            switch response.result {
//            case .success:
//                print("Image uploaded successfully!")
//            case .failure(let error):
//                print("Upload failed: \(error.localizedDescription)")
//            }
//        }
//        
//    }
//    
}

public extension ReceiptImage {
    var base64: String? {
        // Attempt to get a TIFF representation of the image
        guard let tiffData = self.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        
        // Convert to PNG or JPEG. Adjust the properties for JPEG as needed.
        // For PNG:
        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            return nil
        }
        
        // Convert the image data to Base64 string
        let base64String = pngData.base64EncodedString()
        return base64String
    }
}

extension NSImage {
    var pngData: Data? {
        guard let tiffData = self.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmapRep.representation(using: .png, properties: [:])
    }
}

extension NSImage {
    var jpegData: Data? {
        guard let tiffData = self.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmapRep.representation(using: .jpeg, properties: [:])
    }
}

