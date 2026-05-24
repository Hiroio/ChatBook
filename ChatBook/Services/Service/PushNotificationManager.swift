//
//  PushNotificationManager.swift
//  ChatBook
//
//  Created by user on 19.05.2026.
//
import Foundation
import UIKit
import FirebaseMessaging
import UserNotifications

class PushNotificationManager: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
	 
	 static let shared = PushNotificationManager()
	 let userDefault = UserDefaultsManager.shared
	 
	 private override init() {
		  super.init()
	 }
	 
	 // MARK: Setting up notification
	 func setupNotifications(for application: UIApplication) {
		  UNUserNotificationCenter.current().delegate = self
		  Messaging.messaging().delegate = self
		  
		  let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		  UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
				if granted {
					 print("got permission!")
					 
					 DispatchQueue.main.async {
						  application.registerForRemoteNotifications()
					 }
				} else if let error = error {
					 print("failed to get permission: \(error.localizedDescription)")
				}
		  }
	 }
	 
	 // MARK: Getting fcm token (Firebase calling automaticaly when token ready)
	 func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		  guard let token = fcmToken else { return }
		  print("New FCMToken: \(token)")
		  saveTokenToFirestore(token: token)
	 }
	 
	 // MARK: Saving fcmToken
	 private func saveTokenToFirestore(token: String) {
		Task{
		guard token != userDefault.voIpToken else {return}
		  
		  await MainActor.run {
			 userDefault.fcmToken = token
		  }
		  
		do{
		  try await UserManager.shared.setFCMToken()
		  print("FCM TOKEN SAVED TO USER")
		}catch{
		  print("Failed to save token")
		}
		
	 }
  }
	 
//	 ON Open APP
	 func userNotificationCenter(
		  _ center: UNUserNotificationCenter,
		  willPresent notification: UNNotification,
		  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
	 ) {
		let userInfo = notification.request.content.userInfo
			 if let notificationChatID = userInfo["chatID"] as? String {
				  
				  let currentOpenChatID = NavigationManager.shared.chatId
				  
				  if notificationChatID == currentOpenChatID?.chatId {
						completionHandler([])
						return
				  }
				
				
				let title = notification.request.content.title
				let body = notification.request.content.body
				
				let message = MessageModel(id: notificationChatID, text: body, senderId: title, timestamp: Date())
				DispatchQueue.main.async {
				  NavigationManager.shared.message = message
				}
			 }
		
		completionHandler([[]])
	 }
  
//  TAP OnNotification
  func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse,
		withCompletionHandler completionHandler: @escaping () -> Void
  ) {
		let userInfo = response.notification.request.content.userInfo
		
		if let chatID = userInfo["chatID"] as? String {
		  print(chatID)
			 DispatchQueue.main.async {
				NavigationManager.shared.chatId = ChatNavigation(chatId: chatID)
			 }
		}
		
		completionHandler()
  }
}
