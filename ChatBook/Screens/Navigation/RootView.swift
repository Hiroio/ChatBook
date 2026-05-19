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
      if authManager.user == nil{
        AuthorizationView()
      }else{
        MainView()
      }
    }
}

#Preview {
    RootView()
    .environmentObject(AuthenticationManager.shared)
}
