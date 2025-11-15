//
//  CategoryModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 11/12/25.
//

import SwiftUI

struct CategoryModuleView: View {
    let items: [CategoryDTO]
    let onItemTap: (String) -> Void
    
    var body: some View {
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
}

// MARK: - Category Item View
struct CategoryItemView: View {
    let category: CategoryDTO
    let isFirst: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topLeading) {
                if isFirst {
                    // TODO: 원숭이 이미지 나오면 넣기
                    Image("CategoryBackgroundFirst")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 109, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(width: 109, height: 70)
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
            .frame(width: 109, height: 70)
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

#Preview {
    CategoryModuleView(items: CategoryDTO.previews) { categoryId in
        print("Tapped category: \(categoryId)")
    }
    .background(Color.gray.opacity(0.1))
}

