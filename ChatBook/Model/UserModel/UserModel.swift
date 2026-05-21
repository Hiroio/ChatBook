//
//  UserModel.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import Foundation
import FirebaseAuth

struct UserModel: Codable{
  let id: String
  let nickname: String
  let email: String?
  let photoURL: String?
  let fcmToken: String
  let voipToken: String
  let isAnnonymous: Bool
  let isOnline: Bool
  let dateCreated: Date
}


extension UserModel{
  init(user: User){
    self.id = user.uid
    self.nickname = "User#\(user.uid.prefix(3))"
    self.email = user.email
    self.photoURL = user.photoURL?.absoluteString
    self.isAnnonymous = user.isAnonymous
	 self.fcmToken = ""
	 self.voipToken = ""
    self.isOnline = false
	 self.dateCreated = Date()
  }
}


struct UserPreview: Codable {
    let id: String
    let nickname: String
    let photoURL: String
}


