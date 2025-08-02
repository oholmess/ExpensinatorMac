//
//  CategoryService.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/23/24.
//

import Foundation
import Alamofire

class CategoryService {
    static let shared = CategoryService()
    
    var categories: [Category] = []

    func getCategories() async throws {
        // Replace with your actual Azure Function URL
        let route = NetworkRoutes.getCategories
        guard let url = route.url else {
            print("Failed to create/find URL")
            throw ConfigurationError.nilObject
        }
        
        do {
            // Make an asynchronous request to the Azure Function
            let data = try await AF.request(url)
                .validate(statusCode: 200..<300)
                .serializingData()
                .value
            
            // Decode the JSON data into an array of Expense objects
            let decoder = JSONDecoder()
            
            // Decode JSON into Expense array
            let categories = try decoder.decode([Category].self, from: data)
            
            await MainActor.run {
                self.categories = categories
            }
        } catch let error as AFError {
            print("AFError: Error fetching categories: \(error.localizedDescription)")
            throw error
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            throw error
        }
    }
}
