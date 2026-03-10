//
//  SearchUser.swift
//  ChatBook
//
//  Created by user on 09.03.2026.
//

import SwiftUI

struct SearchUser: View {
  let userName: String
    var body: some View {
      HStack(alignment: .bottom){
        Circle()
          .fill(.blue.opacity(0.5))
          .frame(height: 45)
        Spacer()
        VStack{
          Text(userName)
            .font(.headline)
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .bottom)
        Spacer()
      }
    }
}

#Preview {
    SearchUser(userName: "")
}
