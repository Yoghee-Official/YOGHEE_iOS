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
                .font(.largeTitle)
                .foregroundColor(.primary)
            
            Text("알림 목록입니다")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.99, green: 0.98, blue: 0.96))
    }
}

#Preview {
    NotificationListView()
}