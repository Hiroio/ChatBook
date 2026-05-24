//
//  UserView.swift
//  ChatBook
//
//  Created by user on 10.03.2026.
//

import SwiftUI
import PhotosUI

struct UserView: View {
  @StateObject private var vm = UserViewModel()
  @State private var selectedItem: PhotosPickerItem? = nil
  var body: some View {
    VStack(spacing: 15){
      if vm.user != nil{
        PhotosPicker(selection: $selectedItem, matching: .images) {
          ZStack{
            if let photoURL = URL(string: vm.userPhotoURL){
              AsyncImage(url: photoURL){image in
                image
                  .resizable()
                  .scaledToFill()
              }placeholder: {
                Circle()
                  .redacted(reason: .placeholder)
              }
            }else{
              Circle()
                .overlay(
                  Image(systemName: "person.fill")
                    .foregroundStyle(.white)
                )
            }
          }
          .frame(width: 150, height: 150)
          .clipShape(Circle())
        }
        .onChange(of: selectedItem) { _, newItem in
          Task {
            await vm.saveAvatar(from: newItem)
          }
        }
        
        TextField("UserName",
                  text: Binding(
                    get: {
                      vm.userNickname
                    },
                    set: { newValue in
                      if newValue.count < 15{
                        vm.userNickname = newValue
                      }
                    }))
        .font(.title2)
        .foregroundStyle(.blue.opacity(0.7))
		  .padding()
		  .background(
			 RoundedRectangle(cornerRadius: 15)
				.stroke(.black, lineWidth: 1)
		  )
      }else{
        errorLoading
      }
      
      //      MARK: SAVE CHANGES
      let isActive = vm.user != nil
      Button{
        if isActive{
          vm.saveChanges()
        }else{
          vm.reloadProfile()
        }
      }label: {
        Text(isActive ? "Submit" : "Reload")
          .foregroundStyle(.white)
          .font(.title2.bold())
          .padding()
          .background(
            RoundedRectangle(cornerRadius: 20)
              .fill(.blue.opacity(0.7))
              .shadow(color: .blue.opacity(0.7), radius: 5)
          )
      }
    }
    .padding(10)
    .padding(.horizontal, 30)
  }
  
  
  private var errorLoading: some View{
	 VStack(spacing: 25){
      Image(systemName: "exclamationmark.circle.fill")
        .font(.largeTitle)
        .foregroundStyle(.blue)
      Text("Sorry we won't able to load profile")
        .font(.title2)
        .foregroundStyle(.blue.opacity(0.7))
      
    }
  }
}

#Preview {
  UserView()
}
