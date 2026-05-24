//
//  CallServiceFunction.swift
//  ChatBook
//
//  Created by user on 21.05.2026.
//

import Foundation
import FirebaseFunctions
import FirebaseCore

class CallService {
  static let shared = CallService()
  private let functions: Functions

  private init() {
    guard let app = FirebaseApp.app() else {
      fatalError("Firebase не ініціалізовано в AppDelegate")
    }
    self.functions = Functions.functions(app: app, region: "europe-central2")
  }

  // MARK: - Outgoing

  /// Triggers Cloud Function to send VoIP push to the receiver.
  func startRemoteCall(chatId: String, receiverId: String, callerName: String) async {
    let parameters: [String: Any] = [
      "chatId": chatId,
      "receiverId": receiverId,
      "callerName": callerName,
    ]

    print("Functions: Надсилання запиту на triggerVoIPCall...")

    do {
      let result = try await functions.httpsCallable("triggerVoIPCall").call(parameters)

      if let data = result.data as? [String: Any], let success = data["success"] as? Bool, success {
        print("Functions: Успішно відправлено!")
      } else {
        print("Functions: Бекенд повернув success: false")
      }
    } catch {
      print("Functions Error: \(error.localizedDescription)")
    }
  }
}
