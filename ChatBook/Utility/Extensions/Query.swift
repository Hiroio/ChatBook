//
//  Query.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import Foundation
import FirebaseFirestore


extension Query{
  func getDocumentsCustom<T: Decodable>() async throws -> [T]{
    return try await getDocumentsCustomWithSnapshot().product as [T]
  }
  
  func getDocumentsCustomWithSnapshot<T: Decodable>() async throws -> (product: [T], lastDocument: DocumentSnapshot?){
      let data = try await self.getDocuments()
      
      let product = try data.documents.map({
          try $0.data(as: T.self)
      })
      return (product, data.documents.last)
  }
}
