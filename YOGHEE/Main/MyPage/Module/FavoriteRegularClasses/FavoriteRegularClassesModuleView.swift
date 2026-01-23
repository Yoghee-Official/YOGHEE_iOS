//
//  FavoriteRegularClassesModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct FavoriteRegularClassesModuleView: View {
    let classes: [ClassDTO]
    let onItemTap: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12.ratio()) {
                ForEach(classes, id: \.classId) { item in
                    FavoriteRegularClassItemView(item: item, onTap: { onItemTap(item.classId) })
                }
            }
            .padding(.horizontal, 16.ratio())
        }
        .padding(.vertical, 12.ratio())
    }
}

#Preview {
    FavoriteRegularClassesModuleView(
        classes: [],
        onItemTap: { _ in }
    )
}
