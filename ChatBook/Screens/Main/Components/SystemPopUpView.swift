//
//  SystemPopUp.swift
//  ChatBook
//
//  Created by user on 26.05.2026.
//

import SwiftUI

struct SystemPopUpView: View {
  let type: SystemPopUp
    var body: some View {
		VStack(spacing: 10){
		  Text(type.text)
			 .font(.title2.bold())
		  Text(type.desc)
			 .font(.footnote)
		  
		  Grid(horizontalSpacing: 10){
			 GridRow(){
				Button{
				  NavigationManager.shared.popUps = nil
				}label: {
				  Text("Cancel")
					 .foregroundStyle(.black)
					 .padding(15)
					 .background(
						RoundedRectangle(cornerRadius: 25)
						  .stroke(.black, lineWidth: 1)
					 )
				}
				Button{
				  type.action()
				  NavigationManager.shared.popUps = nil
				}label: {
				  Text("Confirm")
					 .padding(15)
					 .background(
						RoundedRectangle(cornerRadius: 25)
						  .stroke(.blue, lineWidth: 1)
					 )
				}
			 }
		  }
		  .font(.headline)
		  .padding()
		}
		.padding()
		.background(
		  RoundedRectangle(cornerRadius: 20)
			 .fill(.ultraThinMaterial)
		)
    }
}

#Preview {
  SystemPopUpView(type: .delete({}))
}
