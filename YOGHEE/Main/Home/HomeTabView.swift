//
//  HomeTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI
import Foundation

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
                    LazyVStack(spacing: 20) {
                        if container.state.isLoading {
                            ProgressView("데이터 로딩 중...")
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else if let errorMessage = container.state.errorMessage {
                            VStack(spacing: 16) {
                                Text("오류가 발생했습니다")
                                    .font(.headline)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Button("다시 시도") {
                                    container.handleIntent(.loadMainData)
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            ForEach(container.state.sections) { section in
                                SectionView(section: section) { itemId in
                                    container.handleIntent(.selectItem(itemId, section.type))
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .notifications:
                    NotificationListView()
                case .classDetail(let classId):
                    Text("클래스 상세: \(classId)")
                case .reviewDetail(let reviewId):
                    Text("리뷰 상세: \(reviewId)")
                case .categoryDetail(let categoryId):
                    Text("카테고리 상세: \(categoryId)")
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

// MARK: - Section View
struct SectionView: View {
    let section: HomeSection
    let onItemTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(section.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            switch section.type {
            case .recommendClass:
                RecommendClassModuleView(items: section.items, onItemTap: onItemTap)
            case .customizedClass:
                CustomizedClassModuleView(items: section.items, onItemTap: onItemTap)
            case .newReview:
                NewReviewModuleView(items: section.items, onItemTap: onItemTap)
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    HomeTabView(navigationPath: .constant(NavigationPath()))
}
