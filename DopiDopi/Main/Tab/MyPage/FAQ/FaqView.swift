//
//  FaqView.swift
//  YOGHEE
//
//  FAQ(CS_MO_1, Figma 1336-16477) - 마이 탭 > 세부 항목 "FAQ"
//  - 1a 뒤로가기: 직전에 보고 있던 화면으로 이동 / 1b 타이틀: FAQ
//  - 2a FAQ 텍스트
//  - 3a 카테고리 칩: 첫 번째 칩 기본 활성화, 클릭 시 해당 카테고리 활성화 + 3b 영역 리프레시
//  - 3b 질문 & 답변: 질문만 노출, 클릭 시 펼쳐지며 답변 노출 / 재클릭 시 접힘
//

import SwiftUI

struct FaqView: View {
    @StateObject private var container: FaqContainer

    /// - Parameter role: 진입한 마이페이지 역할 (요기니 → YOGINI, 지도자 → LEADER)
    init(role: UserRole) {
        _container = StateObject(wrappedValue: FaqContainer(target: FaqTarget(role: role)))
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // 2a: FAQ 텍스트
                Text("FAQ")
                    .pretendardFont(.bold, size: 16)
                    .foregroundColor(.DarkBlack)
                    .tracking(-0.408)
                    .padding(.horizontal, 24)

                categoryChips
                    .padding(.top, 20)

                faqList
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
            }
            .padding(.top, 21)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.SandBeige.ignoresSafeArea())
        // 1a: 뒤로가기 / 1b: 타이틀
        .customNavigationBar(title: "FAQ")
        .overlay {
            if container.state.isLoading {
                LoadingView()
                    .background(Color.black.opacity(0.001))
            }
        }
        .onAppear { container.handleIntent(.load) }
    }

    // MARK: - 3a 카테고리 칩

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(container.state.categories, id: \.code) { category in
                    let isSelected = container.state.selectedCategoryCode == category.code
                    Button {
                        container.handleIntent(.selectCategory(category.code))
                    } label: {
                        Text(category.label)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                            .tracking(-0.408)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSelected ? Color.NatureGreen : Color.Background)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - 3b 질문 & 답변

    @ViewBuilder
    private var faqList: some View {
        if let errorMessage = container.state.errorMessage {
            VStack(spacing: 12) {
                Text(errorMessage)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
                Button("다시 시도") {
                    container.handleIntent(.retry)
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        } else if container.state.faqs.isEmpty {
            if !container.state.isLoading && container.state.selectedCategoryCode != nil {
                Text("등록된 질문이 없습니다.")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
                    .tracking(-0.408)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            }
        } else {
            VStack(spacing: 8) {
                ForEach(container.state.faqs) { faq in
                    FaqItemView(
                        faq: faq,
                        isExpanded: container.state.expandedFaqIds.contains(faq.faqId)
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            container.handleIntent(.toggleFaq(faq.faqId))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - FAQ 항목 (질문 + 펼침 시 답변)

private struct FaqItemView: View {
    let faq: FaqDto
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 12) {
                    Text("Q. \(faq.question)")
                        .pretendardFont(.bold, size: 14)
                        .foregroundColor(.DarkBlack)
                        .tracking(-0.408)
                        .lineLimit(isExpanded ? nil : 1)
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 접힘: 아래 방향 / 펼침: 위 방향
                    Image("NextIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 7, height: 11)
                        .rotationEffect(.degrees(isExpanded ? -90 : 90))
                }

                if isExpanded {
                    Rectangle()
                        .fill(Color.DarkBlack)
                        .frame(height: 1)

                    Text("A. \(faq.answer)")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.Info)
                        .tracking(-0.408)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.CleanWhite)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        FaqView(role: .yogini)
    }
}
