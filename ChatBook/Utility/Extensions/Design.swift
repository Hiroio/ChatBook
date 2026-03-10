//
//  Design.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import Foundation
import SwiftUI


extension RadialGradient {
    static var background: RadialGradient {
      RadialGradient(colors: [.blue.opacity(0.2), .white.opacity(0.5)], center: .center, startRadius: 500, endRadius: 10)
    }
}
