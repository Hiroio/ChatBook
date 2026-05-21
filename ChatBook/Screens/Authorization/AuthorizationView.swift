//
//  AuthorizationView.swift
//  ChatBook
//
//  Created by user on 08.03.2026.
//

import SwiftUI

struct AuthorizationView: View {
  @State private var sheetPresented: Bool = false
  @State private var email: String = ""
  @State private var password: String = ""
  @State private var isPresented: Bool = false
    var body: some View {
      ZStack{
        RadialGradient.background.ignoresSafeArea()
        VStack{
			 Spacer()
			 Text("Chat Book")
				.font(.title.weight(.medium))
          Spacer()
          Button{
            Task{
              try await AuthenticationManager.shared.signInAnonymously()
            }
          }label: {
            HStack{
              Text("Continue as annonymous")
              Image(systemName: "person.fill")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
              RoundedRectangle(cornerRadius: 20)
                .fill(.blue.opacity(0.5))
                .shadow(radius: 5)
            )
          }
          Button{sheetPresented = true}label: {
            HStack{
              Text("Continue with email")
              Image(systemName: "envelope.fill")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
              RoundedRectangle(cornerRadius: 20)
                .fill(.blue.opacity(0.5))
                .shadow(radius: 5)
            )
          }
         
        }
        .foregroundStyle(.primary)
        .font(.headline)
        .padding(.horizontal)
      }
      .sheet(isPresented: $sheetPresented) {
        EmailForm()
      }
    }
}

#Preview {
    AuthorizationView()
}

//
//Task{
//  try await AuthenticationManager.shared.signInAnonymously()
//}
