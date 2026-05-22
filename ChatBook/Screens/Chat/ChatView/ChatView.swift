//
//  ChatView.swift
//  ChatBook
//
//  Created by user on 09.03.2026.
//

import SwiftUI

struct ChatView: View {
  @State var callPresented: Bool = false
  @StateObject var vm: ChatViewModel
  let chatId: String
  
  init(id: String){
    _vm = StateObject(wrappedValue: ChatViewModel(id: id))
	 self.chatId = id
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
//            Text("No messages yet.")
//              .font(.subheadline)
//            Spacer()
          }else{
            MessageGrid(messages: vm.messages)
          }
          
          HStack(spacing: 20){
            TextField(text: $chatText){
              Text("Write a message...")
            }
				.scrollDismissesKeyboard(.interactively)
            .padding()
            .foregroundStyle(.black)
            .background(
              RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .blue.opacity(0.5), radius: 5)
            )
            Button{
              vm.sendMessage(text: chatText)
              chatText = ""
            }label:{
              Image(systemName: "paperplane.fill")
                .font(.headline)
					 .padding()
					 .background(
						Circle()
						  .fill(.white)
						  .shadow(radius: 1)
					 )
            }
          }
          .padding(.horizontal)

        }
		  if callPresented{
			 if let user = vm.otherUser{
				CallView(oppositeUser: user, chatId: chatId){callPresented = false}
				  .transition(.move(edge: .bottom))
			 }
		  }
		  
		  
      }
		.animation(.easeInOut, value: callPresented)
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
    ChatView(id: "123")
  }
}
