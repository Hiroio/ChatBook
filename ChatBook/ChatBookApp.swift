//
//  ChatBookApp.swift
//  ChatBook
//
//  Created by user on 07.03.2026.
//

import SwiftUI
import FirebaseCore

@main
struct ChatBookApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject private var authManager = AuthenticationManager.shared
    var body: some Scene {
        WindowGroup {
            RootView()
            .environmentObject(authManager)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ aplication: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool{
        FirebaseApp.configure()
        
        print("Configurated")
        return true
    }
}
