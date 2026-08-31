//
//  MyPageEmptyView.swift
//  YOGHEE
//
//  Created by 0ofKim on 2/4/26.
//

import SwiftUI

struct MyPageEmptyView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.pretendard(.medium, size: 12))
            .multilineTextAlignment(.center)
            .foregroundColor(Color.Info)
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.top, 80)
            .padding(.bottom, 72)
    }
}

#Preview {
    MyPageEmptyView(message: "예약된 수련이 없습니다.")
}
