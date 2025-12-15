//
//  NotificationListView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

struct NotificationListView: View {
    var body: some View {
        VStack {
            Text("Notification List")
                .pretendardFont(.bold, size: 34)
                .foregroundColor(.primary)
            
            Text("알림 목록입니다")
                .pretendardFont(.regular, size: 17)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
    }
}

#Preview {
    NotificationListView()
}
