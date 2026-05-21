//
//  CallView.swift
//  ChatBook
//
//  Created by user on 20.05.2026.
//

import SwiftUI

struct CallView: View {
  @StateObject private var viewModel: CallViewModel
  
  let dismiss: () -> ()
  init(oppositeUser: UserModel, chatId: String, dismiss: @escaping () -> ()){
	 self._viewModel = StateObject(wrappedValue: .init(chatId: chatId, oppositeUser: oppositeUser))
	 self.dismiss = dismiss
  }
    var body: some View {
		ZStack{
		  Color.white.ignoresSafeArea()
		  VStack{
			 Spacer()
			 Text(viewModel.oppositeUser.nickname)
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
		  .onAppear{
			 viewModel.startCall()
		  }
		}
    }
}

#Preview {
  CallView(oppositeUser: .init(id: "", nickname: "", email: "", photoURL: "", fcmToken: "", voipToken: "", isAnnonymous: false, isOnline: true, dateCreated: Date()), chatId: ""){}
}
