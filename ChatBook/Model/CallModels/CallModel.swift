//
//  CallModel.swift
//  ChatBook
//
//  Created by user on 22.05.2026.
//

import Foundation

enum CallStatus: Equatable {
  case connecting
  case ringing
  case connected
  case ended
  case failed

  var title: String {
    switch self {
    case .connecting: return "Connecting…"
    case .ringing: return "Ongoing"
    case .connected: return "Call started"
    case .ended: return "Call ended"
    case .failed: return "Connection failed"
    }
  }

  var isInProgress: Bool {
    switch self {
    case .connecting, .ringing, .connected: return true
    case .ended, .failed: return false
    }
  }
}

enum CallDirection {
  case outgoing
  case incoming
}

struct CallModel {
  let chatID: String
  let oppositeUser: UserModel
  var isIncoming: Bool = false
}
