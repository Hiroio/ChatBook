//
//  RootView.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import SwiftUI

struct RootView: View {
  @EnvironmentObject var authManager: AuthenticationManager
    var body: some View {
		ZStack{
		  if authManager.user == nil{
			 AuthorizationView()
				.transition(.move(edge: .top))
		  }else{
			 MainView()
		  }
		}
		.animation(.easeInOut, value: authManager.user != nil)
    }
}

#Preview {
    RootView()
    .environmentObject(AuthenticationManager.shared)
}
