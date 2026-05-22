//
//  UserVIewModel.swift
//  ChatBook
//
//  Created by user on 10.03.2026.
//

import Foundation
import Combine
import PhotosUI
import SwiftUI

@MainActor
final class UserViewModel: ObservableObject {
  @Published var userNickname = ""
  @Published var userPhotoURL = ""
  @Published var selectedImage: UIImage? = nil

  private let userManager = UserManager.shared
  private var cancellables = Set<AnyCancellable>()

  var user: UserModel? { userManager.currentUser }

  init() {
    userManager.$currentUser
      .receive(on: DispatchQueue.main)
      .sink { [weak self] user in
        self?.userNickname = user?.nickname ?? ""
        self?.userPhotoURL = user?.photoURL ?? ""
      }
      .store(in: &cancellables)
  }

  func saveChanges() {
    guard let user,
          user.nickname != userNickname || user.photoURL != userPhotoURL else { return }

    Task {
      try await userManager.updateProfileInAllChats(
        id: user.id,
        newNickname: userNickname,
        newPhoto: userPhotoURL
      )
    }
  }

  func reloadProfile() {
    Task {
      try? await userManager.loadCurrentUser()
    }
  }

  func saveAvatar(from item: PhotosPickerItem?) async {
    guard let item else { return }

    do {
      if try await item.loadTransferable(type: Data.self) != nil,
         userManager.currentUserId != nil {
        saveChanges()
      }
    } catch {
      print("failed To load")
    }
  }
}
