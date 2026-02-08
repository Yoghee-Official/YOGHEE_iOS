//
//  FavoriteClassModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct FavoriteClassModuleView: View {
    let classes: [ClassDTO]
    let onItemTap: (String) -> Void
    
    var body: some View {
        if classes.isEmpty {
            MyPageEmptyView(message: "찜한 수련이 없습니다.")
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12.ratio()) {
                    ForEach(classes, id: \.classId) { item in
                        YogaClassItemView(yogaClass: item, ranking: nil, onTap: { onItemTap(item.classId) })
                    }
                }
                .padding(.horizontal, 16.ratio())
            }
            .padding(.vertical, 12.ratio())
        }
    }
}

#Preview {
    FavoriteClassModuleView(
        classes: [],
        onItemTap: { _ in }
    )
}
