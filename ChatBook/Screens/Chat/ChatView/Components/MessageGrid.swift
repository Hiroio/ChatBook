//
//  MessageGrid.swift
//  ChatBook
//
//  Created by user on 10.03.2026.
//

import SwiftUI

struct MessageGrid: View {
  let messages: [MessageModel]
  var body: some View {
	 ScrollViewReader{proxy in
		ScrollView{
		  VStack{
			 ForEach(messages.enumerated(), id: \.offset){(index, message) in
				let userMessage = message.senderId == UserManager.shared.currentUserId ?? ""
				HStack(alignment: .bottom, spacing: 6) {
				  Text(message.text)
				  
				  switch message.localStatus {
				  case .loading:
					 ProgressView()
						.controlSize(.mini)
				  case .failed:
					 Image(systemName: "exclamationmark.circle.fill")
						.foregroundStyle(.red)
						.font(.caption)
				  case .delivered:
					 Text(message.timestamp.formatted(.dateTime.hour().minute()))
						.font(.caption2)
				  }
				}
				.id(index)
				//				.opacity(message.localStatus == .loading ? 0.7 : 1) ? 0.7 : 1)
				.padding()
				.background(
				  RoundedRectangle(cornerRadius: 20)
					 .fill(.white)
					 .shadow(color: .blue.opacity(0.5), radius: 4)
				)
				.frame(maxWidth: .infinity, alignment: userMessage ? .trailing : .leading)
				.onAppear{
				  withAnimation(.bouncy){
					 proxy.scrollTo(messages.count - 1)
				  }
				}
			 }
		  }
		  .padding()
		}
	 }
  }
}

#Preview {
    MessageGrid(messages: [])
}
