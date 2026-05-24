//
//  ChatViewModel.swift
//  ChatBook
//
//  Created by user on 09.03.2026.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
class ChatViewModel: ObservableObject {
  @Published var otherUser: UserModel?
  @Published var currentChat: ChatModel?
  /// Merged list for UI: Firestore messages + local pending/failed rows.
  @Published var messages: [MessageModel] = []
  @Published var exist: Bool = false

  let chatManager = ChatManager.shared
  var userId: String? { UserManager.shared.currentUserId }

  let chatId: String

  private var cancellables = Set<AnyCancellable>()
  private var serverMessages: [MessageModel] = []
  private var pendingById: [String: MessageModel] = [:]
  private var pendingTimeouts: [String: Task<Void, Never>] = [:]
  private var isListeningToMessages = false

  private let pendingTimeoutSeconds: UInt64 = 15

  init(chat: ChatNavigation) {
    chatId = chat.chatId
    exist = chat.exist
    initializeChat(id: chatId)
  }

  deinit {
    pendingTimeouts.values.forEach { $0.cancel() }
  }

  // MARK: - Setup

  func initializeChat(id: String) {
    if exist {
      getChat(id: id)
      fetchMessages(chatId: id)
    } else if let opposideUserId {
      getOppositeUser(with: opposideUserId)
    }
  }

  func getChat(id chatId: String) {
    Task {
      let chat = try? await chatManager.getCurrentChat(for: chatId)
      self.currentChat = chat

      if let opposideUserId {
        getOppositeUser(with: opposideUserId)
      }
    }
  }

  func getOppositeUser(with id: String) {
    chatManager.listenUser(userId: id)
      .receive(on: DispatchQueue.main)
      .sink { completion in
        if case .failure(let error) = completion {
          print("Error: \(error)")
        }
      } receiveValue: { [weak self] user in
        self?.otherUser = user
      }
      .store(in: &cancellables)
  }

  func fetchMessages(chatId: String) {
    guard !isListeningToMessages else { return }
    isListeningToMessages = true

    chatManager.listenToMessages(chatId: chatId)
      .receive(on: DispatchQueue.main)
      .sink { completion in
        if case .failure(let error) = completion {
          print("error: \(error.localizedDescription)")
        }
      } receiveValue: { [weak self] messages in
        self?.applyServerMessages(messages)
      }
      .store(in: &cancellables)
  }

  // MARK: - Send

  func sendMessage(text: String) {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let userId, !trimmed.isEmpty else { return }

    Task {
      var outboundMessageId: String?

      do {
        let activeChatId = try await resolveChatIdForSending(userId: userId)
        let messageId = chatManager.makeMessageDocument(chatId: activeChatId).documentID
        outboundMessageId = messageId

        let pendingMessage = MessageModel(
          id: messageId,
          text: trimmed,
          senderId: userId,
          timestamp: Date(),
          localStatus: .loading
        )

        addPending(pendingMessage)

        try await chatManager.sendMessage(
          chatId: activeChatId,
          messageId: messageId,
          text: trimmed,
          senderId: userId
        )
      } catch {
        print("failed to send message: \(error.localizedDescription)")
        if let outboundMessageId {
          markFailed(messageId: outboundMessageId)
        }
      }
    }
  }

  /// Creates the chat document and starts the listener before the first message.
  private func resolveChatIdForSending(userId: String) async throws -> String {
    if exist {
      return chatId
    }

    guard let opponentId = opposideUserId else {
      throw URLError(.badURL)
    }

    let createdChatId = try await chatManager.createNewChat(myId: userId, opponentId: opponentId)
    exist = true
    getChat(id: createdChatId)
    fetchMessages(chatId: createdChatId)
    return createdChatId
  }

  var opposideUserId: String? {
    guard let currentUserId = userId else { return nil }

    if let substringResult = chatId.split(separator: "_").first(where: { String($0) != currentUserId }) {
      return String(substringResult)
    }

    return nil
  }
}

// MARK: - Pending merge

extension ChatViewModel {

  /// Shows an optimistic row immediately after send.
  private func addPending(_ message: MessageModel) {
    pendingById[message.id] = message
    rebuildMessages()
    scheduleTimeout(for: message.id)
  }

  /// Updates the Firestore snapshot and merges pending rows.
  private func applyServerMessages(_ serverMessages: [MessageModel]) {
    self.serverMessages = serverMessages
    rebuildMessages()
  }

  /// Builds `messages` from server data plus pending rows not yet in Firestore.
  private func rebuildMessages() {
    let serverIds = Set(serverMessages.map(\.id))

    for id in serverIds where pendingById[id] != nil {
      cancelTimeout(for: id)
    }

    pendingById = pendingById.filter { id, message in
      if serverIds.contains(id) {
        return false
      }
      return message.localStatus != .delivered
    }

    let pending = pendingById.values.sorted { $0.timestamp < $1.timestamp }
    messages = serverMessages + pending
  }

  private func markFailed(messageId: String) {
    guard var message = pendingById[messageId] else { return }

    message.localStatus = .failed
    pendingById[messageId] = message
    cancelTimeout(for: messageId)
    rebuildMessages()
  }

  /// Marks the message as failed if the listener never confirms it.
  private func scheduleTimeout(for messageId: String) {
    pendingTimeouts[messageId]?.cancel()

    pendingTimeouts[messageId] = Task { [weak self] in
      try? await Task.sleep(nanoseconds: (self?.pendingTimeoutSeconds ?? 15) * 1_000_000_000)
      guard !Task.isCancelled else { return }

      await MainActor.run {
        guard let self,
              self.pendingById[messageId]?.localStatus == .loading else { return }
        self.markFailed(messageId: messageId)
      }
    }
  }

  private func cancelTimeout(for messageId: String) {
    pendingTimeouts[messageId]?.cancel()
    pendingTimeouts[messageId] = nil
  }
}
