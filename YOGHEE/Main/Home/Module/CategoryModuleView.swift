//
//  CategoryModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 11/12/25.
//

import SwiftUI

struct CategoryModuleView: View {
    let items: [CategoryDTO]
    let isRegularMode: Bool
    let onItemTap: (String) -> Void
    
    var body: some View {
        if isRegularMode {
            regularModeView
        } else {
            oneDayModeView
        }
    }
    
    // MARK: - 정규수련 모드 (지역 카테고리)
    private var regularModeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("다양한 지역에서 잊을 수 없는 요가 수련을 경험해보세요!")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyVGrid(
                    columns: [
                        GridItem(.fixed(109), spacing: 8),
                        GridItem(.fixed(109), spacing: 8),
                        GridItem(.fixed(109), spacing: 8),
                        GridItem(.fixed(109), spacing: 8)
                    ],
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(items.indices, id: \.self) { index in
                        CategoryItemView(
                            category: items[index],
                            isFirst: index == 0,
                            isWide: false,  // 정규수련은 모두 같은 크기
                            onTap: { onItemTap(items[index].categoryId) }
                        )
                    }
                }
                .frame(height: 148)
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - 하루수련 모드 (요가 타입 카테고리)
    private var oneDayModeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(0..<min(3, items.count), id: \.self) { index in
                    CategoryItemView(
                        category: items[index],
                        isFirst: false,
                        isWide: false,
                        onTap: { onItemTap(items[index].categoryId) }
                    )
                }
            }
            
            if items.count > 3 {
                HStack(spacing: 8) {
                    CategoryItemView(
                        category: items[3],
                        isFirst: false,
                        isWide: true,
                        onTap: { onItemTap(items[3].categoryId) }
                    )
                    
                    if items.count > 4 {
                        ForEach(4..<items.count, id: \.self) { index in
                            CategoryItemView(
                                category: items[index],
                                isFirst: false,
                                isWide: false,
                                onTap: { onItemTap(items[index].categoryId) }
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Category Item View
struct CategoryItemView: View {
    let category: CategoryDTO
    let isFirst: Bool
    let isWide: Bool
    let onTap: () -> Void
    
    private var itemWidth: CGFloat {
        isWide ? 226 : 109
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topLeading) {
                if isFirst {
                    // TODO: 원숭이 이미지 나오면 넣기
                    Image("CategoryBackgroundFirst")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: itemWidth, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(width: itemWidth, height: 70)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 239/255, green: 237/255, blue: 235/255).opacity(0.8), lineWidth: 1)
                        )
                }
                
                Text(category.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.leading, 8)
                    .padding(.top, 6)
            }
            .frame(width: itemWidth, height: 70)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
extension CategoryDTO {
    static let previews = [
        CategoryDTO(categoryId: "1", name: "서울", description: "서울", mainDisplay: "Y", type: "R"),
        CategoryDTO(categoryId: "2", name: "경기도", description: "경기도", mainDisplay: "Y", type: "R"),
        CategoryDTO(categoryId: "3", name: "경상도", description: "경상도", mainDisplay: "Y", type: "R"),
        CategoryDTO(categoryId: "4", name: "강원도", description: "강원도", mainDisplay: "Y", type: "R"),
        CategoryDTO(categoryId: "5", name: "전라도", description: "전라도", mainDisplay: "Y", type: "R"),
        CategoryDTO(categoryId: "6", name: "충청도", description: "충청도", mainDisplay: "Y", type: "R"),
        CategoryDTO(categoryId: "7", name: "제주도", description: "제주도", mainDisplay: "Y", type: "R"),
        CategoryDTO(categoryId: "8", name: "기타", description: "기타", mainDisplay: "Y", type: "R")
    ]
}
#endif

#Preview("정규수련 - 지역") {
    ScrollView {
        CategoryModuleView(items: CategoryDTO.previews, isRegularMode: true) { categoryId in
            print("Tapped category: \(categoryId)")
        }
    }
    .background(Color.gray.opacity(0.1))
}

#Preview("하루수련 - 요가타입") {
    ScrollView {
        CategoryModuleView(
            items: [
                CategoryDTO(categoryId: "1", name: "릴렉스", description: "", mainDisplay: "Y", type: "O"),
                CategoryDTO(categoryId: "2", name: "파워", description: "", mainDisplay: "Y", type: "O"),
                CategoryDTO(categoryId: "3", name: "초심자", description: "", mainDisplay: "Y", type: "O"),
                CategoryDTO(categoryId: "4", name: "이색요가", description: "", mainDisplay: "Y", type: "O"),
                CategoryDTO(categoryId: "5", name: "전통 요가", description: "", mainDisplay: "Y", type: "O")
            ],
            isRegularMode: false
        ) { categoryId in
            print("Tapped category: \(categoryId)")
        }
    }
    .background(Color.gray.opacity(0.1))
}

