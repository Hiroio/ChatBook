//
//  ChatsView.swift
//  ChatBook
//
//  Created by user on 07.03.2026.
//

import SwiftUI

struct ChatsView: View {
  @StateObject private var vm = ChatsViewModel()
  var body: some View {
      ZStack{
        RadialGradient(colors: [.blue.opacity(0.2), .white.opacity(0.5)], center: .center, startRadius: 500, endRadius: 10)
          .ignoresSafeArea()
        
        VStack{
          VStack{
            SearchView()
              .zIndex(1)
            
            //          MARK: User Chats
            ChatGrid(chats: vm.userChats)
              .zIndex(-1)
          }
			 .zIndex(1)
        }
		  .padding()
        .frame(maxWidth: .infinity)
      }
		.onAppear{
		  vm.fetchChats()
		}
      .environmentObject(vm)
    }
}

#Preview {
    ChatsView()
}
