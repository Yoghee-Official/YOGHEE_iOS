//
//  MyPageTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

struct MyPageTabView: View {
    @StateObject private var container = MyPageTabContainer()
    
    var body: some View {
        VStack {
            Text("My Page Tab")
                .pretendardFont(.bold, size: 34)
                .foregroundColor(.primary)
            
            Text("마이페이지 탭입니다")
                .pretendardFont(.regular, size: 17)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
    }
}

#Preview {
    MyPageTabView()
}
