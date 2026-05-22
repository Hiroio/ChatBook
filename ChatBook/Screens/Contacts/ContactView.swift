//
//  ContactView.swift
//  ChatBook
//
//  Created by user on 22.05.2026.
//

import SwiftUI

struct ContactView: View {
  @StateObject private var vm = ContactViewModel()
    var body: some View {
		ZStack{
		  RadialGradient.background.ignoresSafeArea()
		  ScrollView{
			 LazyVStack(spacing: 5){
				ForEach(vm.users){user in
				  UserCard(user: user)
				}
			 }
			 
		  }
		  .background(
			 RoundedRectangle(cornerRadius: 15)
				.fill(.white.opacity(0.6))
		  )
		  .padding()
		}
    }
}

#Preview {
    ContactView()
}
