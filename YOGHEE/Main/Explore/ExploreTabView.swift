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
                .font(.largeTitle)
                .foregroundColor(.primary)
            
            Text("탐색 탭입니다")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.99, green: 0.98, blue: 0.96))
    }
}

#Preview {
    ExploreTabView()
}
