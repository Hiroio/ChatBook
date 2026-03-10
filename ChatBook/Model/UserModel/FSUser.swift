//
//  FSUser.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import Foundation


struct FSUser: Codable, Identifiable {
  let id: String
  let nickname: String
  let email: String
  let isAnnonymous: Bool
  let photoURL: String
  let isOnline: Bool
  let dateCreated: Date
}

extension FSUser{
  init(user: UserModel){
    self.id = user.id
    self.nickname = user.nickname
    self.email = user.email ?? ""
    self.isAnnonymous = user.isAnnonymous
    self.isOnline = user.isOnline
    self.photoURL = ""
    self.dateCreated = Date()
  }
}
