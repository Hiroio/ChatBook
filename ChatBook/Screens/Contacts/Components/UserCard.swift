//
//  UserCard.swift
//  ChatBook
//
//  Created by user on 22.05.2026.
//

import SwiftUI

struct UserCard: View {
  let user: UserModel
    var body: some View {
		HStack(alignment: .top, spacing: 15){
		  Image(systemName: "person")
			 .padding()
			 .background(
				Circle()
				  .fill(.mint)
			 )
		  VStack(alignment: .leading){
			 Text(user.nickname)
				.font(.title2)
		  }
		  .frame(maxWidth: .infinity, alignment: .leading)
		  
		  Button{}label: {
			 Image(systemName: "message")
				.padding()
				.background(
				  Circle()
					 .fill(.white)
					 .shadow(radius: 1)
				)
		  }
		}
		.padding()
		.background(
		  RoundedRectangle(cornerRadius: 20)
			 .fill(.white)
		)
    }
}

#Preview {
  UserCard(user: .preview)
}
