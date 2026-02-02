//
//  MessageBoxView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

struct MessageBoxView: View {
    @StateObject private var container = MessageBoxContainer()
    
    var body: some View {
        VStack {
            Text("메시지함")
                .pretendardFont(.bold, size: 34)
                .foregroundColor(.primary)
            
            Text("알림 메시지 목록입니다")
                .pretendardFont(.regular, size: 17)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
        .navigationTitle("메시지함")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MessageBoxView()
    }
}
