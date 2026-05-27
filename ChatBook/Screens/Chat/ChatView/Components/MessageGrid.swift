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
  @State private var position = ScrollPosition()
  @State private var isScrolledTop: Bool = false
  var body: some View {
	 ScrollView(showsIndicators: false){
		LazyVStack(spacing: 10) {
		  ForEach(messages) { message in
			 let userMessage = message.senderId == UserManager.shared.currentUserId ?? ""
			 if vm.selectedMessage?.id != message.id {
				MessageCard(message: message, native: userMessage)
				  .matchedGeometryEffect(id: message.id, in: nameSpace)
				  .id(message.id)
			 }
		  }
		  
		}
		.padding(10)
	 }
	 .defaultScrollAnchor(.bottom)
	 .scrollDismissesKeyboard(.interactively)
	 .scrollPosition($position, anchor: .bottom)
	 .onScrollGeometryChange(for: Bool.self) { geo in
		let bottomInset = geo.contentInsets.bottom
		let visibleBottom = geo.contentOffset.y + geo.containerSize.height - bottomInset
		let contentBottom = geo.contentSize.height
		let distanceFromBottom = contentBottom - visibleBottom
		return distanceFromBottom > 80
	 } action: { _, shouldShowButton in
		isScrolledTop = shouldShowButton
	 }
	 .scrollBounceBehavior(.basedOnSize)
	 .overlay(alignment: .bottomTrailing){
		Button {
		  withAnimation {
			 position.scrollTo(edge: .bottom)
		  }
		} label: {
		  Image(systemName: "chevron.down")
			 .padding(10)
			 .background(
				Circle()
				  .fill(.ultraThinMaterial)
			 )
		}
		.opacity(isScrolledTop ? 1 : 0)
	 }
	 .onAppear {
		position = ScrollPosition(edge: .bottom)
	 }
	 //		.onChange(of: messages.count) { _, _ in
	 //		  scrollToBottom(proxy)
	 //		}
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
