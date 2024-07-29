//
//  Request+Storage.swift
//
//
//  Created by Cemal on 27.07.2024.
//

import Vapor
import GoogleCloud

// MARK: - Request + StorageHelper
extension Request {
    var storageHelper: StorageHelper {
        return StorageHelper(request: self)
    }
}

// MARK: - StorageHelper
struct StorageHelper {
    private var request: Request
    
    init(request: Request) {
        self.request = request
    }
    
    func uploadFile(
        bucket: GCSBucket = .worbion,
        fileData: Data,
        contentType: FileContentType,
        fileName: String
    ) async throws -> StorageUploadResult {
        let result = request.gcs.object.createSimpleUpload(
            bucket: bucket.rawValue,
            body: .data(fileData),
            name: fileName,
            contentType: contentType.contentType,
            queryParameters: nil)
        
        let object = try await result.get()
        return .init(mediaLink: object.mediaLink)
    }
}

// MARK: - StorageUploadResult
struct StorageUploadResult {
    let mediaLink: String?
}

// MARK: - Buckets
enum GCSBucket: String {
    case worbion = "worbiontestbucket"
}

// MARK: - FileContentType
enum FileContentType {
    case image(format: ImageFormatType)
    case pdf
    
    var contentType: String {
        switch self {
        case .image(let format):
            return "image/\(format.rawValue)"
        case .pdf:
            return "application/pdf"
        }
    }
}

enum ImageFormatType: String {
    case png
}
