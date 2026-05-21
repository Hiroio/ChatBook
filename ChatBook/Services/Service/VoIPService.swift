//
//  VoIPService.swift
//  ChatBook
//
//  Created by user on 21.05.2026.
//

import Foundation
import PushKit
import CallKit

class VoIPService: NSObject, PKPushRegistryDelegate {
	 static let shared = VoIPService()
	 
	 private var voipRegistry: PKPushRegistry?
	 
  let userDefault = UserDefaultsManager.shared
  
	 private override init() {
		  super.init()
		  self.voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
		  self.voipRegistry?.delegate = self
		self.voipRegistry?.desiredPushTypes = [.voIP]
	 }
	 
	 func configure() {
		  print("PushKit підготовлено до реєстрації токена.")
	 }
	 
	 // MARK: - PKPushRegistryDelegate
	 func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
		  let tokenData = pushCredentials.token
		  let tokenString = tokenData.map { String(format: "%02.2hhx", $0) }.joined()
		  
		  print("Згенеровано унікальний VoIP Токен: \(tokenString)")
		  
		  saveVoIPTokenToFirestore(token: tokenString)
	 }
	 
	 func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
		  let customData = payload.dictionaryPayload["aps"] as? [String: Any]
		  let callerName = payload.dictionaryPayload["callerName"] as? String ?? "Вхідний виклики"
		  let callIDString = payload.dictionaryPayload["callId"] as? String ?? UUID().uuidString
		  
		  guard let callUUID = UUID(uuidString: callIDString) else {
				completion()
				return;
		  }
		  
		  CallKitManager.shared.reportIncomingCall(uuid: callUUID, handle: callerName)
		  
		  completion()
	 }
	 
  
//  Saving Token
  private func saveVoIPTokenToFirestore(token: String) {
	 Task{
		await MainActor.run {
		  userDefault.voIpToken = token
		}
//		guard token != userDefault.voIpToken else {return}
		
		do{
		  try await UserManager.shared.setVoIPToken()
		}catch{
		  print("Failed to save token")
		}
		
	 }
  }
}
