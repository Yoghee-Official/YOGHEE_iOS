//
//  OneDayCategoryModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/8/25.
//

import SwiftUI

struct OneDayCategoryModuleView: View {
    let items: [CategoryDTO]
    let onItemTap: (String) -> Void

    // items[0] → large 카드 (OnedayCategory1)
    // items[1~4] → 2x2 그리드 (OnedayCategory2~5)
    private var featuredItem: CategoryDTO? { items.first }
    private var gridItems: [CategoryDTO] { Array(items.dropFirst()) }

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            if let featured = featuredItem {
                CategoryItemView(
                    category: featured,
                    size: .large,
                    backgroundImageName: "OnedayCategory1",
                    onTap: { onItemTap(featured.categoryId) }
                )
            }

            LazyVGrid(
                columns: [
                    GridItem(.fixed(93), spacing: 6),
                    GridItem(.fixed(93))
                ],
                spacing: 4
            ) {
                ForEach(gridItems.indices, id: \.self) { index in
                    CategoryItemView(
                        category: gridItems[index],
                        size: .small,
                        backgroundImageName: "OnedayCategory\(index + 2)",
                        onTap: { onItemTap(gridItems[index].categoryId) }
                    )
                }
            }
            .frame(width: 192)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    ScrollView {
        OneDayCategoryModuleView(
            items: [
                CategoryDTO(categoryId: "1", name: "릴렉스"),
                CategoryDTO(categoryId: "2", name: "파워"),
                CategoryDTO(categoryId: "3", name: "초심자"),
                CategoryDTO(categoryId: "4", name: "이색요가"),
                CategoryDTO(categoryId: "5", name: "전통 요가")
            ]
        ) { categoryId in
            print("Tapped category: \(categoryId)")
        }
    }
    .background(Color.gray.opacity(0.1))
}
