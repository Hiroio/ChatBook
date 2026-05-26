//
//  MessageCard.swift
//  ChatBook
//
//  Created by user on 26.05.2026.
//

import SwiftUI

struct MessageCard: View {
  @EnvironmentObject private var vm: ChatViewModel
  @State private var dragAmount: CGFloat = .zero
  @State private var isHorizontalDrag = false

  let message: MessageModel
  let native: Bool

  private let replyTrigger: CGFloat = -25
  private let maxDrag: CGFloat = -100

  var body: some View {
    VStack(alignment: .leading) {
      if let replyId = message.replyId {
        if let replyMessage = vm.messages.first(where: { $0.id == replyId }) {
          ReplyCard(
            replyText: replyMessage.text,
            replyFrom: vm.replyName(replyMessage.senderId)
          )
        } else {
          ReplyCard.deleted()
        }
      }
      HStack(alignment: .bottom, spacing: 6) {
        Text(message.text)

        switch message.localStatus {
        case .loading:
          Image(systemName: "progress.indicator")
            .font(.caption)
        case .failed:
          Image(systemName: "exclamationmark.circle.fill")
            .foregroundStyle(.red)
            .font(.caption)
        case .delivered:
          Text(message.timestamp.formatted(.dateTime.hour().minute()))
            .font(.caption2)
        }
      }
    }
    .padding(10)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(.white)
        .shadow(color: .blue.opacity(0.5), radius: 4)
    )
    .offset(x: dragAmount)
    .contentShape(Rectangle())
    .gesture(replyDragGesture)
    .onLongPressGesture(minimumDuration: 0.5) {
      vm.selectedMessage = message
    }
    .frame(maxWidth: .infinity, alignment: native ? .trailing : .leading)
    .background {
      if dragAmount < replyTrigger {
        Image(systemName: "arrowshape.turn.up.left.fill")
          .frame(maxWidth: .infinity, alignment: .trailing)
          .transition(.move(edge: native ? .trailing : .leading))
      }
    }
    .animation(.bouncy, value: dragAmount)
  }

  private var replyDragGesture: some Gesture {
    DragGesture(minimumDistance: 24)
      .onChanged { value in
        let width = value.translation.width
        let height = value.translation.height

        if !isHorizontalDrag {
          guard abs(width) > abs(height), abs(width) > 12 else { return }
          isHorizontalDrag = true
        }

        guard isHorizontalDrag, width < 0 else {
          dragAmount = 0
          return
        }

        dragAmount = max(width, maxDrag)
      }
      .onEnded { value in
        defer {
          dragAmount = 0
          isHorizontalDrag = false
        }

        guard isHorizontalDrag else { return }

        let width = value.translation.width
        let height = value.translation.height
        guard abs(width) > abs(height), width < replyTrigger else { return }

        vm.replyMessage = message
      }
  }
}

#Preview {
  MessageCard(message: .init(id: "qwe", text: "qwe", senderId: "qwe", timestamp: Date()), native: true)
    .environmentObject(ChatViewModel(chat: ChatNavigation(chatId: "")))
}
