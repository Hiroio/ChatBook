//
//  CallViewModel.swift
//  ChatBook
//
//  Created by user on 20.05.2026.
//

import Foundation
import Combine

@MainActor
final class CallViewModel: ObservableObject {
  @Published private(set) var callStatus: CallStatus = .connecting
  @Published private(set) var formattedDuration = "00:00"
  @Published private(set) var isMuted = false

  let callManager = CallManager.shared
  let chatId: String
  let oppositeUser: UserModel

  private let direction: CallDirection

  var showsCallTimer: Bool {
    callStatus == .ringing || callStatus == .connected
  }

  private var cancellables = Set<AnyCancellable>()
  private var durationTimer: AnyCancellable?
  private var callStartedAt: Date?

  init(chatId: String, oppositeUser: UserModel, direction: CallDirection = .outgoing) {
    self.chatId = chatId
    self.oppositeUser = oppositeUser
    self.direction = direction
    listenToCallManager()

    switch direction {
    case .outgoing:
      startOutgoingCall()
    case .incoming:
      joinIncomingCall()
    }
  }

  // MARK: - Actions

  func leaveCall() {
    stopDurationTimer()
    callManager.leaveChannel()
    callStatus = .ended
  }

  func toggleMute() {
    callManager.toggleMute()
  }

  // MARK: - Start

  private func startOutgoingCall() {
    CallManager.shared.configureAudioSession(callKitActivated: false)
    callManager.joinChannel(channelName: chatId)
    sendVoIPRequest()
  }

  private func joinIncomingCall() {
    // Incoming join happens in CallKitManager.didActivate after audio session is ready.
  }

  // MARK: - CallManager

  private func listenToCallManager() {
    callManager.$callStatus
      .receive(on: DispatchQueue.main)
      .sink { [weak self] status in
        self?.applyCallStatus(status)
      }
      .store(in: &cancellables)

    callManager.$isMuted
      .receive(on: DispatchQueue.main)
      .assign(to: &$isMuted)
  }

  private func applyCallStatus(_ status: CallStatus) {
    callStatus = status

    switch status {
    case .ringing:
      startDurationTimerIfNeeded()
    case .connected:
      break
    case .ended, .failed:
      stopDurationTimer()
    case .connecting:
      stopDurationTimer()
      formattedDuration = "00:00"
    }
  }

  // MARK: - Timer

  private func startDurationTimerIfNeeded() {
    guard durationTimer == nil else { return }

    callStartedAt = Date()
    formattedDuration = "00:00"

    durationTimer = Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.updateFormattedDuration()
      }
  }

  private func stopDurationTimer() {
    durationTimer?.cancel()
    durationTimer = nil
    callStartedAt = nil
  }

  private func updateFormattedDuration() {
    guard let callStartedAt else { return }
    let elapsed = Int(Date().timeIntervalSince(callStartedAt))
    formattedDuration = Self.formatDuration(elapsed)
  }

  private static func formatDuration(_ totalSeconds: Int) -> String {
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60

    if hours > 0 {
      return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    return String(format: "%02d:%02d", minutes, seconds)
  }

  // MARK: - VoIP

  private func sendVoIPRequest() {
    Task {
      let nickname = UserManager.shared.currentUser?.nickname ?? ""

      await CallService.shared.startRemoteCall(
        chatId: chatId,
        receiverId: oppositeUser.id,
        callerName: nickname
      )
    }
  }
}
