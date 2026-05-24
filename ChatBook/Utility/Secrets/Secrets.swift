//
//  Secrets.swift
//  ChatBook
//
//  Created by user on 20.05.2026.
//

import Foundation

enum Secrets {
  static var agoraKey: String {
    guard let key = Bundle.main.infoDictionary?["AGORA_KEY"] as? String else {
      fatalError("AGORA_KEY missing from Info.plist")
    }

    let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, !trimmed.contains("$(") else {
      fatalError("AGORA_KEY is empty — link Secrets.xcconfig to the target (Configuration File), not Resources")
    }

    return trimmed
  }
}
