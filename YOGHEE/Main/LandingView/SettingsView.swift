//
//  SettingsView.swift
//  YOGHEE
//
//  Created by 0ofKim on 1/24/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var container = SettingsContainer()
    
    var body: some View {
        VStack {
            Text("설정")
                .pretendardFont(.bold, size: 34)
                .foregroundColor(.primary)
            
            Text("앱 설정 페이지입니다")
                .pretendardFont(.regular, size: 17)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
