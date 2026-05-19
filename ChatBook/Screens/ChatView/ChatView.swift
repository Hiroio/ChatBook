//
//  ChatView.swift
//  ChatBook
//
//  Created by user on 09.03.2026.
//

import SwiftUI

struct ChatView: View {
  @StateObject var vm: ChatViewModel
  
  init(id: String){
    _vm = StateObject(wrappedValue: ChatViewModel(id: id))
  }
  @State private var chatText: String = ""
    var body: some View {
      ZStack{
		  Color.white.ignoresSafeArea()
        VStack{
          Spacer()
          
//          MARK: FOR MESSAGES
          if vm.messages.isEmpty{
            Text("No messages yet")
              .font(.headline)
              .foregroundStyle(.blue.opacity(0.7))
              .shadow(radius: 2, y: 7)
            Spacer()
          }else{
            MessageGrid(messages: vm.messages)
              .animation(.easeInOut, value: vm.messages.count)
          }
          
          HStack(spacing: 20){
            TextField(text: $chatText){
              Text("Write a message...")
                .foregroundStyle(.blue.opacity(0.5))
            }
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
                .font(.title)
            }
          }
          .padding(.horizontal)

        }
      }
      .toolbar(content: {
        ToolbarItem(placement: .navigation) {
          Circle()
            .frame(height: 55)
        }
      })
      .navigationTitle(vm.opposideUser?.nickname ?? "User")
      .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
  NavigationStack{
    ChatView(id: "123")
  }
}
