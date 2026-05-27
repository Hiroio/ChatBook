//
//  ChatManager.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import Foundation
import FirebaseFirestore
import FirebaseSharedSwift
import Combine

class ChatManager {
  static let shared = ChatManager()

  private init() {}

  private var anyCancellables: Set<AnyCancellable> = []
  private let userManager = UserManager.shared

  private var chatsListener: ListenerRegistration?
  private var messageListener: ListenerRegistration?

  private let chatCollection: CollectionReference = Firestore.firestore().collection("chats")

  // MARK: - Chats

  func getUserChats() async -> [ChatModel] {
    guard let userId = userManager.currentUserId,
          let documents: [ChatModel] = try? await chatCollection
      .whereField("users", arrayContains: userId)
      .order(by: "timestamp", descending: true)
      .getDocumentsCustom() else {
      return []
    }
    return documents
  }

  /// Returns chat navigation data. `exist: false` when the document is not created yet.
  func findOrCreateChatID(with opponentId: String) async throws -> ChatNavigation {
    guard let myId = userManager.currentUserId else { throw URLError(.userAuthenticationRequired) }

    let id = [myId, opponentId].sorted().joined(separator: "_")
    let chatRef = chatCollection.document(id)
    let document = try await chatRef.getDocument()

    if document.exists {
      return ChatNavigation(chatId: document.documentID)
    } else {
      return ChatNavigation(chatId: id, exist: false)
    }
  }

  func createNewChat(myId: String, opponentId: String) async throws -> String {
    let userFS = try? await userManager.userDocument(userId: myId).getDocument(as: UserModel.self)
    let opponentFS = try? await userManager.userDocument(userId: opponentId).getDocument(as: UserModel.self)

    let userPreviewData: [String: Any] = [
      "id": myId,
      "nickname": userFS?.nickname ?? "Unknown",
      "photoURL": userFS?.photoURL ?? "",
    ]

    let opponentPreviewData: [String: Any] = [
      "id": opponentId,
      "nickname": opponentFS?.nickname ?? "Unknown",
      "photoURL": opponentFS?.photoURL ?? "",
    ]

    let id = [myId, opponentId].sorted().joined(separator: "_")
    let newChatRef = chatCollection.document(id)

    let chatData: [String: Any] = [
      "id": id,
      "users": [myId, opponentId],
      "userPreviews": [userPreviewData, opponentPreviewData],
      "timestamp": FieldValue.serverTimestamp(),
      "lastMessage": "No messages yet",
    ]

    try await newChatRef.setData(chatData)
    return id
  }

  func getCurrentChat(for chatId: String) async throws -> ChatModel {
    try await chatCollection.document(chatId).getDocument(as: ChatModel.self)
  }
  
  func deleteChat(_ id: String) async throws{
	 try await chatCollection.document(id).delete()
  }

  // MARK: - Messages

  /// Creates a message document reference so the id is known before Firestore write.
  func makeMessageDocument(chatId: String) -> DocumentReference {
    chatCollection.document(chatId).collection("messages").document()
  }

  // Writes the message and updates chat metadata.
  func sendMessage(
    chatId: String,
    messageId: String,
    text: String,
	 replyId: String?,
    senderId: String
  ) async throws {
    let chatDocument = chatCollection.document(chatId)
    let messageDocument = chatDocument.collection("messages").document(messageId)

    let newMessage: [String: Any] = [
      "id": messageId,
      "text": text,
		"replyId": replyId as Any,
      "senderId": senderId,
      "timestamp": FieldValue.serverTimestamp(),
    ]

    try await messageDocument.setData(newMessage)

    let updatedFields: [String: Any] = [
      "lastMessage": text,
      "timestamp": FieldValue.serverTimestamp(),
    ]

    try await chatDocument.setData(updatedFields, merge: true)
  }
  
  func messageDocument(chatId: String, messageId: String) -> DocumentReference {
    chatCollection.document(chatId).collection("messages").document(messageId)
  }

  func editMessage(chatId: String, text: String, messageId: String) async throws {
    try await messageDocument(chatId: chatId, messageId: messageId)
      .setData(["text": text], merge: true)
  }

  func deleteMessage(chatId: String, messageId: String) async throws {
    try await messageDocument(chatId: chatId, messageId: messageId).delete()
  }
}

// MARK: - Listeners

extension ChatManager {

  func chatsPublisher(userId: String) -> AnyPublisher<[ChatModel], Error> {
    let subject = PassthroughSubject<[ChatModel], Error>()

    let query = chatCollection
      .whereField("users", arrayContains: userId)
      .order(by: "timestamp", descending: true)

    let listener = query.addSnapshotListener { snapshot, error in
      if let error = error {
        subject.send(completion: .failure(error))
        return
      }

      let chats = snapshot?.documents.compactMap { doc in
        try? doc.data(as: ChatModel.self)
      } ?? []

      subject.send(chats)
    }
    return subject
      .handleEvents(receiveCancel: {
        listener.remove()
      })
      .eraseToAnyPublisher()
  }

  func listenToMessages(chatId: String) -> AnyPublisher<[MessageModel], Error> {
    let subject = PassthroughSubject<[MessageModel], Error>()

    let query = chatCollection
      .document(chatId)
      .collection("messages")
      .order(by: "timestamp", descending: false)

    let listener = query.addSnapshotListener { snapshot, error in
      if let error = error {
        subject.send(completion: .failure(error))
        return
      }

      let messages = snapshot?.documents.compactMap { doc in
        try? doc.data(as: MessageModel.self)
      } ?? []

      subject.send(messages)
    }
    return subject
      .handleEvents(receiveCancel: {
        listener.remove()
      })
      .eraseToAnyPublisher()
  }

  func listenUser(userId: String) -> AnyPublisher<UserModel, Error> {
    let subject = PassthroughSubject<UserModel, Error>()

    let query = Firestore.firestore().collection("Users")
      .document(userId)

    let listener = query.addSnapshotListener { snapshot, error in
      if let error = error {
        subject.send(completion: .failure(error))
        return
      }

      if let user = try? snapshot?.data(as: UserModel.self) {
        subject.send(user)
      }
    }
    return subject
      .handleEvents(receiveCancel: {
        listener.remove()
      })
      .eraseToAnyPublisher()
  }
}
