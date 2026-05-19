//
//  UserDefaultsManager.swift
//  ChatBook
//
//  Created by user on 19.05.2026.
//

import Foundation


class UserDefaultsManager{
  static let shared = UserDefaultsManager()
  
  
  let userDefault = UserDefaults.standard
  
  
  var fcmToken: String {
	 get{
		userDefault.value(forKey: "fcmToken") as? String ?? ""
	 }
	 set{
		userDefault.setValue(newValue, forKey: "fcmToken")
	 }
  }
}
