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




// MARK: - Message

struct MessageModel: Codable, Identifiable {
  let id: String
  let text: String
  let senderId: String
  let timestamp: Date

  /// Local-only delivery state. Not stored in Firestore.
  var localStatus: MessageStatus = .delivered

  enum CodingKeys: String, CodingKey {
    case id, text, senderId, timestamp
  }

  init(
    id: String,
    text: String,
    senderId: String,
    timestamp: Date,
    localStatus: MessageStatus = .delivered
  ) {
    self.id = id
    self.text = text
    self.senderId = senderId
    self.timestamp = timestamp
    self.localStatus = localStatus
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    text = try container.decode(String.self, forKey: .text)
    senderId = try container.decode(String.self, forKey: .senderId)
    timestamp = try container.decode(Date.self, forKey: .timestamp)
    localStatus = .delivered
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(text, forKey: .text)
    try container.encode(senderId, forKey: .senderId)
    try container.encode(timestamp, forKey: .timestamp)
  }
}

enum MessageStatus: Equatable {
  case delivered, loading, failed
}
