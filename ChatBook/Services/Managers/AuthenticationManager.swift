//
//  AuthenticationManager.swift
//  FireBaseBootCamp
//
//  Created by user on 06.02.2026.
//

import Foundation
import FirebaseAuth
import Combine

class AuthenticationManager: ObservableObject{
  static let shared = AuthenticationManager()
  
  @Published var user: UserModel? = nil
  
  private init() {
    user = try? getAuthentificatedUser()
    print("Current user", user)
  }
  
  private var currentUser: User? {
    Auth.auth().currentUser
  }
  
  func getAuthentificatedUser() throws -> UserModel{
    guard let user = Auth.auth().currentUser else {
      print("User not found")
      throw(URLError(.badURL))
    }
    
    return UserModel(user: user)
  }
  
  func signOut() throws{
    try Auth.auth().signOut()
    user = nil
  }
}


// MARK: Email functions
extension AuthenticationManager{
  func signUp(email: String, password: String) async throws {
    let createdUser = try await Auth.auth().createUser(withEmail: email, password: password)
    
    let newUser = UserModel(user: createdUser.user)
    user = newUser
    Task{
      try? await UserManager.shared.createNewUser(user: newUser)
    }
  }
  
  func updatePassword(password: String) async throws{
    guard let user = currentUser else{
      throw AuthErrors.userNotFound
    }
    try await user.updatePassword(to: password)
  }
  
  
}

// MARK: SignIn Annonymously
extension AuthenticationManager{
  //    Sign In Annonymously
  func signInAnonymously()async throws{
    let authDataResult = try await Auth.auth().signInAnonymously()
    let newUser = UserModel(user: authDataResult.user)
    user = newUser
    Task{
      try? await UserManager.shared.createNewUser(user: newUser)
    }
  }
  
  //    Link email + password
  func linkwithEmail(email: String, password: String)async throws -> UserModel{
    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
    
    return try await linkCredentional(credential)
  }
  
  
  private func linkCredentional(_ credential: AuthCredential) async throws -> UserModel{
      guard let user = Auth.auth().currentUser else {
          throw URLError(.badURL)
      }
      let result = try await user.link(with: credential)
      return UserModel(user: result.user)
  }
}



// MARK: Errors
enum AuthErrors: Error{
  case userNotFound
  case wrongCredentials
}
