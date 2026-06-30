//
//  RegularCategoryModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/8/25.
//

import SwiftUI

// 데이터 순서: [0]큰카드, [1~4]작은카드 2x2, [5]큰카드, [6~7]작은카드 세로 2개
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
                HStack(alignment: .top, spacing: 6) {
                    // [0] 큰 카드 (RegularCategory1)
                    if items.count > 0 {
                        CategoryItemView(
                            category: items[0],
                            size: .large,
                            backgroundImageName: "RegularCategory1",
                            onTap: { onItemTap(items[0].categoryId) }
                        )
                    }

                    // [1~4] 작은 카드 2x2 (RegularCategory2~5)
                    if items.count > 4 {
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                CategoryItemView(category: items[1], size: .small, backgroundImageName: "RegularCategory2", onTap: { onItemTap(items[1].categoryId) })
                                CategoryItemView(category: items[2], size: .small, backgroundImageName: "RegularCategory3", onTap: { onItemTap(items[2].categoryId) })
                            }
                            HStack(spacing: 6) {
                                CategoryItemView(category: items[3], size: .small, backgroundImageName: "RegularCategory4", onTap: { onItemTap(items[3].categoryId) })
                                CategoryItemView(category: items[4], size: .small, backgroundImageName: "RegularCategory5", onTap: { onItemTap(items[4].categoryId) })
                            }
                        }
                    }

                    // [5] 큰 카드 (RegularCategory6)
                    if items.count > 5 {
                        CategoryItemView(
                            category: items[5],
                            size: .large,
                            backgroundImageName: "RegularCategory6",
                            onTap: { onItemTap(items[5].categoryId) }
                        )
                    }

                    // [6~7] 작은 카드 세로 2개 (RegularCategory7~8)
                    if items.count > 7 {
                        VStack(spacing: 4) {
                            CategoryItemView(category: items[6], size: .small, backgroundImageName: "RegularCategory7", onTap: { onItemTap(items[6].categoryId) })
                            CategoryItemView(category: items[7], size: .small, backgroundImageName: "RegularCategory8", onTap: { onItemTap(items[7].categoryId) })
                        }
                    }
                }
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
                CategoryDTO(categoryId: "1", name: "서울"),      // [0] 큰 카드
                CategoryDTO(categoryId: "2", name: "경기도"),    // [1] 작은 카드
                CategoryDTO(categoryId: "3", name: "경상도"),    // [2] 작은 카드
                CategoryDTO(categoryId: "5", name: "전라도"),    // [3] 작은 카드
                CategoryDTO(categoryId: "6", name: "충청도"),    // [4] 작은 카드
                CategoryDTO(categoryId: "7", name: "제주도"),    // [5] 큰 카드
                CategoryDTO(categoryId: "4", name: "강원도"),    // [6] 작은 카드
                CategoryDTO(categoryId: "8", name: "기타")       // [7] 작은 카드
            ]
        ) { categoryId in
            print("Tapped category: \(categoryId)")
        }
    }
    .background(Color.gray.opacity(0.1))
}
