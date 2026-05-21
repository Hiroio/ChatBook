//
//  CallViewModel.swift
//  ChatBook
//
//  Created by user on 20.05.2026.
//

import Foundation
import Combine

class CallViewModel: ObservableObject {
  @Published var statusMessage: String = ""
  let callManager = CallManager.shared
  let chatId: String
  let oppositeUser: UserModel
  
  var cancellables = Set<AnyCancellable>()
  init(chatId: String, oppositeUser: UserModel){
	 self.chatId = chatId
	 self.oppositeUser = oppositeUser
	 listenStatus()
  }
  
  
  func startCall() {
	 callManager.joinChannel(channelName: chatId)
	 
	 sendVoIPRequest()
  }
  
  func listenStatus(){
	 callManager.$statusMessage.sink { _ in
		
	 } receiveValue: { message in
		self.statusMessage = message
	 }
	 .store(in: &cancellables)
	 
  }
  
  func leaveCall(){
	 callManager.leaveChannel()
  }
  
  func sendVoIPRequest(){
	 Task {
		let user = await UserManager.shared.getUser()
		
		await CallService.shared.startRemoteCall(
		  chatId: self.chatId,
		  receiverId: oppositeUser.id,
		  callerName: user?.nickname ?? ""
		)
	 }
  }
}
