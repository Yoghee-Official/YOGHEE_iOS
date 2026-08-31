//
//  CategoryItemView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/8/25.
//

import SwiftUI

enum CategoryItemSize: Equatable {
    case small    // 93x73 (OneDayCategoryModuleView 2x2 그리드)
    case normal   // 109x70 (RegularCategoryModuleView)
    case wide     // 226x70
    case large    // 145x150 (OneDayCategoryModuleView 피처드 카드)

    var width: CGFloat {
        switch self {
        case .small:  return 93
        case .normal: return 109
        case .wide:   return 226
        case .large:  return 145
        }
    }

    var height: CGFloat {
        switch self {
        case .small:         return 73
        case .normal, .wide: return 70
        case .large:         return 150
        }
    }
}

struct CategoryItemView: View {
    let category: CategoryDTO
    let size: CategoryItemSize
    var backgroundImageName: String? = nil
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                backgroundLayer
                textLayer
            }
            .frame(width: size.width, height: size.height)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        if let imageName = backgroundImageName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(width: size.width, height: size.height)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.Background.opacity(0.8), lineWidth: 1)
                )
        }
    }

    @ViewBuilder
    private var textLayer: some View {
        if size == .large {
            VStack(spacing: 2) {
                Text("언제나 새로운")
                    .pretendardFont(.medium, size: 10)
                    .foregroundColor(.DarkBlack)
                Text(category.name)
                    .pretendardFont(.bold, size: 16)
                    .foregroundColor(.DarkBlack)
            }
        } else {
            Text(category.name)
                .pretendardFont(.bold, size: 12)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    HStack {
        CategoryItemView(
            category: CategoryDTO(categoryId: "4", name: "이색요가"),
            size: .large,
            backgroundImageName: "OnedayCategory1",
            onTap: {}
        )
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                CategoryItemView(category: CategoryDTO(categoryId: "1", name: "릴렉스"), size: .small, backgroundImageName: "OnedayCategory2", onTap: {})
                CategoryItemView(category: CategoryDTO(categoryId: "2", name: "파워"), size: .small, backgroundImageName: "OnedayCategory3", onTap: {})
            }
            HStack(spacing: 6) {
                CategoryItemView(category: CategoryDTO(categoryId: "3", name: "초심자"), size: .small, backgroundImageName: "OnedayCategory4", onTap: {})
                CategoryItemView(category: CategoryDTO(categoryId: "5", name: "전통 요가"), size: .small, backgroundImageName: "OnedayCategory5", onTap: {})
            }
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
