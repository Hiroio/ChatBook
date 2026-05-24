//
//  CallKitManager.swift
//  ChatBook
//
//  Created by user on 21.05.2026.
//

import Foundation
import CallKit
import AVFoundation

/// Cached incoming call data until the user taps Answer.
struct PendingIncomingCall {
  let uuid: UUID
  let chatId: String
  let callerId: String
  let callerName: String
}

final class CallKitManager: NSObject {
  static let shared = CallKitManager()

  private let provider: CXProvider
  private let callController = CXCallController()
  private var currentCallUUID: UUID?
  private var pendingIncomingCall: PendingIncomingCall?
  private var isEndingCallFromApp = false

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

  // MARK: - Incoming

  func reportIncomingCall(uuid: UUID, handle: String, chatId: String, callerId: String) {
    currentCallUUID = uuid
    pendingIncomingCall = PendingIncomingCall(
      uuid: uuid,
      chatId: chatId,
      callerId: callerId,
      callerName: handle
    )

    let update = CXCallUpdate()
    update.remoteHandle = CXHandle(type: .generic, value: handle)
    update.hasVideo = false

    provider.reportNewIncomingCall(with: uuid, update: update) { error in
      if let error {
        print("CallKit incoming error: \(error.localizedDescription)")
      } else {
        print("CallKit incoming UI shown for chat \(chatId)")
      }
    }
  }

  // MARK: - Outgoing

  func startOutgoingCall(uuid: UUID, handle: String) {
    currentCallUUID = uuid
    let handleObj = CXHandle(type: .generic, value: handle)
    let startCallAction = CXStartCallAction(call: uuid, handle: handleObj)
    let transaction = CXTransaction(action: startCallAction)
    callController.request(transaction) { error in
      if let error {
        print("CallKit outgoing error: \(error.localizedDescription)")
      }
    }
  }

  /// Ends CallKit UI only when this device has an active CallKit call.
  func endCallIfNeeded() {
    guard let uuid = currentCallUUID else { return }

    isEndingCallFromApp = true
    let endCallAction = CXEndCallAction(call: uuid)
    let transaction = CXTransaction(action: endCallAction)
    callController.request(transaction) { [weak self] error in
      if let error {
        print("CallKit end error: \(error.localizedDescription)")
      }
      self?.isEndingCallFromApp = false
    }
  }

  // MARK: - Private

  private func clearCallState() {
    currentCallUUID = nil
    pendingIncomingCall = nil
  }

  @MainActor
  private func presentIncomingCallUI() async {
    guard let pending = pendingIncomingCall else {
      print("CallKit: no pending incoming call")
      return
    }

    CallManager.shared.warmUpEngine()

    let oppositeUser = await loadCallerUser(
      id: pending.callerId,
      fallbackName: pending.callerName
    )

    NavigationManager.shared.currentCall = CallModel(
      chatID: pending.chatId,
      oppositeUser: oppositeUser,
      isIncoming: true
    )

    print("CallKit: opened in-app call UI for chat \(pending.chatId)")
  }

  private func loadCallerUser(id: String, fallbackName: String) async -> UserModel {
    if let user = try? await UserManager.shared.fetchUser(id: id) {
      return user
    }

    var profile = UserModel.newProfile(id: id, email: nil, isAnonymous: false)
    profile.nickname = fallbackName
    return profile
  }

  /// Joins Agora after CallKit activates the audio session.
  private func joinIncomingAgoraChannelIfNeeded() {
    guard let chatId = pendingIncomingCall?.chatId else { return }
    print("CallKit: joining Agora channel \(chatId)")
    CallManager.shared.joinChannel(channelName: chatId)
  }
}

// MARK: - CXProviderDelegate

extension CallKitManager: CXProviderDelegate {

  func providerDidReset(_ provider: CXProvider) {
    Task { @MainActor in
      NavigationManager.shared.currentCall = nil
      CallManager.shared.leaveChannel(notifyCallKit: false)
      clearCallState()
    }
  }

  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    print("CallKit: user answered incoming call")
    action.fulfill()

    Task { @MainActor in
      await presentIncomingCallUI()
    }
  }

  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    print("CallKit: call ended from system UI")
    action.fulfill()

    guard !isEndingCallFromApp else {
      clearCallState()
      return
    }

    Task { @MainActor in
      NavigationManager.shared.currentCall = nil
      CallManager.shared.leaveChannel(notifyCallKit: false)
      clearCallState()
    }
  }

  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
    print("CallKit: audio session activated")
    CallManager.shared.configureAudioSession(callKitActivated: true)
    CallManager.shared.enableAudioForCall()
    joinIncomingAgoraChannelIfNeeded()
    NotificationCenter.default.post(name: .callKitAudioDidActivate, object: nil)
  }

  func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
    print("CallKit: audio session deactivated")
  }
}
