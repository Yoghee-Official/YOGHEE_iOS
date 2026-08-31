//
//  ClassRegisterSharedViews.swift
//  YOGHEE
//
//  클래스 등록 플로우 공통: 섹션 헤더, 아웃라인 카드 스타일
//

import SwiftUI

// MARK: - Section Header (제목 bold 16 + 서브텍스트 optional)

struct ClassRegisterSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.ratio()) {
            Text(title)
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            if let subtitle = subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .pretendardFont(.regular, size: 10)
                    .foregroundColor(.Info)
            }
        }
    }
}

// MARK: - Outlined Card (흰 배경 + 테두리, 수련 장소 등록 등에서 재사용)

struct ClassRegisterOutlinedCard<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16.ratio())
            .background(Color.CleanWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: 1)
            )
    }
}

// MARK: - Outlined Field Style (한 줄 입력 필드 공통 스타일)

struct ClassRegisterOutlinedFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16.ratio())
            .padding(.vertical, 8.ratio())
            .frame(height: 49.ratio())
            .background(Color.CleanWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: 1)
            )
    }
}

extension View {
    func classRegisterOutlinedFieldStyle() -> some View {
        modifier(ClassRegisterOutlinedFieldStyle())
    }
}
