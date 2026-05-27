//
//  ChatCard.swift
//  ChatBook
//
//  Created by user on 23.05.2026.
//

import SwiftUI

struct ChatCard: View {
  @State private var dragAmountX: CGFloat = 0
  let opponentPreview: UserPreview?
  let chat: ChatModel
  var body: some View {
		HStack{
		  Image(systemName: "person.fill")
			 .padding()
			 .background(
				Circle()
				  .fill(.white)
				  .shadow(radius: 1)
			 )
			 .padding(.horizontal, 5)
		  VStack(alignment: .leading, spacing: 5){
			 Text(opponentPreview?.nickname ?? "Unknown")
				.font(.subheadline.weight(.black))
				.frame(maxWidth: .infinity, alignment: .leading)
				.foregroundStyle(.black)
			 
			 VStack(alignment: .leading){
				Text(chat.lastMessage)
				Text(chat.timestamp.formatted())
				  .font(.caption)
				  .frame(maxWidth: .infinity, alignment: .trailing)
			 }
			 .foregroundStyle(.gray)
		  }
		}
		.frame(maxWidth: .infinity)
		.padding()
		.background(
		  RoundedRectangle(cornerRadius: 20)
			 .fill(.white)
			 .shadow(radius: 1)
		)
		.offset(x: dragAmountX)
		.gesture(
		  DragGesture()
			 .onChanged({ drag in
				let distance = drag.location.x - drag.startLocation.x
				dragAmountX = max(-60, min(distance, 0))
			 })
			 .onEnded({ _ in
				if dragAmountX > -50 {
				  dragAmountX = 0
				}
			 })
		)
		.background(
		  RoundedRectangle(cornerRadius: 15)
			 .stroke(dragAmountX < -50 ? .red : .clear, lineWidth: 1)
		)
		.background(
		  Group{
			 if dragAmountX < -59{
				Button{
				  NavigationManager.shared.popUps = .delete{
					 Task{
						try? await ChatManager.shared.deleteChat(chat.id)
					 }
				  }
				}label: {
				  Image(systemName: "trash")
					 .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
					 .foregroundStyle(.red)
					 .font(.title)
					 .padding(.horizontal)
					 .frame(maxWidth: .infinity, alignment: .trailing)
					 .contentShape(.rect)
				}
			 }
		  }
		)
		.animation(.bouncy, value: dragAmountX)
	 }
  }

#Preview {
  ChatCard(opponentPreview: nil, chat: ChatModel(id: "", users: [], userPreviews: [], lastMessage: "", timestamp: Date()))
}
