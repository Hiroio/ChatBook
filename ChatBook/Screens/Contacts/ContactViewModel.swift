//
//  ContactViewModel.swift
//  ChatBook
//
//  Created by user on 22.05.2026.
//

import Foundation
import Combine

class ContactViewModel: ObservableObject{
  @Published var users: [UserModel] = []
  
  private let userManager = UserManager.shared
  
  init(){
	 fetchUsers()
  }
  
  func fetchUsers(){
	 Task{
		let users = try? await userManager.fetchUsers()
		
		await MainActor.run {
		  self.users = users ?? []
		}
	 }
  }
}
