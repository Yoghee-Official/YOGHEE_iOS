//
//  ContentTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

struct ContentTabView: View {
    @StateObject private var container = ContentTabContainer()
    
    var body: some View {
        VStack {
            Text("Content Tab")
                .pretendardFont(.bold, size: 34)
                .foregroundColor(.primary)
            
            Text("콘텐츠 탭입니다")
                .pretendardFont(.regular, size: 17)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
    }
}

#Preview {
    ContentTabView()
}
