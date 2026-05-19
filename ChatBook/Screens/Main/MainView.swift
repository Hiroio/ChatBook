//
//  MainView.swift
//  ChatBook
//
//  Created by user on 19.05.2026.
//

import SwiftUI

struct MainView: View {
  @EnvironmentObject var navigation: NavigationManager
    var body: some View {
		ZStack{
		  TabView(selection: $navigation.mainScreen){
			 ChatsView()
				.tabItem {
				  Image(systemName: "message")
				}
				.tag(MainScreen.chats)
			 
			 EmptyView()
				.tabItem {
				  Image(systemName: "phone")
				}
				.tag(MainScreen.contacts)
		  }
		  
		  if navigation.mainScreen == .profile{
			 
		  }
		  
		  if let chatId = navigation.chatId{
			 ChatView(id: chatId)
				.zIndex(1)
				.transition(.slide)
				.allowsHitTesting(navigation.chatId != nil)
		  }
		}
		.animation(.bouncy, value: navigation.chatId != nil)
    }
}

#Preview {
    MainView()
	 .environmentObject(NavigationManager.shared)
}
