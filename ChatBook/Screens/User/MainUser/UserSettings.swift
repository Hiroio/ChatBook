//
//  UserSettings.swift
//  ChatBook
//
//  Created by user on 09.03.2026.
//

import SwiftUI

struct UserSettings: View {
  @State private var activated: Bool = false
    var body: some View {
      Button{
        withAnimation(){
          activated.toggle()
        }
      }label:{
        Image(systemName: "person")
			 .padding()
			 .background(
				Circle()
				  .fill(.white)
				  .shadow(radius: 1)
			 )
      }
      .overlay(alignment: .bottom) {
        Group{
          if activated{
            VStack{
              Button("Settings", systemImage: "gearshape"){
                withAnimation(){
						NavigationManager.shared.userProfile.toggle()
						activated = false
                }
              }
              .padding(12)
              .background(
                RoundedRectangle(cornerRadius: 20)
                  .fill(.white)
                  .shadow(color: .blue, radius: 3)
              )
              Button{
                try? AuthenticationManager.shared.signOut()
              }label:{
                HStack{
                  Text("Sign Out")
                  Image(systemName: "arrow.backward.to.line.square")
                }
                .padding(12)
                .foregroundStyle(.red)
                .font(.headline)
                .background(
                  RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: .red, radius: 3)
                )
              }
            }
            .fixedSize()
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 15)
                .fill(.white)
                .shadow(color: .blue,radius: 5)
            )
            .transition(.asymmetric(insertion: .scale, removal: .opacity))
            .offset(x: -70, y: 125)
          }
        }
        
      }
      }
}

#Preview {
  UserSettings()
}
