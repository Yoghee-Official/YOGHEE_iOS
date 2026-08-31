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
                .pretendardFont(.bold, size: 34)
                .foregroundColor(.primary)
            
            Text("티타임 탭입니다")
                .pretendardFont(.regular, size: 17)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
    }
}

#Preview {
    TeaTimeTabView()
}
