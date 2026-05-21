//
//  ChatViewModel.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import Foundation
import Combine

class ChatsViewModel: ObservableObject{
  @Published var userChats: [ChatModel] = []
  @Published var searchText: String = "" {
    didSet {
      if searchText.count >= 3 {
        getUsersBySearch()
      } else {
        usersBySearch = []
      }
    }
  }
  @Published var usersBySearch: [FSUser] = []
  @Published var selectedChatID: String? = nil
  
  
  private var cancellables: Set<AnyCancellable> = []
//  MARK: MANAGERS
  private let chatManager = ChatManager.shared
  private let userManager = UserManager.shared
  
  let userId = AuthenticationManager.shared.user?.id
  init(){
    
  }
  
  
//  func getUsersChats() async {
//    await self.userChats = chatManager.getUserChats()
//  }
  
  func fetchChats() {
          guard let userId = AuthenticationManager.shared.user?.id else { return }

          chatManager.chatsPublisher(userId: userId)
              .receive(on: DispatchQueue.main)
              .sink { completion in
                  if case .failure(let error) = completion {
                      print("error: \(error.localizedDescription)")
                  }
              } receiveValue: { [weak self] chats in
                  self?.userChats = chats
              }
              .store(in: &cancellables)
      }
  
  
  private func getUsersBySearch(){
    Task {
      let results: [FSUser] = await userManager.getUsersBySearch(text: searchText)
      await MainActor.run {
        self.usersBySearch = results
      }
    }
  }
  
  func prepareChat(with opponentId: String) async -> String {
		await chatManager.findOrCreateChat(with: opponentId)
  }
  
}
