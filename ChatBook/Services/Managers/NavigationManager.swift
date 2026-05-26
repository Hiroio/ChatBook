//
//  NavigationManager.swift
//  ChatBook
//
//  Created by user on 19.05.2026.
//

import Foundation
import Combine

@MainActor
final class NavigationManager: ObservableObject {
  static let shared = NavigationManager()

  @Published var mainScreen: MainScreen = .chats
  @Published var userProfile: Bool = false
  @Published var chatId: ChatNavigation?
  
  @Published var popUps: SystemPopUp? = nil

  /// When set, MainView presents CallView.
  @Published var currentCall: CallModel?

  @Published var message: MessageModel?
}

enum MainScreen {
  case chats, contacts

  var title: String {
    switch self {
    case .chats: "Chats"
    case .contacts: "Contacts"
    }
  }
}

struct ChatNavigation {
  let chatId: String
  /// False when the chat document has not been created in Firestore yet.
  let exist: Bool

  init(chatId: String, exist: Bool = true) {
    self.chatId = chatId
    self.exist = exist
  }
}


enum SystemPopUp{
  case delete(() -> ())
  
  
  var text: String{
	 switch self {
	 case .delete:
		"Are you sure?"
	 }
  }
  
  var desc: String{
	 switch self {
	 case .delete:
		"This action cannot be undone."
	 }
  }
  
  var action: () -> Void{
	 switch self {
	 case .delete(let action):
		action
	 }
  }
}
