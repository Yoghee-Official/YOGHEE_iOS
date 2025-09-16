//
//  HomeView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var container = HomeContainer()
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
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
    }
}

// MARK: - Header View
struct HeaderView: View {
    var body: some View {
        HStack {
            Text("YOGHEE")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                // 알림 버튼 액션
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
    HomeView()
}
