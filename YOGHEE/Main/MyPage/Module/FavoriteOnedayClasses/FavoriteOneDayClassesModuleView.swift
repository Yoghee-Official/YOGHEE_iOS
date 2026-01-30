//
//  FavoriteOneDayClassesModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct FavoriteOneDayClassesModuleView: View {
    let centers: [CenterDTO]
    let onItemTap: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12.ratio()) {
                ForEach(centers, id: \.centerId) { item in
                    YogaCenterItemView(yogaCenter: item, onTap: {
                        onItemTap(item.centerId)
                    })
                }
            }
            .padding(.horizontal, 16.ratio())
        }
        .padding(.vertical, 12.ratio())
    }
}

#Preview {
    FavoriteOneDayClassesModuleView(
        centers: [],
        onItemTap: { _ in }
    )
}
