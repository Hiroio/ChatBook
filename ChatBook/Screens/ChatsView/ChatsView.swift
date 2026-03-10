//
//  ChatsView.swift
//  ChatBook
//
//  Created by user on 07.03.2026.
//

import SwiftUI

struct ChatsView: View {
  @StateObject private var vm = ChatsViewModel()
  @State private var isPresent: Bool = false
  var body: some View {
    NavigationStack{
      ZStack{
        RadialGradient(colors: [.blue.opacity(0.2), .white.opacity(0.5)], center: .center, startRadius: 500, endRadius: 10)
          .ignoresSafeArea()
        
        VStack{
          HStack{
            Text("Chats")
              .font(.title.bold())
              .fontDesign(.monospaced)
            Spacer()
            UserSettings(isPresent: $isPresent)
              .zIndex(2)
          }
          VStack{
            SearchView()
              .zIndex(2)
            
            //          MARK: User Chats
            ChatGrid(chats: vm.userChats)
              .zIndex(-1)
          }
          .padding()
        }
        .frame(maxWidth: .infinity)
        
        if isPresent{
          ZStack{
            Color.black.opacity(0.3)
              .ignoresSafeArea()
              .transition(.opacity)
              .onTapGesture {
                withAnimation(){
                  isPresent.toggle()
                }
              }
            
            UserView()
              .transition(.move(edge: .bottom))
          }
          .zIndex(1)
          .allowsHitTesting(isPresent)
        }
      }
      .environmentObject(vm)
    }
  }
}

#Preview {
    ChatsView()
}
