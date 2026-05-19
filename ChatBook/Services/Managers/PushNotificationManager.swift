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
		  Task {
				guard let user = await UserManager.shared.getUser() else {
					 await MainActor.run {
						  userDefault.fcmToken = token
					 }
					 print("User not found saved to userDefault")
					 return
				}
				
				print("User Found: \(user.id) saving token to fireStore")
				await UserManager.shared.setFCMToken(token: token)
				
				await MainActor.run {
					 self.userDefault.fcmToken = ""
				}
		  }
	 }
	 
	 // MARK: Sending notification if open
	 func userNotificationCenter(
		  _ center: UNUserNotificationCenter,
		  willPresent notification: UNNotification,
		  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
	 ) {
		  // TODO: Implement NavigationManager (if user currently in chatid == notification chatID then don't show the notification)
		  completionHandler([[.banner, .sound]])
	 }
}
