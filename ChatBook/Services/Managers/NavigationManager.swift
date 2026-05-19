//
//  NavigationManager.swift
//  ChatBook
//
//  Created by user on 19.05.2026.
//

import Foundation
import Combine

class NavigationManager: ObservableObject{
  static let shared = NavigationManager()
  @Published var mainScreen: MainScreen = .chats
  @Published var chatId: String? = nil
  
}





enum MainScreen{
  case chats, profile, contacts
}
