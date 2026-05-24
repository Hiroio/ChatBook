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

extension Notification.Name {
  static let callKitAudioDidActivate = Notification.Name("callKitAudioDidActivate")
}

class CallManager: NSObject, AgoraRtcEngineDelegate, ObservableObject {
  static let shared = CallManager()

  @Published private(set) var callStatus: CallStatus = .connecting
  @Published private(set) var isMuted = false

  private var agoraEngine: AgoraRtcEngineKit?
  private var currentChannelName: String?
  private var hasJoinedChannel = false
  private var isJoining = false

  let appId = Secrets.agoraKey

  private override init() {
    super.init()
  }

  // MARK: - Setup

  /// Creates the shared engine. Does not enable the microphone yet.
  func warmUpEngine() {
    guard agoraEngine == nil else { return }

    guard !appId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      print("Agora: AGORA_KEY is empty — check Secrets.xcconfig / Info.plist")
      return
    }

    let config = AgoraRtcEngineConfig()
    config.appId = appId

    let engine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
    engine.setChannelProfile(.communication)
    agoraEngine = engine

    print("Agora engine ready (appId prefix: \(appId.prefix(8))…)")
  }

  /// Enables Agora audio — call after AVAudioSession is configured.
  func enableAudioForCall() {
    warmUpEngine()
    agoraEngine?.enableAudio()
  }

  func configureAudioSession(callKitActivated: Bool = false) {
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(
        .playAndRecord,
        mode: .voiceChat,
        options: [.defaultToSpeaker, .allowBluetoothHFP, .allowBluetoothA2DP]
      )

      if !callKitActivated {
        try audioSession.setActive(true)
      }

      print("AVAudioSession configured (callKitActivated: \(callKitActivated))")
    } catch {
      print("AVAudioSession error: \(error.localizedDescription)")
    }
  }

  // MARK: - Channel

  func joinChannel(channelName: String) {
    guard !isJoining else {
      print("Agora: join already in progress")
      return
    }

    isJoining = true
    currentChannelName = channelName

    DispatchQueue.main.async {
      self.callStatus = .connecting
    }

    Task {
      defer { isJoining = false }

      if hasJoinedChannel {
        print("Agora: leaving previous channel before join")
        await leaveChannelAsync(notifyCallKit: false)
      }

      enableAudioForCall()

      guard agoraEngine != nil else {
        await MainActor.run { self.callStatus = .failed }
        print("Agora: engine is nil, cannot join")
        return
      }

      do {
        let token = try await getToken(chatId: channelName)

        let options = AgoraRtcChannelMediaOptions()
        options.channelProfile = .communication
        options.clientRoleType = .broadcaster
        options.publishMicrophoneTrack = true
        options.autoSubscribeAudio = true

        await MainActor.run {
          print("Agora joining channel: \(channelName)")
          let result = self.agoraEngine?.joinChannel(
            byToken: token,
            channelId: channelName,
            uid: 0,
            mediaOptions: options
          ) ?? -7

          if result == 0 {
            self.hasJoinedChannel = true
          } else {
            print("Agora joinChannel error: \(result) (\(Self.describeJoinError(result)))")
            self.callStatus = .failed
          }
        }
      } catch {
        await MainActor.run { self.callStatus = .failed }
        print("Agora token error: \(error.localizedDescription)")
      }
    }
  }

  func leaveChannel(notifyCallKit: Bool = true) {
    Task {
      await leaveChannelAsync(notifyCallKit: notifyCallKit)
    }
  }

  private func leaveChannelAsync(notifyCallKit: Bool) async {
    currentChannelName = nil
    hasJoinedChannel = false
    agoraEngine?.leaveChannel(nil)

    await MainActor.run {
      self.callStatus = .ended
      self.isMuted = false

      if notifyCallKit {
        CallKitManager.shared.endCallIfNeeded()
      }
    }
  }

  func getToken(chatId: String) async throws -> String {
    let baseUrl = "https://getagoratoken-d4ddbjwr6a-lm.a.run.app/getAgoraToken"

    guard UserManager.shared.currentUserId != nil else {
      throw URLError(.userAuthenticationRequired)
    }

    var components = URLComponents(string: baseUrl)
    components?.queryItems = [URLQueryItem(name: "channelName", value: chatId)]

    guard let url = components?.url else {
      throw URLError(.badURL)
    }

    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(AgoraTokenResponse.self, from: data).token
  }

  // MARK: - Mute

  func setMuted(_ muted: Bool) {
    isMuted = muted
    agoraEngine?.muteLocalAudioStream(muted)
  }

  func toggleMute() {
    setMuted(!isMuted)
  }

  private static func describeJoinError(_ code: Int32) -> String {
    switch code {
    case -7: return "not initialized / engine not ready"
    case -17: return "join rejected — check token or App ID"
    default: return "see AgoraErrorCode"
    }
  }
}

// MARK: - AgoraRtcEngineDelegate

extension CallManager {

  func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
    print("Agora joined channel: \(channel) uid: \(uid)")
    hasJoinedChannel = true
    DispatchQueue.main.async {
      self.callStatus = .ringing
    }
  }

  func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
    print("Agora remote user joined: \(uid)")
    DispatchQueue.main.async {
      self.callStatus = .connected
    }
  }

  func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
    print("Agora remote user offline: \(uid)")
    DispatchQueue.main.async {
      self.callStatus = .ended
      self.leaveChannel(notifyCallKit: true)
    }
  }

  func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
    print("Agora error: \(errorCode.rawValue) (\(Self.describeAgoraError(errorCode)))")
    if errorCode == .invalidAppId {
      print("Agora: App ID in the app must match agoraAppId in functions/stream-keys.json")
    }
  }

  private static func describeAgoraError(_ code: AgoraErrorCode) -> String {
    switch code {
    case .invalidAppId: return "invalid App ID"
    case .notInitialized: return "not initialized"
    case .tokenExpired: return "token expired"
    case .invalidToken: return "invalid token"
    default: return "code \(code.rawValue)"
    }
  }
}
