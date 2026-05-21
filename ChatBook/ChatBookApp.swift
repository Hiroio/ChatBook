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
  @StateObject private var navigationManager = NavigationManager.shared
  var body: some Scene {
	 WindowGroup {
		RootView()
		  .environmentObject(authManager)
		  .environmentObject(navigationManager)
	 }
	 .onChange(of: scenePhase) { oldValue, newValue in
		Task{
		  switch newValue{
		  case .active:
			 await UserManager.shared.initializeUser(online: true)
		  case .background:
			 await UserManager.shared.initializeUser(online: false)
		  default:
			 await UserManager.shared.initializeUser(online: false)
		  }
		}
	 }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
	 
	 FirebaseApp.configure()
	 print("Configurated")
	 
	 PushNotificationManager.shared.setupNotifications(for: application)
	 VoIPService.shared.configure()
	 
	 Task{
		if let user = await UserManager.shared.getUser(){
		  CallManager.shared.initializeClient()
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
