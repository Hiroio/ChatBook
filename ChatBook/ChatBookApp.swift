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
	 @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
	 @StateObject private var authManager = AuthenticationManager.shared
  @StateObject private var navigationManager = NavigationManager.shared
	 var body: some Scene {
		  WindowGroup {
				RootView()
					 .environmentObject(authManager)
					 .environmentObject(navigationManager)
		  }
	 }
}

class AppDelegate: NSObject, UIApplicationDelegate {
	 
	 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		  
		  FirebaseApp.configure()
		  print("Configurated")
		  
		  PushNotificationManager.shared.setupNotifications(for: application)
		  
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
