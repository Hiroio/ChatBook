//
//  ChatViewModel.swift
//  ChatBook
//
//  Created by user on 09.03.2026.
//

import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject{
  @Published var otherUser: UserModel? = nil
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
  
//  MARK: Getting chat from FireStore
  func getChat(id chatId: String){
    Task{
       let chat = try? await chatManager.getCurrentChat(for: chatId)
      
      await MainActor.run {
        self.currentChat = chat
		  if let otherUserId = opposideUser?.id{
			 getOppositeUser(with: otherUserId)
		  }
		  }
      }
    }
  
//  Listening User if he's online.
func getOppositeUser(with id: String){
	 chatManager.listenUser(userId: id)
		.receive(on: DispatchQueue.main)
		.sink { completion in
		  switch completion{
		  case .failure(let error):
			 print("Error: \(error)")
		  default:
			 print("Success")
		  }
		} receiveValue: { [weak self] user in
		  self?.otherUser = user
		}
		.store(in: &cancellables)
  }
  
//  Listening messages live
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
