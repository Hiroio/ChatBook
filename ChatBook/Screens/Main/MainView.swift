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
		ZStack(alignment: .top){
		  Color.blue.opacity(0.14).ignoresSafeArea()
		  
		  VStack{
//			 Header
			 HStack{
				Text(navigation.mainScreen.title)
				  .font(.title.weight(.medium))
				  .frame(maxWidth: .infinity, alignment: .leading)
				UserSettings()
				  .zIndex(2)
			 }
			 .padding(.horizontal)
			 
//			 MARK: MAIN NAVIGATION
			 TabView(selection: $navigation.mainScreen){
				ChatsView()
				  .tabItem {
					 Image(systemName: "message")
				  }
				  .tag(MainScreen.chats)
				
				ContactView()
				  .tabItem {
					 Image(systemName: "phone")
				  }
				  .tag(MainScreen.contacts)
			 }
			 .zIndex(-1)
		  }
		  
//		  MARK: SECONDARY
		  if let chat = navigation.chatId{
			 ChatView(chat: chat)
				.zIndex(1)
				.transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top).combined(with: .opacity)))
				.allowsHitTesting(navigation.chatId != nil)
		  }
		  
		  if let call = navigation.currentCall {
			 CallView(call: call) {
				navigation.currentCall = nil
			 }
			 .zIndex(2)
			 .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top).combined(with: .opacity)))
			 .allowsHitTesting(navigation.currentCall != nil)
		  }
		  
		  if let message = navigation.message{
			 MessagePopUp(message: message)
				.padding(.horizontal, 5)
				.zIndex(3)
				.transition(.asymmetric(insertion: .move(edge: .top), removal: .opacity))
		  }
		  if let popUp = navigation.popUps{
			 ZStack{
				Color.black.opacity(0.3).ignoresSafeArea()
				  .onTapGesture {
					 navigation.popUps = nil
				  }
				SystemPopUpView(type: popUp)
			 }
			 .allowsHitTesting(navigation.popUps != nil)
			 .zIndex(3)
		  }
		}
		.sheet(isPresented: $navigation.userProfile, content: {
		  UserView()
			 .presentationDetents([.medium])
			 .presentationDragIndicator(.visible)
		})
		.animation(.bouncy, value: navigation.chatId != nil)
		.animation(.bouncy, value: navigation.currentCall != nil)
		.animation(.bouncy, value: navigation.message != nil)
		.animation(.bouncy, value: navigation.popUps != nil)
    }
}

#Preview {
    MainView()
	 .environmentObject(NavigationManager.shared)
}
