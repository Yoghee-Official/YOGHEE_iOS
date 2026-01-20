//
//  ReservedClassesModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct ReservedClassesModuleView: View {
    let classes: [YogaClassScheduleDTO]
    let onItemTap: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12.ratio()) {
                ForEach(classes, id: \.classId) { item in
                    YogaClassScheduleItemView(item: item, onTap: { onItemTap(item.classId) })
                }
            }
            .padding(.horizontal, 16.ratio())
        }
        .padding(.vertical, 12.ratio())
    }
}

#Preview {
    ReservedClassesModuleView(
        classes: [],
        onItemTap: { _ in }
    )
}
