//
//  Category.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/23/24.
//

import Foundation

struct Category: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var categoryId: Int?
    var name: String
    
    init(categoryId: Int? = nil, name: String) {
        self.categoryId = categoryId
        self.name = name
    }
    
    enum CodingKeys: String, CodingKey {
        case categoryId, name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        categoryId = try container.decodeIfPresent(Int.self, forKey: .categoryId)
        name = try container.decode(String.self, forKey: .name)
    }
}
