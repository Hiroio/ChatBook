//
//  ChatModel.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import Foundation

struct ChatModel: Codable, Identifiable{
  let id: String
  let users: [String]
  let userPreviews: [UserPreview]
  let lastMessage: String
  let timestamp: Date
  
  
  
  
  
  
//  TODO: CHATMANAGER NEW CReATION FUNC WITH DATA
//  func opponentData(currentUserId: String) -> UserModel? {
//          if let opponentId = users.first(where: { $0 != currentUserId }) {
//            return userData[opponentId]
//          }
//          return nil
//      }
}




//MARK: Message model
struct MessageModel: Codable, Identifiable{
  let id: String
  let text: String
  let senderId: String
  let timestamp: Date
}
