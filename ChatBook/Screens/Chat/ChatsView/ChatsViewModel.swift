//
//  ChatViewModel.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import Foundation
import Combine

@MainActor
final class ChatsViewModel: ObservableObject {
  @Published var userChats: [ChatModel] = []
  @Published var searchText: String = "" {
    didSet {
      if searchText.count >= 3 {
        searchUsers()
      } else {
        usersBySearch = []
      }
    }
  }
  @Published var usersBySearch: [UserModel] = []
  @Published var selectedChatID: String? = nil

  private var cancellables = Set<AnyCancellable>()
  private let chatManager = ChatManager.shared
  private let userManager = UserManager.shared

  var userId: String? { userManager.currentUserId }

  func fetchChats() {
    guard let userId = userManager.currentUserId else { return }

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

  private func searchUsers() {
    Task {
      let results = (try? await userManager.searchUsers(nicknamePrefix: searchText)) ?? []
      usersBySearch = results
    }
  }

  func prepareChat(with opponentId: String) async -> String {
    await chatManager.findOrCreateChat(with: opponentId)
  }
}
