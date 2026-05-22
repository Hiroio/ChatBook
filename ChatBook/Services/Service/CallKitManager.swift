//
//  CallKitManager.swift
//  ChatBook
//
//  Created by user on 21.05.2026.
//

import Foundation
import CallKit
import AVFoundation

class CallKitManager: NSObject {
	 static let shared = CallKitManager()
	 
	 private let provider: CXProvider
	 private let callController = CXCallController()
	 private var currentCallUUID: UUID?
	 
	 private override init() {
		  let configuration = CXProviderConfiguration()
		  configuration.supportsVideo = false
		  configuration.maximumCallGroups = 1
		  configuration.maximumCallsPerCallGroup = 1
		  configuration.supportedHandleTypes = [.generic]
		  
		  self.provider = CXProvider(configuration: configuration)
		  
		  super.init()
		  
		  self.provider.setDelegate(self, queue: nil)
	 }
	 
	 //(Incoming Call)
	 func reportIncomingCall(uuid: UUID, handle: String) {
		  self.currentCallUUID = uuid
		  
		  let update = CXCallUpdate()
		  update.remoteHandle = CXHandle(type: .generic, value: handle)
		  update.hasVideo = false
		  
		  provider.reportNewIncomingCall(with: uuid, update: update) { error in
				if let error = error {
					 print("Помилка CallKit при спробі показати вхідний дзвінок: \(error.localizedDescription)")
				} else {
					 print("CallKit успішно відобразив системний екран вхідного виклику.")
				}
		  }
	 }
	 
	 // (Outgoing Call)
	 func startOutgoingCall(uuid: UUID, handle: String) {
		  self.currentCallUUID = uuid
		  let handleObj = CXHandle(type: .generic, value: handle)
		  
		  let startCallAction = CXStartCallAction(call: uuid, handle: handleObj)
		  
		  let transaction = CXTransaction(action: startCallAction)
		  callController.request(transaction) { error in
				if let error = error {
					 print("Помилка системи при запуску вихідного дзвінка: \(error.localizedDescription)")
				}
		  }
	 }
	 
//	Ending call on phone
	 func endCall() {
		  guard let uuid = currentCallUUID else { return }
		  
		  let endCallAction = CXEndCallAction(call: uuid)
		  
		  let transaction = CXTransaction(action: endCallAction)
		  callController.request(transaction) { error in
				if let error = error {
					 print("Помилка системи при спробі покласти слухавку: \(error.localizedDescription)")
				}
		  }
	 }
}

// MARK: - CXProviderDelegate
extension CallKitManager: CXProviderDelegate {
	 
	 // GREEN BTN Accept
	 func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
		  print("Делегат CallKit: Користувач підтвердив вхідний дзвінок.")
		  
		  CallManager.shared.configureAudioSession()
			 
//		TODO: AGORA CONNECT + NAVIGATION
		  action.fulfill()
	 }
	 
//	 AUTOMATIC leave
	 func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
		  print("Делегат CallKit: Фіксація завершення виклику.")
		  
//		AGORA
		  CallManager.shared.leaveChannel()
		  self.currentCallUUID = nil
		  
		  action.fulfill()
	 }
	 
	 func providerDidReset(_ provider: CXProvider) {
		  print("Делегат CallKit: Системний скид.")
		  CallManager.shared.leaveChannel()
		  self.currentCallUUID = nil
	 }
}
