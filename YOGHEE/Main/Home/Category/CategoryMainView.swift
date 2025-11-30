//
//  CategoryMainView.swift
//  YOGHEE
//
//  Created by 0ofKim on 11/18/25.
//

import SwiftUI

struct CategoryMainView: View {
    let categoryId: String
    let categoryName: String
    let categoryType: String
    let categories: [CategoryDTO]
    
    @State private var selectedCategoryId: String
    @Environment(\.dismiss) private var dismiss
    
    init(categoryId: String, categoryName: String, categoryType: String, categories: [CategoryDTO]) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.categoryType = categoryType
        self.categories = categories
        self._selectedCategoryId = State(initialValue: categoryId)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 카테고리 탭
            categoryTabsView
                .padding(.top, 16)
                .padding(.bottom, 16)
            
            // 요기클럽 할인 배너
            YogheeClubDiscountBanner()
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            
            Spacer()
            
            Text("추후 피그마 디자인에 맞춰 개발 예정")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .background(Color.SandBeige)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image("BackArrow")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
        }
        .onAppear {
            enableSwipeBack()
        }
    }
    
    // TODO: SwiftUI-Introspect 사용하면 간단히 됨
    private func enableSwipeBack() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let navigationController = window.rootViewController?.findNavigationController() else {
            return
        }
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: - Category Tabs
    private var categoryTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.categoryId) { category in
                    CategoryTabButton(
                        category: category,
                        isSelected: selectedCategoryId == category.categoryId
                    ) {
                        selectedCategoryId = category.categoryId
                        print("\(category.name) 클릭")
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var navigationTitle: String {
        switch categoryType {
        case "R": return "위치탐색"
        case "O": return "취향탐색"
        default: return categoryName
        }
    }
}

// MARK: - Category Tab Button
struct CategoryTabButton: View {
    let category: CategoryDTO
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(category.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.NatureGreen : Color.Background
                )
                .clipShape(RoundedRectangle(cornerRadius: 32))
        }
        .buttonStyle(.plain)
    }
}

#Preview("정규수련 - 서울") {
    NavigationStack {
        CategoryMainView(
            categoryId: "1",
            categoryName: "서울",
            categoryType: "R",
            categories: [
                CategoryDTO(categoryId: "1", name: "서울", description: "서울", mainDisplay: "Y", type: "R"),
                CategoryDTO(categoryId: "2", name: "경기도", description: "경기도", mainDisplay: "Y", type: "R"),
                CategoryDTO(categoryId: "3", name: "경상도", description: "경상도", mainDisplay: "Y", type: "R"),
                CategoryDTO(categoryId: "4", name: "강원도", description: "강원도", mainDisplay: "Y", type: "R"),
                CategoryDTO(categoryId: "5", name: "전라도", description: "전라도", mainDisplay: "Y", type: "R")
            ]
        )
    }
}

#Preview("하루수련 - 릴렉스") {
    NavigationStack {
        CategoryMainView(
            categoryId: "1",
            categoryName: "릴렉스",
            categoryType: "O",
            categories: [
                CategoryDTO(categoryId: "1", name: "릴렉스", description: "릴렉스", mainDisplay: "Y", type: "O"),
                CategoryDTO(categoryId: "2", name: "파워", description: "파워", mainDisplay: "Y", type: "O"),
                CategoryDTO(categoryId: "3", name: "초심자", description: "초심자", mainDisplay: "Y", type: "O"),
                CategoryDTO(categoryId: "4", name: "이색요가", description: "이색요가", mainDisplay: "Y", type: "O"),
                CategoryDTO(categoryId: "5", name: "전통요가", description: "전통요가", mainDisplay: "Y", type: "O")
            ]
        )
    }
}


