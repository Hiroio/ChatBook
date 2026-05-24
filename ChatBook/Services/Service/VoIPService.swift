//
//  VoIPService.swift
//  ChatBook
//
//  Created by user on 21.05.2026.
//

import Foundation
import PushKit
import CallKit

final class VoIPService: NSObject, PKPushRegistryDelegate {
  static let shared = VoIPService()

  private var voipRegistry: PKPushRegistry?
  private let userDefault = UserDefaultsManager.shared

  private override init() {
    super.init()
    voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
    voipRegistry?.delegate = self
    voipRegistry?.desiredPushTypes = [.voIP]
  }

  func configure() {
    print("PushKit ready for VoIP token registration.")
  }

  // MARK: - PKPushRegistryDelegate

  func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
    let tokenString = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
    print("VoIP token: \(tokenString)")
    saveVoIPTokenToFirestore(token: tokenString)
  }

  func pushRegistry(
    _ registry: PKPushRegistry,
    didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType,
    completion: @escaping () -> Void
  ) {
    let data = payload.dictionaryPayload

    let chatId = data["chatId"] as? String
    let callerId = data["callerId"] as? String
    let callerName = data["callerName"] as? String ?? "Incoming call"

    guard let chatId, let callerId else {
      print("VoIP push missing chatId or callerId. Keys: \(data.keys)")
      completion()
      return
    }

    let callUUID = UUID()

    CallKitManager.shared.reportIncomingCall(
      uuid: callUUID,
      handle: callerName,
      chatId: chatId,
      callerId: callerId
    )

    completion()
  }

  // MARK: - Firestore

  private func saveVoIPTokenToFirestore(token: String) {
    Task {
      let previous = await MainActor.run { userDefault.voIpToken }
      guard token != previous else { return }

      await MainActor.run {
        userDefault.voIpToken = token
      }

      do {
        try await UserManager.shared.setVoIPToken()
      } catch {
        print("Failed to save VoIP token: \(error.localizedDescription)")
      }
    }
  }
}
