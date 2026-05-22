//
//  MessageGrid.swift
//  ChatBook
//
//  Created by user on 10.03.2026.
//

import SwiftUI

struct MessageGrid: View {
  let messages: [MessageModel]
    var body: some View {
      ScrollView{
        VStack{
          ForEach(messages){message in
            let userMessage = message.senderId == UserManager.shared.currentUserId
            HStack(alignment: .bottom){
              Text(message.text)
              Text(message.timestamp.formatted(.dateTime.hour().minute()))
                .font(.caption2)
            }
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .blue.opacity(0.5), radius: 4)
            )
            .frame(maxWidth: .infinity, alignment: userMessage ? .trailing : .leading)
          }
        }
        .padding()
      }
    }
}

#Preview {
    MessageGrid(messages: [])
}
