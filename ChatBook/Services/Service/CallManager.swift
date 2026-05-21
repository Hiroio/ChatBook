//
//  CallManager.swift
//  ChatBook
//
//  Created by user on 20.05.2026.
//

import Foundation
import AgoraRtcKit
import Combine
import AVFAudio

class CallManager: NSObject, AgoraRtcEngineDelegate, ObservableObject {
  static let shared = CallManager()
  
  @Published var statusMessage: String = ""
  private var agoraEngine: AgoraRtcEngineKit?
  let appId = Secrets.agoraKey
  
  private override init() {
	 super.init()
  }
  
  func initializeClient() {
	 let config = AgoraRtcEngineConfig()
	 config.appId = appId
	 
	 agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
	 agoraEngine?.setChannelProfile(.communication)
	 agoraEngine?.enableAudio()
	 
	 print("Agora Engine Successfully Initialized!")
  }
  
  func joinChannel(channelName: String) {
	 let options = AgoraRtcChannelMediaOptions()
	 options.channelProfile = .communication
	 options.clientRoleType = .broadcaster
	 options.publishMicrophoneTrack = true
	 options.autoSubscribeAudio = true
	 
	 Task {
		do {
		  let token = try await getToken(chatId: channelName)
		  
		  await MainActor.run {
			 let _ = agoraEngine?.joinChannel(
				byToken: token,
				channelId: channelName,
				uid: 0,
				mediaOptions: options
			 )
		  }
		} catch {
		  await MainActor.run {
			 self.statusMessage = "Failed to load token: \(error.localizedDescription)"
		  }
		  print("Failed to load token: \(error.localizedDescription)")
		}
	 }
  }
  
  func getToken(chatId: String) async throws -> String {
	 let baseUrl = "https://getagoratoken-d4ddbjwr6a-lm.a.run.app/getAgoraToken"
	 
	 guard AuthenticationManager.shared.user?.id != nil else {
		throw URLError(.userAuthenticationRequired)
	 }
	 
	 guard let url = URL(string: "\(baseUrl)?channelName=\(chatId)") else {
		throw URLError(.badURL)
	 }
	 
	 let (data, _) = try await URLSession.shared.data(from: url)
	 return try JSONDecoder().decode(AgoraTokenResponse.self, from: data).token
  }
  
  func leaveChannel() {
	 agoraEngine?.leaveChannel(nil)
	 DispatchQueue.main.async {
		self.statusMessage = "Дзвінок завершено"
		CallKitManager.shared.endCall()
	 }
  }
  
  func configureAudioSession() {
	 do {
		let audioSession = AVAudioSession.sharedInstance()
		try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetoothHFP, .allowBluetoothA2DP])
		try audioSession.setActive(true)
		print("AVAudioSession успішно конфігуровано.")
	 } catch {
		print("Помилка ініціалізації AVAudioSession: \(error.localizedDescription)")
	 }
  }
}

// MARK: - AgoraRtcEngineDelegate
extension CallManager {
  
  func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
	 print("Successfully joined channel: \(channel) with UID: \(uid)")
	 DispatchQueue.main.async {
		self.statusMessage = "Started Call"
	 }
  }
  
  func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
	 print("User \(uid) joined after \(elapsed) milliseconds")
	 DispatchQueue.main.async {
		self.statusMessage = "User Joined"
	 }
  }
  
  func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
	 print("User \(uid) left: Reason -> \(reason)")
	 DispatchQueue.main.async {
		self.statusMessage = "User left"
		
		self.leaveChannel()
	 }
  }
}
