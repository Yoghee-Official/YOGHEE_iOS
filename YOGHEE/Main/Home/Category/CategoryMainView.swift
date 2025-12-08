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
    let classType: ClassType
    let categories: [CategoryDTO]
    
    @StateObject private var container = CategoryMainContainer()
    @Environment(\.dismiss) private var dismiss
    
    init(categoryId: String, categoryName: String, categoryType: ClassType, categories: [CategoryDTO]) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.classType = categoryType
        self.categories = categories
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 카테고리 탭
                categoryTabsView
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                
                // 요기클럽 할인 배너
                YogheeClubDiscountBanner()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                
                // 필터 버튼
                filterButton
                    .padding(.horizontal, 28)
                    .padding(.bottom, 16)
                    .overlay(alignment: .topLeading) {
                        if container.state.showFilterSheet {
                            FilterPopup(
                                selectedFilter: container.state.selectedFilter,
                                onClose: {
                                    container.handleIntent(.toggleFilterSheet)
                                },
                                onFilterChange: { filter in
                                    container.handleIntent(.applyFilter(filter))
                                    container.handleIntent(.toggleFilterSheet)
                                }
                            )
                            .padding(.leading, 16)
                            .offset(y: -12)
                        }
                    }
                    .zIndex(999)
                
                // 수련원 목록 리스트
                if container.state.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else if let errorMessage = container.state.errorMessage {
                    Spacer()
                    Text("오류 발생: \(errorMessage)")
                        .pretendardFont(.regular, size: 12)
                        .foregroundColor(.red)
                    Spacer()
                } else if container.state.classes.isEmpty {
                    Spacer()
                    Text("예약 가능한 수업이 없습니다.")
                        .pretendardFont(.regular, size: 12)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 36) {
                            ForEach(container.state.classes, id: \.classId) { categoryClass in
                                CategoryClassListItemView(
                                    categoryClass: categoryClass,
                                    categoryType: classType,
                                    onTap: {
                                        container.handleIntent(.selectClass(categoryClass.classId))
                                    },
                                    onFavoriteToggle: {
                                        container.handleIntent(.toggleFavorite(classId: categoryClass.classId))
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 0)
                        .padding(.bottom, 36)
                    }
                }
            }
            .background(Color.SandBeige)
        }
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
            container.handleIntent(.initialize(categoryId: categoryId, type: classType.rawValue))
        }
    }
    
    private func enableSwipeBack() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let navigationController = window.rootViewController?.findNavigationController() else {
            return
        }
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: - Filter Button
    private var filterButton: some View {
        Button(action: {
            container.handleIntent(.toggleFilterSheet)
        }) {
            HStack(spacing: 4) {
                Text(container.state.selectedFilter.rawValue)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.black)
                
                Image("DownArrow")
                    .resizable()
                    .frame(width: 8, height: 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Category Tabs
    private var categoryTabsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.categoryId) { category in
                    CategoryTabButton(
                        category: category,
                        isSelected: container.state.selectedCategoryId == category.categoryId
                    ) {
                        container.handleIntent(.selectCategory(categoryId: category.categoryId, type: classType.rawValue))
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var navigationTitle: String {
        classType.moduleTitle
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
                .pretendardFont(.medium, size: 12)
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

// MARK: - Filter Popup
struct FilterPopup: View {
    let selectedFilter: FilterOption
    let onClose: () -> Void
    let onFilterChange: (FilterOption) -> Void
    
    private enum Constants {
        static let width: CGFloat = 104.ratio()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onClose) {
                HStack(spacing: 4) {
                    Text(selectedFilter.rawValue)
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.black)
                    
                    Image("DownArrow")
                        .resizable()
                        .frame(width: 8, height: 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 12)
            }
            .buttonStyle(.plain)
            
            Divider()
                .frame(height: 1)
                .background(Color.black)
            
            // 필터 옵션 리스트
            VStack(spacing: 8) {
                ForEach(FilterOption.allCases, id: \.self) { option in
                    Button(action: {
                        onFilterChange(option)
                    }) {
                        Text(option.rawValue)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(width: Constants.width)
        .background(Color.SandBeige)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Background, lineWidth: 1)
        )
    }
}

#Preview("정규수련 - 서울") {
    NavigationStack {
        CategoryMainView(
            categoryId: "1",
            categoryName: "서울",
            categoryType: .regular,
            categories: [
                CategoryDTO(categoryId: "1", name: "서울", description: "서울", mainDisplay: "Y", type: .regular),
                CategoryDTO(categoryId: "2", name: "경기도", description: "경기도", mainDisplay: "Y", type: .regular),
                CategoryDTO(categoryId: "3", name: "경상도", description: "경상도", mainDisplay: "Y", type: .regular),
                CategoryDTO(categoryId: "4", name: "강원도", description: "강원도", mainDisplay: "Y", type: .regular),
                CategoryDTO(categoryId: "5", name: "전라도", description: "전라도", mainDisplay: "Y", type: .regular)
            ]
        )
    }
}

#Preview("하루수련 - 릴렉스") {
    NavigationStack {
        CategoryMainView(
            categoryId: "1",
            categoryName: "릴렉스",
            categoryType: .oneDay,
            categories: [
                CategoryDTO(categoryId: "1", name: "릴렉스", description: "릴렉스", mainDisplay: "Y", type: .oneDay),
                CategoryDTO(categoryId: "2", name: "파워", description: "파워", mainDisplay: "Y", type: .oneDay),
                CategoryDTO(categoryId: "3", name: "초심자", description: "초심자", mainDisplay: "Y", type: .oneDay),
                CategoryDTO(categoryId: "4", name: "이색요가", description: "이색요가", mainDisplay: "Y", type: .oneDay),
                CategoryDTO(categoryId: "5", name: "전통요가", description: "전통요가", mainDisplay: "Y", type: .oneDay)
            ]
        )
    }
}


