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
  init(call: CallModel, dismiss: @escaping () -> Void) {
    self._viewModel = StateObject(
      wrappedValue: CallViewModel(
        chatId: call.chatID,
        oppositeUser: call.oppositeUser,
        direction: call.isIncoming ? .incoming : .outgoing
      )
    )
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
				  Text(viewModel.callStatus.title)
					 .font(.subheadline)
					 .foregroundStyle(.secondary)

				  if viewModel.showsCallTimer {
					 Text(viewModel.formattedDuration)
						.font(.title2.monospacedDigit().weight(.medium))
						.padding(.top, 4)
				  }

				  Spacer()

				  HStack(spacing: 40) {
					 Button {
						viewModel.toggleMute()
					 } label: {
						Image(systemName: viewModel.isMuted ? "mic.slash.fill" : "mic.fill")
						  .font(.title3)
						  .foregroundStyle(.white)
						  .padding()
						  .background(Circle().fill(viewModel.isMuted ? .orange : .gray))
					 }

					 Button {
						viewModel.leaveCall()
						dismiss()
					 } label: {
						Image(systemName: "phone.down.fill")
						  .font(.title3)
						  .foregroundStyle(.white)
						  .padding()
						  .background(Circle().fill(.red))
					 }
				  }
				}
				.padding()
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
  CallView(
    call: CallModel(
      chatID: "",
      oppositeUser: .newProfile(id: "1", email: nil, isAnonymous: false),
      isIncoming: false
    )
  ) {}
}
