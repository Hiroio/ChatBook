//
//  Secrets.swift
//  ChatBook
//
//  Created by user on 20.05.2026.
//

import Foundation

enum Secrets{
  static var agoraKey: String{
	 guard let key = Bundle.main.infoDictionary?["AGORA_KEY"] as? String else {
		fatalError("AGORA Key not found")
	 }
	 
	 return key
  }
}
