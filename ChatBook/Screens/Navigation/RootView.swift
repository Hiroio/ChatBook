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
    ZStack {
      switch authManager.sessionState {
      case .loading:
        ProgressView("Loading…")
      case .signedOut:
        AuthorizationView()
          .transition(.move(edge: .top))
      case .signedIn:
        MainView()
      }
    }
    .animation(.easeInOut, value: authManager.sessionState)
  }
}

#Preview {
  RootView()
    .environmentObject(AuthenticationManager.shared)
}
