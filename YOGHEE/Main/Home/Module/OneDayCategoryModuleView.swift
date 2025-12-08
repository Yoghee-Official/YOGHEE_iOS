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
    
    var body: some View {
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

#Preview {
    ScrollView {
        OneDayCategoryModuleView(
            items: [
                CategoryDTO(categoryId: "1", name: "릴렉스", description: "", mainDisplay: "Y", type: .oneDay),
                CategoryDTO(categoryId: "2", name: "파워", description: "", mainDisplay: "Y", type: .oneDay),
                CategoryDTO(categoryId: "3", name: "초심자", description: "", mainDisplay: "Y", type: .oneDay),
                CategoryDTO(categoryId: "4", name: "이색요가", description: "", mainDisplay: "Y", type: .oneDay),
                CategoryDTO(categoryId: "5", name: "전통 요가", description: "", mainDisplay: "Y", type: .oneDay)
            ]
        ) { categoryId in
            print("Tapped category: \(categoryId)")
        }
    }
    .background(Color.gray.opacity(0.1))
}
