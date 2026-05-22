//
//  ChatGrid.swift
//  ChatBook
//
//  Created by user on 09.03.2026.
//

import SwiftUI

struct ChatGrid: View {
  let chats: [ChatModel]
  var body: some View {
	 if chats.isEmpty{
		Text("You have no chats.")
		  .font(.footnote.weight(.medium))
		  .shadow(radius: 1)
		  .frame(maxHeight: .infinity)
	 }else{
		ScrollView{
		  let userId = UserManager.shared.currentUserId
		  VStack(spacing: 5){
			 ForEach(chats){chat in
				let opponentPreview = chat.userPreviews.first(where: {$0.id != (userId)})
				Button{
				  NavigationManager.shared.chatId = chat.id
				}label: {
				  UserChat(opponentPreview: opponentPreview, chat: chat)
				}
			 }
		  }
		}
	 }
  }
}

#Preview {
  ChatGrid(chats: [])
}


@ViewBuilder
func UserChat(opponentPreview: UserPreview?, chat: ChatModel) -> some View{
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
}
