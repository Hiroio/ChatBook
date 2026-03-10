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
          
          
          Spacer()
          Button{
            try? AuthenticationManager.shared.signOut()}label:{
            Text("Sign out")
              .foregroundStyle(.white)
              .background(
                RoundedRectangle(cornerRadius: 20)
                  .fill(.red)
                
              )
          }
          Spacer()
          Circle()
            .fill(.blue.opacity(0.5))
            .frame(height: 55)
            .offset(y: isPresented ? 0 : 110)
            .shadow(color: .blue,radius: 5)
            .onAppear(){
              isPresented.toggle()
            }
            .animation(.easeInOut(duration: 1.5).repeatForever(), value: isPresented)
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
