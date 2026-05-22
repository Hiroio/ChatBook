//
//  AuthenticationManager.swift
//  FireBaseBootCamp
//
//  Created by user on 06.02.2026.
//

import Foundation
import FirebaseAuth
import Combine

enum SessionState: Equatable {
  case loading
  case signedOut
  case signedIn
}

enum AuthError: Error {
  case userNotFound
  case wrongCredentials
  case notAuthenticated
}

@MainActor
final class AuthenticationManager: ObservableObject {
  static let shared = AuthenticationManager()

  @Published private(set) var sessionState: SessionState = .loading

  private let userManager = UserManager.shared

  private init() {
    Task { await bootstrapSession() }
  }

  // MARK: - Session

  func bootstrapSession() async {
    sessionState = .loading

    guard let firebaseUser = Auth.auth().currentUser else {
      userManager.clearCurrentUser()
      sessionState = .signedOut
      return
    }

    await restoreFirestoreUser(for: firebaseUser)
  }

  func signOut() throws {
    try Auth.auth().signOut()
    userManager.clearCurrentUser()
    sessionState = .signedOut
  }

  // MARK: - Email

  func signUp(email: String, password: String) async throws {
    let createdUser = try await Auth.auth().createUser(withEmail: email, password: password)
    try await finishSignIn(firebaseUser: createdUser.user)
  }

  func updatePassword(password: String) async throws {
    guard let user = Auth.auth().currentUser else {
      throw AuthError.userNotFound
    }
    try await user.updatePassword(to: password)
  }

  // MARK: - Anonymous

  func signInAnonymously() async throws {
    let authDataResult = try await Auth.auth().signInAnonymously()
    try await finishSignIn(firebaseUser: authDataResult.user)
  }

  func linkWithEmail(email: String, password: String) async throws -> UserModel {
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    return try await linkCredential(credential)
  }

  // MARK: - Private

  private func finishSignIn(firebaseUser: User) async throws {
    sessionState = .loading
    try await userManager.ensureUserDocument(
      email: firebaseUser.email,
      isAnonymous: firebaseUser.isAnonymous
    )
    sessionState = .signedIn
  }

  private func restoreFirestoreUser(for firebaseUser: User) async {
    do {
      try await userManager.loadCurrentUser()
      sessionState = .signedIn
    } catch {
      do {
        try await userManager.ensureUserDocument(
          email: firebaseUser.email,
          isAnonymous: firebaseUser.isAnonymous
        )
        sessionState = .signedIn
      } catch {
        try? Auth.auth().signOut()
        userManager.clearCurrentUser()
        sessionState = .signedOut
      }
    }
  }

  private func linkCredential(_ credential: AuthCredential) async throws -> UserModel {
    guard let user = Auth.auth().currentUser else {
      throw AuthError.notAuthenticated
    }

    let result = try await user.link(with: credential)
    return try await userManager.ensureUserDocument(
      email: result.user.email,
      isAnonymous: result.user.isAnonymous
    )
  }
}
