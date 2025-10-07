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
                    .frame(height: 59)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(container.state.modules) { module in
                            ModuleCardView(module: module) {
                                container.handleIntent(HomeIntent.selectModule(module.id))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
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
        HStack {
            Text("YOGHEE")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // 토글 버튼
            HStack(spacing: 8) {
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
            
            Spacer()
            
            Button(action: {
                navigationPath.append(NavigationDestination.notifications)
            }) {
                Image(systemName: "bell")
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
        .background(Color(red: 0.99, green: 0.98, blue: 0.96))
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
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.primary : Color.gray.opacity(0.2))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? Color.primary : Color.gray.opacity(0.3), 
                            lineWidth: 1
                        )
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
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
