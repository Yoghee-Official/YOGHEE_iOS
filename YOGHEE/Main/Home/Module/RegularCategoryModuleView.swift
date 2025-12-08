//
//  RegularCategoryModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/8/25.
//

import SwiftUI

struct RegularCategoryModuleView: View {
    let items: [CategoryDTO]
    let onItemTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("다양한 지역에서 잊을 수 없는 요가 수련을 경험해보세요!")
                .pretendardFont(.medium, size: 12)
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
                            isWide: false,
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

#Preview {
    ScrollView {
        RegularCategoryModuleView(
            items: [
                CategoryDTO(categoryId: "1", name: "서울", description: "서울", mainDisplay: "Y", type: .regular),
                CategoryDTO(categoryId: "2", name: "경기도", description: "경기도", mainDisplay: "Y", type: .regular),
                CategoryDTO(categoryId: "3", name: "경상도", description: "경상도", mainDisplay: "Y", type: .regular),
                CategoryDTO(categoryId: "4", name: "강원도", description: "강원도", mainDisplay: "Y", type: .regular),
                CategoryDTO(categoryId: "5", name: "전라도", description: "전라도", mainDisplay: "Y", type: .regular),
                CategoryDTO(categoryId: "6", name: "충청도", description: "충청도", mainDisplay: "Y", type: .regular),
                CategoryDTO(categoryId: "7", name: "제주도", description: "제주도", mainDisplay: "Y", type: .regular),
                CategoryDTO(categoryId: "8", name: "기타", description: "기타", mainDisplay: "Y", type: .regular)
            ]
        ) { categoryId in
            print("Tapped category: \(categoryId)")
        }
    }
    .background(Color.gray.opacity(0.1))
}
