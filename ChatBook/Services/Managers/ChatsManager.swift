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
  
  //  managers
  private var anyCancellables: Set<AnyCancellable> = []
  private let userManager = UserManager.shared
  
  //  Listeners
  private var chatsListener: ListenerRegistration?
  private var messageListener: ListenerRegistration?
  
  
  //  Collection FS
  private let chatCollection: CollectionReference = Firestore.firestore().collection("chats")
  
  //  MARK: Listener Functions
  
  
  
  
  //  MARK: Get chats for mainMenu
  func getUserChats() async -> [ChatModel]{
    guard let userId = userManager.currentUserId,
          let documents: [ChatModel] = try? await chatCollection
      .whereField("users", arrayContains: userId)
      .order(by: "timestamp", descending: true)
      .getDocumentsCustom() else{
      return []
    }
    return documents
  }
  
  //  MARK: Trying to find chat with user if not create
  func findOrCreateChat(with opponentId: String) async -> String {
    guard let myId = userManager.currentUserId else { return "" }
    let id = [myId, opponentId].sorted().joined(separator: "_")
    let chatRef = chatCollection.document(id)
    do {
      let document = try await chatRef.getDocument()
      
      if document.exists {
        return document.documentID
      } else {
        return await createNewChat(myId: myId, opponentId: opponentId)
      }
    } catch {
      print("Error: \(error)")
      return ""
    }
  }
  
  //  MARK: Creating chat for user if doesn't exist
  private func createNewChat(myId: String, opponentId: String) async -> String {
    let db = Firestore.firestore()
    
    let userFS = try? await userManager.userDocument(userId: myId).getDocument(as: UserModel.self)
    let opponentFS = try? await userManager.userDocument(userId: opponentId).getDocument(as: UserModel.self)
    
    let userPreviewData: [String: Any] = [
      "id": myId,
      "nickname": userFS?.nickname ?? "Unknown",
      "photoURL": userFS?.photoURL ?? ""
    ]
    
    let opponentPreviewData: [String: Any] = [
      "id": opponentId,
      "nickname": opponentFS?.nickname ?? "Unknown",
      "photoURL": opponentFS?.photoURL ?? ""
    ]
    
    let id = [myId, opponentId].sorted().joined(separator: "_")
    let newChatRef = db.collection("chats").document(id)
    
    let chatData: [String: Any] = [
      "id": id,
      "users": [myId, opponentId],
      "userPreviews": [userPreviewData, opponentPreviewData],
      "timestamp": FieldValue.serverTimestamp(),
      "lastMessage": "No messages yet"
    ]
    
    do {
      try await newChatRef.setData(chatData)
      return id
    } catch {
      print("Failed to create Chat \(error)")
      return ""
    }
  }
  
  //  MARK: GetChatForChatViewModel
  func getCurrentChat(for chatId: String) async throws -> ChatModel{
    try await chatCollection.document(chatId).getDocument(as: ChatModel.self)
  }
  
  
  func sentMessage(for chatId: String, text: String, senderId: String) throws{
    let chatDocument = chatCollection.document(chatId)
    
    let messageDocument = chatDocument.collection("messages").document()
    let newMessage: [String: Any] = [
      "id": messageDocument.documentID,
      "text": text,
      "senderId": senderId,
      "timestamp": FieldValue.serverTimestamp()
    ]
    
    messageDocument.setData(newMessage)
    
    let updatedFields: [String: Any] = [
      "lastMessage" : text,
      "timestamp": FieldValue.serverTimestamp()
    ]
    
    chatDocument.setData(updatedFields, merge: true)
  }
}


// MARK: Listeners
extension ChatManager{
//  MARK: Multiple Chats
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
  
  
//  MARK: Single chat
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
  
//  Single User
  func listenUser(userId: String) -> AnyPublisher<UserModel, Error> {
	 let subject = PassthroughSubject<UserModel, Error>()
	 
	 let query = Firestore.firestore().collection("Users")
		.document(userId)

	 let listener = query.addSnapshotListener { snapshot, error in
		  if let error = error {
				subject.send(completion: .failure(error))
				return
		  }
		  
		if let user = try? snapshot?.data(as: UserModel.self){
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
