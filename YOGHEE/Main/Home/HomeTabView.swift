//
//  HomeTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

// MARK: - Home Tab View
struct HomeTabView: View {
    @StateObject private var container = HomeTabContainer()
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                HeaderView(container: container, navigationPath: $navigationPath)
                    .frame(height: 60)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(container.state.modules) { module in
                            ModuleCardView(module: module) {
                                container.handleIntent(HomeIntent.selectModule(module.id))
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 20)
                }
            }
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .notifications:
                    NotificationListView()
                }
            }
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    @ObservedObject var container: HomeTabContainer
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        HStack(spacing: 15) {
            // 로고
            Image("HeaderLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 28)
            
            // 토글 버튼 그룹
            HStack(spacing: 0) {
                ToggleButton(
                    title: "하루수련",
                    isSelected: container.state.selectedTrainingMode == .daily,
                    action: {
                        container.handleIntent(HomeIntent.toggleTrainingMode(.daily))
                    }
                )
                
                ToggleButton(
                    title: "정규수련",
                    isSelected: container.state.selectedTrainingMode == .regular,
                    action: {
                        container.handleIntent(HomeIntent.toggleTrainingMode(.regular))
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
        .background(Color(red: 0.99, green: 0.98, blue: 0.96))
        // Figma guest 버전의 배경색: .background(Color.black)
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
                // Figma uses Montserrat, fallback to system font
                // .font(.custom("Montserrat-SemiBold", size: 14))
                .foregroundColor(.black)
                .frame(width: 71.5, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color(red: 214/255, green: 246/255, blue: 149/255) : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Module Card View
struct ModuleCardView: View {
    let module: HomeModule
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 16)
                .fill(module.color)
                .frame(height: 200)
                .overlay(
                    VStack {
                        Text(module.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("탭하여 네비게이션")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, 4)
                    }
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeTabView(navigationPath: .constant(NavigationPath()))
}
