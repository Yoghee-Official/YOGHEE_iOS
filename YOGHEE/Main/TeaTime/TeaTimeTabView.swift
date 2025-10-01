//
//  TeaTimeTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

struct TeaTimeTabView: View {
    @StateObject private var container = TeaTimeTabContainer()
    
    var body: some View {
        VStack {
            Text("Tea Time Tab")
                .font(.largeTitle)
                .foregroundColor(.primary)
            
            Text("티타임 탭입니다")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.99, green: 0.98, blue: 0.96))
    }
}

#Preview {
    TeaTimeTabView()
}
