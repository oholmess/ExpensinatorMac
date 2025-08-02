//
//  NetworkHandler.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 12/5/24.
//

import Foundation


enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum ContentType: String {
    case json = "application/json; charset=utf-8"
}

class NetworkHandler {
    func request(
        _ url: URL,
        jsonDictionary: Any? = nil,
        httpMethod: String = HttpMethod.get.rawValue,
        contentType: String = ContentType.json.rawValue,
        accessToken: String? = nil
    ) async throws -> Data {
        var urlRequest = makeUrlRequest(url, httpMethod: httpMethod, contentType: contentType, accessToken: accessToken)
        
        if let jsonDictionary, let httpBody = try? JSONSerialization.data(withJSONObject: jsonDictionary) {
            urlRequest.httpBody = httpBody
        } else if jsonDictionary != nil {
            print("Failed to serialize object to JSON data")
            throw ConfigurationError.nilObject
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Could not create HTTPURLResponse for url: \(urlRequest.url?.absoluteString ?? "")")
            throw NetworkError.noResponse
        }
        
        let statusCode = httpResponse.statusCode
        guard 200...299 ~= statusCode else {
            print("Failed status code: \(statusCode)")
            throw NetworkError.failedStatusCodeResponseData(statusCode, data)
        }
        
        return data
    }
    
    func request<ResponseType: Decodable>(
        _ url: URL,
        jsonDictionary: Any? = nil,
        responseType: ResponseType.Type,
        httpMethod: String = HttpMethod.get.rawValue,
        contentType: String = ContentType.json.rawValue,
        accessToken: String? = nil
    ) async throws -> ResponseType {
        let data = try await request(url, jsonDictionary: jsonDictionary, httpMethod: httpMethod, contentType: contentType, accessToken: accessToken)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("DEBUG: Data received in function \(#function):\n\(String(describing: responseString.first))")
        } else {
            print("DEBUG: Data received in function \(#function) could not be converted to string.")
        }
        
        print("DEBUG: decoded data: ", try JSONDecoder().decode(responseType, from: data))
        
        return try JSONDecoder().decode(responseType, from: data)
    }
}


extension NetworkHandler {
    func makeUrlRequest(
        _ url: URL,
        httpMethod: String = HttpMethod.get.rawValue,
        contentType: String? = ContentType.json.rawValue,
        accessToken: String? = nil
    ) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        print("DEBUG: HTTP Method: \(httpMethod)")
        
        if let contentType {
            urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
            
            if contentType.ranges(of: "json") != nil {
                urlRequest.addValue(contentType, forHTTPHeaderField: "Accept")
            }
        }
        
        if let accessToken = accessToken {
            let authorizationKey = "Bearer ".appending(accessToken)
            urlRequest.addValue(authorizationKey, forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
    
}
