//
//  UserManager.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import Foundation
import FirebaseFirestore
import FirebaseSharedSwift

class UserManager {
  static let shared = UserManager()
  
  private init(){}
  
  let userDefault = UserDefaultsManager.shared
  
  
  private let userCollection: CollectionReference = Firestore.firestore().collection("Users")
  
  func userDocument(userId: String) -> DocumentReference{
	 userCollection.document(userId)
  }
  
  func createNewUser(user: UserModel) async throws{
	 var userFS = FSUser(user: user)
	 userFS.isOnline = true
	 if !userDefault.fcmToken.isEmpty{
		userFS.fcmToken = userDefault.fcmToken
	 }
	 
	 try userDocument(userId: user.id).setData(from: userFS, merge: false, encoder: Firestore.Encoder())
  }
  
  func getUsersBySearch(text: String) async -> [FSUser]{
	 let queryEnd = text + "\u{f8ff}"
	 
	 guard let users = try? await userCollection
		.whereField("nickname", isGreaterThanOrEqualTo: text)
		.whereField("nickname", isLessThanOrEqualTo: queryEnd)
		.getDocumentsCustom() as [FSUser] else {
		return []
	 }
	 return users
  }
  
  func getUser() async -> UserModel?{
	 guard let id = AuthenticationManager.shared.user?.id else {return nil}
	 print("here user to find: \(id)")
	 return try? await userDocument(userId: id).getDocument(as: UserModel.self)
  }
  
  func getUser(by id: String) async -> UserModel?{
	 return try? await userDocument(userId: id).getDocument(as: UserModel.self)
  }
  
  
  func setFCMToken() async throws {
	 guard let id = AuthenticationManager.shared.user?.id else {return}
	 let token = UserDefaultsManager.shared.fcmToken
	 try await userDocument(userId: id).setData(["fcmToken": token], merge: true)
  }
  
  func setVoIPToken() async throws {
	 guard let id = AuthenticationManager.shared.user?.id else {return}
	 let token = UserDefaultsManager.shared.voIpToken
	 try await userDocument(userId: id).setData(["voipToken": token], merge: true)
	 
	 print("VoIP Token set : \(token)")
  }
  
  
  func initializeUser(online: Bool) async{
	 guard let id = AuthenticationManager.shared.user?.id else {return}
	 try? await userDocument(userId: id).setData(["isOnline": online], merge: true)
  }
  
}



extension UserManager{
  func updateProfileInAllChats(id: String, newNickname: String, newPhoto: String) async -> Bool {
	 let db = Firestore.firestore()
	 
	 try? await userDocument(userId: id).setData(["nickname": newNickname], merge: true)
	 
	 let snapshots = try? await db.collection("chats")
		.whereField("users", arrayContains: id)
		.getDocuments()
	 
	 let batch = db.batch()
	 
	 snapshots?.documents.forEach { doc in
		var previews = doc.data()["userPreviews"] as? [[String: Any]] ?? []
		
		for i in 0..<previews.count {
		  if previews[i]["id"] as? String == id {
			 previews[i]["nickname"] = newNickname
			 previews[i]["photoURL"] = newPhoto
		  }
		}
		
		batch.updateData(["userPreviews": previews], forDocument: doc.reference)
	 }
	 
	 try? await batch.commit()
	 return true
  }
}
