//
//  GoogleStorage.swift
//
//
//  Created by Cemal on 26.07.2024.
//

import Vapor
import GoogleCloud
import CloudStorage

func setupStorage(app: Application) throws {
    guard
        let projectId = Environment.get("GOOGLE_APPLICATION_PROJECT_ID"),
        let googleServiceAccountCredentialsJsonStr = Environment.get("GOOGLE_APPLICATION_CREDENTIALS")
    else {
        return
    }
    let serviceAccountCredentials = try GoogleServiceAccountCredentials(fromJsonString: googleServiceAccountCredentialsJsonStr)
    
    var googleCloudCredentials = try GoogleCloudCredentialsConfiguration(projectId: projectId)
    googleCloudCredentials.serviceAccountCredentials = serviceAccountCredentials
    app.googleCloud.credentials = googleCloudCredentials
    app.googleCloud.storage.configuration = .default()
    
}

extension String {
    enum GCSBucket {
        static let worbion = "worbiontestbucket"
    }
}
