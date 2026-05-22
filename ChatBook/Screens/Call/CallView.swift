//
//  CallView.swift
//  ChatBook
//
//  Created by user on 20.05.2026.
//

import SwiftUI

struct CallView: View {
  @Namespace var animation
  @StateObject private var viewModel: CallViewModel
  @State private var isPresented: Bool = false
  let dismiss: () -> ()
  init(oppositeUser: UserModel, chatId: String, dismiss: @escaping () -> ()){
	 self._viewModel = StateObject(wrappedValue: .init(chatId: chatId, oppositeUser: oppositeUser))
	 self.dismiss = dismiss
  }
    var body: some View {
		VStack(){
		  if isPresented{
			 HStack{
				Text(viewModel.oppositeUser.nickname)
				  .padding()
				  .matchedGeometryEffect(id: "name", in: animation)
			 }
		  }else{
			 ZStack{
				Color.white.ignoresSafeArea()
				VStack{
				  Spacer()
				  Text(viewModel.oppositeUser.nickname)
					 .matchedGeometryEffect(id: "name", in: animation)
				  Text(viewModel.statusMessage)
				  Spacer()
				  Button{
					 viewModel.leaveCall()
					 dismiss()
				  }label: {
					 Image(systemName: "phone")
						.padding()
						.background(
						  Circle()
							 .fill(.red)
						)
				  }
				}
				.padding()
			 }
			 .onAppear{
				viewModel.startCall()
			 }
		  }
		}
		.frame(maxWidth: .infinity, alignment: .bottom)
		.background(
		  UnevenRoundedRectangle(cornerRadii: .init(topLeading: 0, bottomLeading: isPresented ? 20 : 0, bottomTrailing: isPresented ? 20 : 0, topTrailing: 0))
			 .fill(.white)
			 .ignoresSafeArea(edges: .top)
		)
		.overlay(
		  Button{
			 withAnimation(.bouncy){
				isPresented.toggle()
			 }
		  }label: {
			 Image(systemName: "chevron.down")
				.rotationEffect(Angle(degrees: isPresented ? -180 : 0))
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding()
		  },
		  alignment: .topLeading
		)
    }
}

#Preview {
  CallView(oppositeUser: .init(id: "", nickname: "User", email: "", photoURL: "", fcmToken: "", voipToken: "", isAnnonymous: false, isOnline: true, dateCreated: Date()), chatId: ""){}
}
