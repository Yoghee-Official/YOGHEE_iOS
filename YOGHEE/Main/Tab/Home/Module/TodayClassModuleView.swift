//
//  TodayClassModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

struct TodayClassModuleView: View {
    let item: TodayClassDTO
    /// 영역 클릭 시 마이페이지 랜딩
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(item.message)
                    .pretendardFont(.bold, size: 12)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(Color.GheeYellow)
            .cornerRadius(21)
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 7.5)
        .onTapGesture {
            onTap()
        }
    }
}
