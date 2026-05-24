//
//  ContactViewModel.swift
//  ChatBook
//
//  Created by user on 22.05.2026.
//

import Foundation
import Combine

class ContactViewModel: ObservableObject{
  @Published var users: [UserModel] = []
  
  private let userManager = UserManager.shared
  private let chatManager = ChatManager.shared
  var cancellables = Set<AnyCancellable>()
  init(){
	 listenUsers()
  }
  
  func listenUsers(){
	 userManager.fetchUsers()
		.receive(on: DispatchQueue.main)
		.sink { _ in
		  
		} receiveValue: { [weak self] result in
		  self?.users = result.filter({$0.id != self?.userManager.currentUserId})
		}
		.store(in: &cancellables)

  }
  
  
  func getChatOrPrepare(with id : String) async throws -> ChatNavigation{
		return try await chatManager.findOrCreateChatID(with: id)
  }
  
}
