//
//  ChatView.swift
//  ChatBook
//
//  Created by user on 09.03.2026.
//

import SwiftUI

struct ChatView: View {
  @Namespace var animation
  @State private var repliedMessage: MessageModel? = nil
  @StateObject var vm: ChatViewModel
  let chatId: String
  
  init(chat: ChatNavigation) {
    chatId = chat.chatId
    _vm = StateObject(wrappedValue: ChatViewModel(chat: chat))
  }
  @State private var chatText: String = ""
    var body: some View {
      ZStack{
		  Color.white.ignoresSafeArea()
        VStack{
			 header
          Spacer()
          
//          MARK: FOR MESSAGES
          if vm.messages.isEmpty{
				Text("Chat is empty.\nSend a message to start conversation.")
				  .multilineTextAlignment(.center)
				  .frame(maxHeight: .infinity)
				  .foregroundStyle(.gray)
				  .font(.footnote)
          }else{
				MessageGrid(nameSpace: animation, messages: vm.messages)
          }
          
			 ChatTextField()
				.environmentObject(vm)

        }
		  .blur(radius: vm.selectedMessage != nil ? 5 : 0)
		  
//		  Selection of message
		  if let selectedMessage = vm.selectedMessage{
			 ZStack{
				Color.black.opacity(0.05).ignoresSafeArea()
				  .onTapGesture {
					 vm.selectedMessage = nil
				  }
				SelectedMessage(nameSpace: animation, message: selectedMessage)
			 }
			 .allowsHitTesting(vm.selectedMessage != nil)
		  }
      }
		.environmentObject(vm)
		.animation(.linear, value: vm.selectedMessage != nil)
		.animation(.easeInOut(duration: 1.0), value: vm.messages.isEmpty)
    }
  
  private var header: some View{
	 VStack{
		let online = (vm.otherUser?.isOnline ?? false)
		Text(vm.otherUser?.nickname ?? "Unknown")
		  .font(.headline)
		Text(online ? "Online" : "Offline")
		  .foregroundStyle(online ? .green : .red)
		  .font(.caption)
	 }
	 .frame(maxWidth: .infinity)
	 .overlay(
		HStack{
		  Button{
			 NavigationManager.shared.chatId = nil
		  }label: {
			 Image(systemName: "chevron.left")
				.padding()
				.background(
				  Circle()
					 .fill(.white)
					 .shadow(radius: 1)
				)
		  }
		  Spacer()
		  
		  Button{
			 if let otherUser = vm.otherUser{
				NavigationManager.shared.currentCall = CallModel(chatID: vm.chatId, oppositeUser: otherUser)
			 }
		  }label: {
			 Image(systemName: "phone")
				.padding()
				.background(
				  Circle()
					 .fill(.white)
					 .shadow(radius: 1)
				)
		  }
		}
		  .padding(.horizontal)
	 )
  }
  
  
}

#Preview {
  NavigationStack{
    ChatView(chat: ChatNavigation(chatId: "123"))
  }
}
