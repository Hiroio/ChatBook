//
//  ReplyCard.swift
//  ChatBook
//
//  Created by user on 26.05.2026.
//

import SwiftUI

struct ReplyCard: View {
  let replyText: String
  let replyFrom: String
  var isDeleted: Bool = false

  static func deleted() -> ReplyCard {
    ReplyCard(replyText: "Message deleted", replyFrom: "", isDeleted: true)
  }

  var body: some View {
    HStack {
      Rectangle()
        .frame(width: 1, height: 20)
      VStack(alignment: .leading) {
        if !isDeleted {
          Text("Reply from \(replyFrom)")
            .font(.footnote.weight(.semibold))
        }
        Text(replyText)
          .font(.footnote)
          .italic(isDeleted)
          .foregroundStyle(isDeleted ? .secondary : .primary)
          .lineLimit(1)
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 10)
    .background(
      RoundedRectangle(cornerRadius: 15)
        .fill(isDeleted ? Color.gray.opacity(0.12) : Color.blue.opacity(0.1))
    )
  }
}

#Preview {
    ReplyCard(replyText: "qweqweqw", replyFrom: "ME")
}
