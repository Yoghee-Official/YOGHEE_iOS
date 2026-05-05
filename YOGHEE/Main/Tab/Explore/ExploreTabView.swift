//
//  ExploreTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

struct ExploreTabView: View {
    @StateObject private var container = ExploreTabContainer()
    
    var body: some View {
        VStack {
            Text("Explore Tab")
                .pretendardFont(.bold, size: 34)
                .foregroundColor(.primary)
            
            Text("탐색 탭입니다")
                .pretendardFont(.regular, size: 17)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
    }
}

#Preview {
    ExploreTabView()
}
