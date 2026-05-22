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
  @Published var userProfile: Bool = false
  @Published var chatId: String? = nil
  @Published var currentCall: CallModel? = nil
  
}





enum MainScreen{
  case chats, contacts
  
  var title: String{
	 switch self {
	 case .chats:
		"Chats"
	 case .contacts:
		"Contacts"
	 }
  }
}
