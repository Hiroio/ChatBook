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
    ScrollView{
      let userId = AuthenticationManager.shared.user?.id
      VStack(spacing: 15){
        ForEach(chats){chat in
          let opponentPreview = chat.userPreviews.first(where: {$0.id != (userId)})
          NavigationLink{
            ChatView(id: chat.id)
          }label:{
            UserChat(opponentPreview: opponentPreview, chat: chat)
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
    Circle()
      .frame(height: 100)
      .padding(.trailing)
    VStack(spacing: 10){
      Text(opponentPreview?.nickname ?? "Unknown")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      VStack{
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
      .fill(.white.opacity(0.7))
  )
}
