//
//  NetworkRoutes.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 12/5/24.
//

import Foundation

enum NetworkRoutes {
    private static let baseUrl = "https://FunctionAppCCB2.azurewebsites.net/"
    
    case getExpenses
    case addExpense
    case updateExpenses
    case deleteExpenses
    case getCategories
    case addReceiptToBlob
    
    var url: URL? {
        var path: String
        switch self {
        case .getExpenses:
            path = NetworkRoutes.baseUrl + "api/get_expenses"
        case .addExpense:
            path = NetworkRoutes.baseUrl + "api/add_expense"
        case .updateExpenses:
            path = NetworkRoutes.baseUrl + "api/update_expenses"
        case .deleteExpenses:
            path = NetworkRoutes.baseUrl + "api/delete_expenses"
        case .getCategories:
            path = NetworkRoutes.baseUrl + "api/get_categories"
        case .addReceiptToBlob:
            path = NetworkRoutes.baseUrl + "api/upload_receipt_to_blob"
        }
        
        return URL(string: path)
    }
    
    var method: HttpMethod {
        switch self {
        case .addExpense, .addReceiptToBlob:
            return .post
        case .getExpenses, .getCategories:
            return .get
        case .updateExpenses:
            return .put
        case .deleteExpenses:
            return .delete
        }
    }
    
}
