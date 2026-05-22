//
//  UserModel.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import Foundation

struct UserModel: Codable, Identifiable, Equatable {
  let id: String
  var nickname: String
  let email: String?
  var photoURL: String?
  var fcmToken: String
  var voipToken: String
  let isAnnonymous: Bool
  var isOnline: Bool
  let dateCreated: Date
  
  
  static let preview = UserModel(id: "", nickname: "User", email: "", fcmToken: "", voipToken: "", isAnnonymous: false, isOnline: true, dateCreated: Date())
}

extension UserModel {
  static func newProfile(id: String, email: String?, isAnonymous: Bool) -> UserModel {
    UserModel(
      id: id,
      nickname: "User#\(id.prefix(3))",
      email: email,
      photoURL: nil,
      fcmToken: "",
      voipToken: "",
      isAnnonymous: isAnonymous,
      isOnline: true,
      dateCreated: Date()
    )
  }
}

struct UserPreview: Codable {
  let id: String
  let nickname: String
  let photoURL: String
}
