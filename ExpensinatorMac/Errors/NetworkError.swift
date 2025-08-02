//
//  NetworkError.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 12/6/24.
//

import Foundation

enum NetworkError: Error {
    
    case userError(String)
    case dataError(String)
    case encodingError
    case decodingError
    case failedStatusCode(String)
    case failedStatusCodeResponseData(Int, Data)
    case noResponse
    
    var statusCodeResponseData: (Int, Data)? {
        switch self {
        case .failedStatusCodeResponseData(let statusCode, let data):
            return (statusCode, data)
        default:
            return nil
        }
    }
    
}
