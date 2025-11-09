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
        HStack(spacing: 15) {
            Image("HeaderLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 28)
            
            HStack(spacing: 0) {
                ToggleButton(
                    title: "하루수련",
                    isSelected: container.state.selectedTrainingMode == .oneDay,
                    action: {
                        container.handleIntent(.toggleTrainingMode(.oneDay))
                    }
                )
                
                ToggleButton(
                    title: "정규수련",
                    isSelected: container.state.selectedTrainingMode == .regular,
                    action: {
                        container.handleIntent(.toggleTrainingMode(.regular))
                    }
                )
            }
            .background(Color.white)
            .cornerRadius(16)
            
            Spacer()
            
            // 알림 아이콘
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
        .frame(height: 60)
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
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 71.5, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.NatureGreen : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
