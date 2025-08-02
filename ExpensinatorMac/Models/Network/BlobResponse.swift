//
//  BlobResponse.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 12/6/24.
//

import Foundation

struct UploadResponse: Decodable {
    let message: String
    let blobUrl: String
}

