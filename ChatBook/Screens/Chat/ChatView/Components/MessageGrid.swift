//
//  MessageGrid.swift
//  ChatBook
//
//  Created by user on 10.03.2026.
//

import SwiftUI

struct MessageGrid: View {
  @EnvironmentObject private var vm: ChatViewModel
  let nameSpace: Namespace.ID
  let messages: [MessageModel]
  @State private var hoverTask: Task<Void, Never>?
  var body: some View {
	 ScrollViewReader{proxy in
		ScrollView{
		  LazyVStack(spacing: 10) {
			 ForEach(messages) { message in
				let userMessage = message.senderId == UserManager.shared.currentUserId ?? ""
				if vm.selectedMessage?.id != message.id {
				  MessageCard(message: message, native: userMessage)
					 .matchedGeometryEffect(id: message.id, in: nameSpace)
				}
			 }
			 
		  }
		  .padding()
		}
		.scrollDismissesKeyboard(.interactively)
		.onAppear {
		  scrollToBottom(proxy)
		}
		.onChange(of: messages.count) { _, _ in
		  scrollToBottom(proxy)
		}
	 }
  }
//  var messageForPreview: [MessageModel]{
//	 if self.messages.isEmpty{
//		return MessageModel.getForPreview(20, userId: UserManager.shared.currentUserId ?? "")
//	 }else{
//		return messages
//	 }
//  }
  
  private func scrollToBottom(_ proxy: ScrollViewProxy) {
	 guard let lastMessage = messages.last else { return }

	 DispatchQueue.main.async {
		withAnimation(.linear) {
		  proxy.scrollTo(lastMessage.id, anchor: .bottom)
		}
	 }
  }
}

#Preview {
  @Previewable @Namespace var ns
  MessageGrid(nameSpace: ns, messages: [])
	 .environmentObject(ChatViewModel(chat: .init(chatId: "")))
}
