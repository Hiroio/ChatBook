//
//  SearchView.swift
//  ChatBook
//
//  Created by user on 09.03.2026.
//

import SwiftUI

struct SearchView: View {
  @EnvironmentObject private var vm: ChatsViewModel
  
  private var searchField: Bool {
    vm.searchText.count >= 3
  }
    var body: some View {
      TextField(text: $vm.searchText) {
        HStack{
          Text("Search")
            Spacer()
          Image(systemName: "magnifyingglass")
        }.foregroundStyle(.blue.opacity(0.4))
      }
      .foregroundStyle(.blue.opacity(0.6))
      .padding()
      .frame(maxWidth: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(.white)
          .shadow(color: .blue.opacity(0.3), radius: 5)
      )
      .overlay(alignment: .top){
        Group{
          if searchField{
            VStack{
                if vm.usersBySearch.isEmpty{
                  Text("Users with such a name not found")
                    .padding(.vertical)
                }else{
                  ForEach(vm.usersBySearch){user in
                    Button {
                        vm.prepareChat(with: user.id)
                    } label: {
                        SearchUser(userName: user.nickname)
                    }
                    .navigationDestination(item: $vm.selectedChatID) { chatId in
                        ChatView(id: chatId)
                    }
                  }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
              RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .blue.opacity(0.3), radius: 3, y: 10)
            )
            .offset(y: 55)
          }
        }
      }
      .animation(.easeInOut, value: searchField)
    }
}

#Preview {
    SearchView()
    .environmentObject(ChatsViewModel())
}
