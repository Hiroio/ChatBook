//
//  Animation.swift
//  ChatBook
//
//  Created by user on 07.03.2026.
//

import SwiftUI

struct Animation: View {
  @State private var isPresented: Bool = false
  var body: some View {
    VStack{
      Circle()
        .lineIntersection(
            Circle()
              .offset(y: isPresented ? 150 : 50)
            )
        .padding()
      ZStack(alignment: .leading){
        RoundedRectangle(cornerRadius: 20)
          .fill(.white)
          .shadow(radius: 5)
        RoundedRectangle(cornerRadius: 15)
          .trim(from: 0 , to: CGFloat(isPresented ? 1 : 0.5))
          .fill(.blue.opacity(0.5))
          .shadow(color: .blue, radius: 10)
          .padding(5)
          .frame(maxWidth: isPresented ? .infinity : 0)
      }
      .padding(.horizontal)
      .frame(height: 50)
    }
    .onAppear {
      withAnimation(.easeInOut(duration: 2).repeatForever()){
        isPresented.toggle()
      }
    }
  }
}

#Preview {
  Animation()
}
