//
//  ChatBookApp.swift
//  ChatBook
//
//  Created by user on 07.03.2026.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging

@main
struct ChatBookApp: App {
  @Environment(\.scenePhase) var scenePhase
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject private var authManager = AuthenticationManager.shared
  @StateObject private var userManager = UserManager.shared
  @StateObject private var navigationManager = NavigationManager.shared

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(authManager)
        .environmentObject(userManager)
        .environmentObject(navigationManager)
    }
    .onChange(of: authManager.sessionState) { _, state in
      if state == .signedIn {
        CallManager.shared.warmUpEngine()
      }
    }
    .onChange(of: scenePhase) { _, newValue in
      guard authManager.sessionState == .signedIn else { return }

      Task {
        switch newValue {
        case .active:
          try? await userManager.setOnline(true)
        case .background, .inactive:
          try? await userManager.setOnline(false)
        @unknown default:
          try? await userManager.setOnline(false)
        }
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    print("Configurated")
//  FCM TOKEN
    PushNotificationManager.shared.setupNotifications(for: application)
//  VOIP TOKEN
	 VoIPService.shared.configure()

    Task { @MainActor in
      if AuthenticationManager.shared.sessionState == .signedIn {
        CallManager.shared.warmUpEngine()
      }
    }
    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    print("APNs токен успішно отримано від Apple в AppDelegate і передано у Firebase.")
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Apple не змогла видати APNs токен: \(error.localizedDescription)")
  }
}
