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
                .font(.largeTitle)
                .foregroundColor(.primary)
            
            Text("콘텐츠 탭입니다")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.99, green: 0.98, blue: 0.96))
    }
}

#Preview {
    ContentTabView()
}
