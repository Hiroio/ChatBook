//
//  UserManager.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseSharedSwift

enum UserManagerError: Error {
  case notAuthenticated
  case userNotFound
}

@MainActor
final class UserManager: ObservableObject {
  static let shared = UserManager()

  @Published private(set) var currentUser: UserModel?

  private let userDefaults = UserDefaultsManager.shared
  private let userCollection = Firestore.firestore().collection("Users")

  private init() {}

  var currentUserId: String? {
    Auth.auth().currentUser?.uid
  }

  // MARK: - References

  func userDocument(userId: String) -> DocumentReference {
    userCollection.document(userId)
  }

  // MARK: - Session (current user)

  func loadCurrentUser() async throws -> UserModel {
    guard let id = currentUserId else { throw UserManagerError.notAuthenticated }

    let user = try await userDocument(userId: id).getDocument(as: UserModel.self)
    currentUser = user
    return user
  }

  func ensureUserDocument(email: String?, isAnonymous: Bool) async throws -> UserModel {
    guard let id = currentUserId else { throw UserManagerError.notAuthenticated }

    let document = userDocument(userId: id)
    let snapshot = try await document.getDocument()

    if snapshot.exists {
      try await document.setData(sessionFields(), merge: true)
    } else {
      var user = UserModel.newProfile(id: id, email: email, isAnonymous: isAnonymous)
      user.fcmToken = userDefaults.fcmToken
      user.voipToken = userDefaults.voIpToken
      try document.setData(from: user, merge: false, encoder: Firestore.Encoder())
    }

    let user = try await document.getDocument(as: UserModel.self)
    currentUser = user
    return user
  }

  func clearCurrentUser() {
    currentUser = nil
  }

  // MARK: - Fetch (by id)

  func fetchUser(id: String) async throws -> UserModel {
    try await userDocument(userId: id).getDocument(as: UserModel.self)
  }
  
  func fetchUsers() -> some Publisher<[UserModel], Error>{
	 let subject = PassthroughSubject<[UserModel], Error>()
	 
	 let listener = userCollection.addSnapshotListener { snapshot, error in
		  if let error = error {
				subject.send(completion: .failure(error))
				return
		  }
		  
		  let users = snapshot?.documents.compactMap { doc in
				try? doc.data(as: UserModel.self)
		  } ?? []
		  
		  subject.send(users)
	 }
	 
	 return subject
		  .handleEvents(receiveCancel: {
				listener.remove()
		  })
		  .eraseToAnyPublisher()
	 
  }

  // MARK: - Search

  func searchUsers(nicknamePrefix text: String) async throws -> [UserModel] {
    let queryEnd = text + "\u{f8ff}"

    return try await userCollection
      .whereField("nickname", isGreaterThanOrEqualTo: text)
      .whereField("nickname", isLessThanOrEqualTo: queryEnd)
      .getDocumentsCustom()
  }

  // MARK: - Profile updates

  func setOnline(_ isOnline: Bool) async throws {
    try await setValue(for: .isOnline(isOnline))
  }

  func setFCMToken() async throws {
    try await setValue(for: .fcmToken(userDefaults.fcmToken))
  }

  func setVoIPToken() async throws {
    try await setValue(for: .voipToken(userDefaults.voIpToken))
  }

  func setValue(for field: UserFields) async throws {
    guard let id = currentUserId else { throw UserManagerError.notAuthenticated }

    try await userDocument(userId: id).setData([field.key: field.anyValue], merge: true)
    currentUser = try await loadCurrentUser()
  }

  func updateProfileInAllChats(id: String, newNickname: String, newPhoto: String) async throws {
    let db = Firestore.firestore()

    try await userDocument(userId: id).setData(["nickname": newNickname, "photoURL": newPhoto], merge: true)

    let snapshots = try await db.collection("chats")
      .whereField("users", arrayContains: id)
      .getDocuments()

    let batch = db.batch()

    snapshots.documents.forEach { doc in
      var previews = doc.data()["userPreviews"] as? [[String: Any]] ?? []

      for index in previews.indices where previews[index]["id"] as? String == id {
        previews[index]["nickname"] = newNickname
		  previews[index]["nicknameLowered"] = newNickname.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        previews[index]["photoURL"] = newPhoto
      }

      batch.updateData(["userPreviews": previews], forDocument: doc.reference)
    }

    try await batch.commit()

    if id == currentUserId {
      currentUser = try await loadCurrentUser()
    }
  }

  // MARK: - Private

  private func sessionFields() -> [String: Any] {
    [
      "fcmToken": userDefaults.fcmToken,
      "voipToken": userDefaults.voIpToken,
      "isOnline": true,
    ]
  }
}

enum UserFields {
  case nickname(String)
  case fcmToken(String)
  case voipToken(String)
  case isOnline(Bool)

  var key: String {
    switch self {
    case .nickname: return "nickname"
    case .fcmToken: return "fcmToken"
    case .voipToken: return "voipToken"
    case .isOnline: return "isOnline"
    }
  }

  var anyValue: Any {
    switch self {
    case .nickname(let value): return value
    case .fcmToken(let value): return value
    case .voipToken(let value): return value
    case .isOnline(let value): return value
    }
  }
}
