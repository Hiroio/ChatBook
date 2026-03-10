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

class UserViewModel: ObservableObject{
  @Published var user: UserModel? = nil
  @Published var userNickname = ""
  @Published var userPhotoURL = ""
  @Published var selectedImage: UIImage? = nil
  
  private let userManager = UserManager.shared
  private let storageManager = StorageManager.shared
  
  init() {
    getUser()
  }
  
  func getUser(){
    Task{
      let user = await userManager.getUser()
      self.user = user
      self.userNickname = user?.nickname ?? ""
      self.userPhotoURL = user?.photoURL ?? ""
    }
  }
  
  func saveChanges(){
    if user?.nickname != userNickname || user?.photoURL != userPhotoURL{
      if let id = user?.id{
        Task(priority: .background){
          let state = await userManager.updateProfileInAllChats(id: id, newNickname: userNickname, newPhoto: userPhotoURL)
          if state{
            getUser()
          }
        }
      }
    }
  }
  
  func saveAvatar(from item: PhotosPickerItem?) async {
    guard let item = item else { return }
    
    do {
      if let data = try await item.loadTransferable(type: Data.self), let id = AuthenticationManager.shared.user?.id{
        let photoURL = try? await storageManager.uploadProfileImage(imageData: data, userId: id)
        userPhotoURL = photoURL ?? ""
        self.saveChanges()
      }
    }catch{
      print("failed To load")
    }
  }
}
