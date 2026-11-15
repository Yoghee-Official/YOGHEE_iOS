//
//  TermsView.swift
//  YOGHEE
//
//  마이페이지 세부항목 "이용약관" > 약관 (TM_MO_1, Figma 259-16583)
//  각 메뉴 클릭 시 해당 약관 웹뷰(TU_MO_1 ~ TU_MO_4)로 랜딩
//

import SwiftUI

struct TermsView: View {
    var body: some View {
        // 2a: 메뉴
        VStack(alignment: .leading, spacing: 0) {
            ForEach(PolicyType.allCases) { policy in
                NavigationLink(value: MyPageNavigationDestination.policy(policy)) {
                    HStack(spacing: 8) {
                        Text(policy.menuTitle)
                            .pretendardFont(.bold, size: 14)
                            .foregroundColor(.DarkBlack)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        Image("FrontArrowLineIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 6, height: 12)
                    }
                    .padding(.horizontal, 24.ratio())
                    .frame(height: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.SandBeige)
        // 1a: 뒤로가기 / 1b: 타이틀
        .customNavigationBar(title: "약관")
    }
}

#Preview {
    NavigationStack {
        TermsView()
    }
}
