//
//  ChatViewModel.swift
//  ChatBook
//
//  Created by user on 09.03.2026.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject{
  @Published var currentChat: ChatModel? = nil
  @Published var messages: [MessageModel] = []

//  Helpers
  public let chatManager = ChatManager.shared
  public let userId = AuthenticationManager.shared.user?.id
  
  private var cancellables: Set<AnyCancellable> = []
  
//  CHAT ID
  let chatId: String
  
  init(id: String){
    chatId = id
    getChat(id: id)
    fetchMessages(chatId: id)
  }
  
  func getChat(id chatId: String){
    Task{
       let chat = try? await chatManager.getCurrentChat(for: chatId)
      
      await MainActor.run {
        self.currentChat = chat
      }
    }
  }
  
  func fetchMessages(chatId: String) {
          chatManager.listenToMessages(chatId: chatId)
              .receive(on: DispatchQueue.main)
              .sink { completion in
                  if case .failure(let error) = completion {
                      print("error: \(error.localizedDescription)")
                  }
              } receiveValue: { [weak self] messages in
                  self?.messages = messages
              }
              .store(in: &cancellables)
      }
  
  func sendMessage(text: String){
    guard let userId else {return}
    do{
      try chatManager.sentMessage(for: chatId, text: text, senderId: userId)
    }catch{
      print("failed to send message")
      return
    }
  }
  
  var opposideUser: UserPreview?{
    currentChat?.userPreviews.first(where: {$0.id != userId})
  }
}
