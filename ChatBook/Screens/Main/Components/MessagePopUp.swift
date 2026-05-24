//
//  MessagePopUp.swift
//  ChatBook
//
//  Created by user on 23.05.2026.
//

import SwiftUI

struct MessagePopUp: View {
  @State private var dragAmount: CGFloat = 0
  let message: MessageModel
    var body: some View {
		HStack{
		  VStack(alignment: .leading){
			 Text(message.senderId)
				.font(.headline)
			 Text(message.text)
				.font(.subheadline)
		  }
		  .frame(maxWidth: .infinity, alignment: .leading)
		  Text(message.timestamp.formatted(.dateTime.hour().minute()))
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding()
		.background(
		  RoundedRectangle(cornerRadius: 20)
			 .fill(.white)
			 .shadow(radius: 3, y: 4)
		)
		.offset(y: dragAmount)
		.gesture(
		  DragGesture()
			 .onChanged{ drag in
				let distantance = drag.translation.height
				self.dragAmount = min(0, distantance)
			 }
			 .onEnded({ drag in
				if drag.location.y < drag.startLocation.y{
				  print("dismiised")
				  NavigationManager.shared.message = nil
				}
			 })
		)
		.onAppear{
		  DispatchQueue.main.asyncAfter(deadline: .now() + 2){
			 if NavigationManager.shared.message?.id == message.id{
				NavigationManager.shared.message = nil
			 }
		  }
		}
    }
}

#Preview {
    MessagePopUp(message: MessageModel(id: "", text: "asdasdas", senderId: "user", timestamp: Date()))
}
