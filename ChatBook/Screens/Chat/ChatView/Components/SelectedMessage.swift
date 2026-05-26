//
//  SelectedMessage.swift
//  ChatBook
//
//  Created by user on 26.05.2026.
//

import SwiftUI

struct SelectedMessage: View {
  @EnvironmentObject private var vm: ChatViewModel
  let nameSpace: Namespace.ID
  let message: MessageModel
    var body: some View {
		let userMessage = message.senderId == UserManager.shared.currentUserId
		VStack(alignment: userMessage ? .trailing : .leading){
		  MessageCard(message: message, native: userMessage)
		  .matchedGeometryEffect(id: message.id, in: nameSpace)
		  VStack{
			 menu
		  }
		  .padding()
		  .background(
			 RoundedRectangle(cornerRadius: 15)
				.fill(.ultraThinMaterial)
		  )
		}
		.frame(maxWidth: .infinity, alignment: userMessage ? .trailing : .leading)
		}
  
  private var menu: some View{
	 VStack(alignment: .leading){
		actionBtn(label: "Reply", image: "arrowshape.turn.up.left", action: {
		  vm.replyMessage = message
		})
		actionBtn(label: "Copy", image: "document.on.document", action: {
		  UIPasteboard.general.string = message.text
		  vm.selectedMessage = nil
		})
		if message.senderId == UserManager.shared.currentUserId{
		  actionBtn(label: "Edit", image: "pencil", action: {
			 vm.messageForEdit = message
			 vm.selectedMessage = nil
		  })
		}
		Rectangle()
		  .frame(height: 1)
		  .opacity(0.4)
		Button{
		  NavigationManager.shared.popUps = .delete {
			 Task { await vm.deleteMessage(message.id) }
		  }
		  vm.selectedMessage = nil
		}label:{
		  HStack{
			 Text("Delete")
				.frame(maxWidth: .infinity, alignment: .leading)
			 Image(systemName: "trash")
		  }
		  .padding(5)
		  .foregroundStyle(.red)
		}
	 }
	 .frame(maxWidth: 150)
	 
  }
}

#Preview {
  @Previewable @Namespace var ns
  SelectedMessage(nameSpace: ns,
	 message: MessageModel(id: "", text: "qwe", senderId: "", timestamp: Date()))
  .environmentObject(ChatViewModel(chat: ChatNavigation(chatId: "qwe")))
}


@ViewBuilder
func actionBtn(label: String, image: String, action: @escaping () -> ()) -> some View{
  Button{
	 action()
  }label: {
	 HStack(spacing: 5){
		Image(systemName: image)
		Text(label)
	 }
	 .padding(5)
	 .foregroundStyle(.black)
  }
}
