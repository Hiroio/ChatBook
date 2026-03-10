//
//  EmailForm.swift
//  ChatBook
//
//  Created by user on 09.03.2026.
//

import SwiftUI

struct EmailForm: View {
  @State private var email: String = ""
  @State private var password: String = ""
    var body: some View {
      VStack(spacing: 15){
        TextField(text: $email) {
          Text("Email")
        }
        .foregroundStyle(.blue.opacity(0.6))
        .padding()
        .frame(maxWidth: .infinity)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(.white)
            .shadow(color: .blue.opacity(0.3), radius: 5)
        )
        SecureField(text: $password) {
          Text("Password")
        }
        .foregroundStyle(.blue.opacity(0.6))
        .padding()
        .frame(maxWidth: .infinity)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(.white)
            .shadow(color: .blue.opacity(0.3), radius: 5)
        )
        
        Button{
          Task{
           try await AuthenticationManager.shared.signUp(email: email, password: password)
          }
        }label:{
          Text("Sign up")
            .foregroundStyle(.white)
            .padding()
            .font(.headline)
            .frame(maxWidth: .infinity)
            .background(
              RoundedRectangle(cornerRadius: 20)
                .fill(.blue.opacity(0.7))
                .shadow(color: .blue, radius: 5)
            )
            .padding(.horizontal)
        }
      }
      .padding(.horizontal)
      .presentationDetents([.medium, .fraction(0.4)])
      .presentationSizing(.form)
    }
}

#Preview {
    EmailForm()
}
