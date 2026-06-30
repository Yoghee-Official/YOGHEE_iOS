//
//  HomeHeaderView.swift
//  YOGHEE
//
//  Created by 0ofKim on 11/8/25.
//

import SwiftUI

struct HomeHeaderView: View {
    @ObservedObject var container: HomeTabContainer
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
          VStack(spacing: 0) {
              // 1줄: 로고
              HStack {
                  Image("HeaderLogo")
                      .resizable()
                      .scaledToFit()
                      .frame(width: 23, height: 28)
                  Spacer()
              }
              .padding(.horizontal, 16)
              .frame(height: 43)
      
              // 2줄: 토글 + 알림
              HStack(spacing: 0) {
                  HStack(spacing: 0) {
                      ForEach(ClassType.allCases, id: \.self) { type in
                          ToggleButton(
                              title: type.toggleTitle,
                              isSelected: container.state.selectedClassType == type,
                              action: {
                                  container.handleIntent(.toggleClassType(type))
                              }
                          )
                      }
                  }
                  .background(Color.white)
                  .cornerRadius(16)

                  Spacer()
      
                  Button(action: {
                      navigationPath.append(NavigationDestination.notifications)
                  }) {
                      Image("NotificationButton")
                          .resizable()
                          .scaledToFit()
                          .frame(width: 34, height: 27)
                  }
              }
              .padding(.horizontal, 16)
              .frame(height: 48)
          }
          .background(Color.SandBeige)
      }
}

// MARK: - Toggle Button
struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .pretendardFont(isSelected ? .bold : .regular, size: 14)
                .foregroundColor(.black)
                .opacity(isSelected ? 1.0 : 0.2)
                .frame(width: 71.5, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.NatureGreen : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
