//
//  TodayClassModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

struct TodayClassModuleView: View {
    let items: [TodayClassDTO]
    let onItemTap: (String) -> Void

    // TODO: [서버 협의 필요] TodayClassDTO.displayMessage 필드명이 확정되면 자동으로 반영됨
    // 서버에서 표시 문구를 완성해서 내려주므로 클라이언트는 그대로 표시
    // 방어 문구 처리(비로그인/수업없음/수업지남)도 서버에서 담당
    private var displayText: String {
        items.first?.displayMessage ?? ""
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(displayText)
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
            if let firstItem = items.first {
                onItemTap(firstItem.classId)
            }
        }
    }
}
