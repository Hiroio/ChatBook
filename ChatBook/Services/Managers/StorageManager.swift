//
//  StorageManager.swift
//  ChatBook
//
//  Created by user on 10.03.2026.
//

import Foundation
import FirebaseStorage

class StorageManager{
  static let shared = StorageManager()
  
  private let storage = Storage.storage().reference()
  
  func uploadProfileImage(imageData: Data, userId: String) async throws -> String{
            let fileRef = storage.child("avatars/\(userId).jpg")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            _ = try await fileRef.putDataAsync(imageData, metadata: metadata)
            
            let downloadURL = try await fileRef.downloadURL()
            return downloadURL.absoluteString
  }
}
