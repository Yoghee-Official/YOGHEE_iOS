//
//  MyPageSectionHeaderView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI

struct MyPageSectionHeaderView: View {
    let title: String
    let titleType: MyPageSection.TitleType
    @Binding var isYogini: Bool  // true = 요기니, false = 지도자
    let onMoreButtonTap: (() -> Void)?
    
    var body: some View {
        HStack {
            // 왼쪽: 제목
            Text(title)
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            
            Spacer()
            
            // 오른쪽: TitleType에 따라 분기
            switch titleType {
            case .toggle:
                InstructorToggleView(
                    isYogini: $isYogini
                )
            case .moreButton:
                if let onMoreButtonTap = onMoreButtonTap {
                    MoreButtonView(onTap: onMoreButtonTap)
                }
            case .none:
                EmptyView()
            }
        }
        .frame(height: 32)
        .padding(.horizontal, 24.ratio())
    }
}

// MARK: - 지도자/요기니 토글 뷰
struct InstructorToggleView: View {
    @Binding var isYogini: Bool  // true = 요기니, false = 지도자
    
    var body: some View {
        HStack(spacing: 0) {
            // 지도자 버튼
            Button(action: {
                isYogini = false
            }) {
                Text("지도자")
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(!isYogini ? .DarkBlack : .gray)
                    .frame(maxWidth: .infinity)
            }
            
            // 요기니 버튼
            Button(action: {
                isYogini = true
            }) {
                Text("요기니")
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(isYogini ? .DarkBlack : .gray)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: 143, height: 32)
        .background(
            ZStack {
                // 전체 배경
                Capsule()
                    .fill(Color.white)
                
                // 활성화된 버튼 배경
                GeometryReader { geometry in
                    Capsule()
                        .fill(isYogini ? Color.GheeYellow : Color.FlowBlue)
                        .frame(width: geometry.size.width / 2)
                        .offset(x: isYogini ? geometry.size.width / 2 : 0)
                }
            }
        )
    }
}

// MARK: - 목록 더보기 버튼
struct MoreButtonView: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text("목록 더보기")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .padding(.horizontal, 8.ratio())
                .padding(.vertical, 8.ratio())
                .background(Color.Background)
                .cornerRadius(8.ratio())
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // 토글 예시
        MyPageSectionHeaderView(
            title: "이번주 수련 목록",
            titleType: .toggle,
            isYogini: .constant(true),
            onMoreButtonTap: nil
        )
        
        // 더보기 버튼 예시
        MyPageSectionHeaderView(
            title: "예약한 수련 미리보기",
            titleType: .moreButton,
            isYogini: .constant(false),
            onMoreButtonTap: {
                print("목록 더보기 클릭")
            }
        )
        
        // 헤더 없음 예시
        MyPageSectionHeaderView(
            title: "세부 항목",
            titleType: .none,
            isYogini: .constant(false),
            onMoreButtonTap: nil
        )
    }
    .padding()
}
