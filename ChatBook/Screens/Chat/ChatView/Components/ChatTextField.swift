//
//  ChatTextField.swift
//  ChatBook
//
//  Created by user on 26.05.2026.
//

import SwiftUI

struct ChatTextField: View {
  @EnvironmentObject private var vm: ChatViewModel
    var body: some View {
		VStack(spacing: 0){
		  if let replyMessage = vm.replyMessage {
			 HStack{
				ReplyCard(replyText: replyMessage.text, replyFrom: vm.replyName(replyMessage.id))
				  .frame(maxWidth: .infinity, alignment: .leading)
				Button{
				  vm.replyMessage = nil
				}label: {
				  Image(systemName: "xmark")
				}
			 }
			 .padding(.horizontal)
			 .padding(.vertical, 10)
		  }
		  
		  if let editMessage = vm.messageForEdit {
			 HStack{
				Rectangle()
				  .frame(width: 1, height: 15)
				Text("Editing")
				  .frame(maxWidth: .infinity, alignment: .leading)
				
				Button{
				  vm.chatText = ""
				  vm.messageForEdit = nil
				}label: {
				  Image(systemName: "xmark")
					 .foregroundStyle(.black)
				}
			 }
			 .foregroundStyle(.green.opacity(0.4))
			 .padding(10)
			 .onAppear {
				vm.chatText = editMessage.text
			 }
		  }
		  HStack(spacing: 20){
			 TextField(text: $vm.chatText){
				Text("Write a message...")
			 }
			 .scrollDismissesKeyboard(.interactively)
			 .padding(15)
			 .foregroundStyle(.black)
			 Button{
				if vm.isEditing{
				  vm.editMessage()
				}else{
				  vm.sendMessage()
				}
			 }label:{
				Image(systemName: vm.isEditing ? "checkmark" : "paperplane.fill")
				  .font(.title2)
				  .padding(10)
				  .background(
					 Circle()
						.fill(.white)
						.shadow(radius: 1)
				  )
				  .padding(.horizontal, 5)
			 }
		  }
		}
		.background(
		  RoundedRectangle(cornerRadius: 20)
			 .fill(.white)
			 .shadow(color: .blue.opacity(0.3), radius: 5)
		)
		.padding(10)
		.animation(.easeInOut, value: vm.replyMessage != nil)
		.animation(.easeInOut, value: vm.messageForEdit != nil)
    }
}

#Preview {
    ChatTextField()
	 .environmentObject(ChatViewModel(chat: ChatNavigation(chatId: "qwe")))
}
