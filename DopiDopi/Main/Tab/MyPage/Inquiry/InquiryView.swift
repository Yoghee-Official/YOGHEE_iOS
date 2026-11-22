//
//  InquiryView.swift
//  YOGHEE
//
//  나의 문의(CS_MO_2, Figma 1336-16852 / 1336-16632) - 마이 탭 > 세부 항목 "나의 문의" (요기니 전용)
//  - 1a 뒤로가기: 직전에 보고 있던 화면으로 이동 / 1b 타이틀: 나의 문의
//  - 2 문의함 종류: 2a 문의하기(기본 활성화) / 2b 나의 문의함 (클릭 시 활성화되며 영역 리프레시)
//  - 3a 카카오톡 채팅 문의: 클릭 시 A18 얼럿 → 확인 시 카카오톡 채널 채팅 연결
//  - 4a 문의 유형 드롭다운 / 4b 내용(최대 500자) / 4c 문의 등록(미작성 시 비활성화) / 4d 안내 문구
//  - 5a 문의 내역: 제목·상태값 노출, 클릭 시 내용(+답변완료 시 답변) 펼침 / 재클릭 시 접힘
//

import SwiftUI

struct InquiryView: View {
    @StateObject private var container = InquiryContainer()
    @FocusState private var isContentFocused: Bool

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text(container.state.selectedTab.sectionTitle)
                    .pretendardFont(.bold, size: 16)
                    .foregroundColor(.DarkBlack)
                    .tracking(-0.408)
                    .padding(.horizontal, 24)

                // 2: 문의함 종류
                tabChips
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                Group {
                    switch container.state.selectedTab {
                    case .inquire:
                        inquireSection
                    case .myInquiries:
                        myInquiriesSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .padding(.top, 21)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                isContentFocused = false
                container.handleIntent(.closeCategoryDropdown)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.SandBeige.ignoresSafeArea())
        // 1a: 뒤로가기 / 1b: 타이틀
        .customNavigationBar(title: "나의 문의")
        .overlay {
            if container.state.isSubmitting {
                LoadingView()
                    .background(Color.black.opacity(0.001))
            }
        }
        .overlay { alerts }
        .onAppear { container.handleIntent(.load) }
    }

    // MARK: - 2 문의함 종류

    private var tabChips: some View {
        HStack(spacing: 8) {
            ForEach(InquiryTab.allCases, id: \.self) { tab in
                Button {
                    isContentFocused = false
                    container.handleIntent(.selectTab(tab))
                } label: {
                    InquiryChip(
                        title: tab.title,
                        isActive: container.state.selectedTab == tab
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 문의하기 탭 (3, 4)

    private var inquireSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            kakaoChatCard

            inquiryFormCard
                .padding(.top, 8)

            // 4d: 안내 문구
            Text("답변이 등록되면 메시지함을 통해 알려드릴게요!")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.Info)
                .tracking(-0.408)
                .padding(.horizontal, 8)
                .padding(.top, 16)
        }
    }

    /// 3a: 카카오톡 채팅 문의
    private var kakaoChatCard: some View {
        Button {
            isContentFocused = false
            container.handleIntent(.tapKakaoChat)
        } label: {
            HStack(spacing: 8) {
                Text("채팅 문의")
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(.DarkBlack)
                    .tracking(-0.408)

                Spacer(minLength: 0)

                HStack(spacing: 24) {
                    Text("카카오톡 열기")
                        .pretendardFont(.regular, size: 14)
                        .foregroundColor(.DarkBlack)
                        .tracking(-0.408)
                    Image("NextIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 7, height: 11)
                }
            }
            .padding(24)
            .inquiryCardStyle()
        }
        .buttonStyle(.plain)
    }

    /// 4: 1:1 문의 작성
    private var inquiryFormCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("문의 유형")
                .padding(.horizontal, 4)

            // 4a: 문의 유형 드롭다운
            InquiryCategoryDropdown(
                categories: container.state.categories,
                selected: container.state.selectedCategory,
                isOpen: container.state.isCategoryDropdownOpen,
                onToggle: {
                    isContentFocused = false
                    container.handleIntent(.toggleCategoryDropdown)
                },
                onSelect: { container.handleIntent(.selectCategory($0)) }
            )
            .padding(.top, 19)
            .zIndex(1)

            // 4b: 내용
            VStack(alignment: .leading, spacing: 18) {
                sectionLabel("내용")

                Rectangle()
                    .fill(Color.DarkBlack)
                    .frame(height: 0.5)

                contentEditor
            }
            .padding(.horizontal, 4)
            .padding(.top, 20)

            // 4c: 문의 등록
            submitButton
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 25)
        .inquiryCardStyle()
    }

    private var contentEditor: some View {
        ZStack(alignment: .topLeading) {
            if container.state.content.isEmpty {
                Text("문의 내용을 작성해주세요.")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
                    .tracking(-0.408)
                    .allowsHitTesting(false)
            }

            TextEditor(text: Binding(
                get: { container.state.content },
                set: { container.handleIntent(.updateContent($0)) }
            ))
            .pretendardFont(.medium, size: 12)
            .foregroundColor(.DarkBlack)
            .tracking(-0.408)
            .scrollContentBackground(.hidden)
            .focused($isContentFocused)
            // TextEditor 기본 내부 여백 보정 → placeholder와 첫 글자 위치를 맞춘다
            .padding(.horizontal, -5)
            .padding(.vertical, -8)
            .onChange(of: isContentFocused) { _, focused in
                if focused { container.handleIntent(.closeCategoryDropdown) }
            }
        }
        .frame(height: 130, alignment: .topLeading)
    }

    private var submitButton: some View {
        let enabled = container.state.canSubmit
        return Button {
            isContentFocused = false
            container.handleIntent(.submit)
        } label: {
            Text("문의 등록")
                .pretendardFont(.semiBold, size: 15)
                .foregroundColor(enabled ? .DarkBlack : .Info)
                .tracking(-0.408)
                .frame(width: 208, height: 48)
                .background {
                    if enabled {
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.925, blue: 0.451),
                                Color(red: 1.0, green: 0.945, blue: 0.600),
                                Color(red: 1.0, green: 0.965, blue: 0.745)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 104
                        )
                    } else {
                        Color.Background
                    }
                }
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    // MARK: - 나의 문의함 탭 (5)

    @ViewBuilder
    private var myInquiriesSection: some View {
        let state = container.state
        if let errorMessage = state.listErrorMessage, state.inquiries.isEmpty {
            VStack(spacing: 12) {
                Text(errorMessage)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
                    .multilineTextAlignment(.center)
                Button("다시 시도") {
                    container.handleIntent(.retryList)
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        } else if state.inquiries.isEmpty {
            if state.isLoadingList || !state.hasLoadedList {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else {
                Text("등록된 문의가 없습니다.")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
                    .tracking(-0.408)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            }
        } else {
            LazyVStack(spacing: 8) {
                ForEach(state.inquiries) { inquiry in
                    InquiryItemView(
                        inquiry: inquiry,
                        isExpanded: state.expandedInquiryIds.contains(inquiry.inquiryId)
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            container.handleIntent(.toggleInquiry(inquiry.inquiryId))
                        }
                    }
                    .onAppear {
                        container.handleIntent(.loadMoreIfNeeded(currentId: inquiry.inquiryId))
                    }
                }

                if state.isLoadingList {
                    ProgressView()
                        .padding(.vertical, 16)
                }
            }
        }
    }

    // MARK: - 얼럿

    @ViewBuilder
    private var alerts: some View {
        if container.state.showKakaoAlert {
            // A18: 카카오톡 채팅 문의 연결
            MessageBoxAlertView(
                message: "카카오톡 채팅 문의로 연결합니다.\n카카오톡을 열겠습니까?",
                confirmTitle: "확인",
                cancelTitle: "닫기",
                onConfirm: { container.handleIntent(.confirmKakaoChat) },
                onDismiss: { container.handleIntent(.dismissKakaoAlert) }
            )
        } else if let message = container.state.message {
            MessageBoxAlertView(
                message: message,
                onConfirm: { container.handleIntent(.dismissMessage) },
                onDismiss: { container.handleIntent(.dismissMessage) }
            )
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .pretendardFont(.bold, size: 14)
            .foregroundColor(.DarkBlack)
            .tracking(-0.408)
    }
}

// MARK: - 칩 (2 문의함 종류 / 5a 상태값)

private struct InquiryChip: View {
    let title: String
    var isActive: Bool = false
    var background: Color? = nil
    var foreground: Color = .DarkBlack

    var body: some View {
        Text(title)
            .pretendardFont(.medium, size: 12)
            .foregroundColor(foreground)
            .tracking(-0.408)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(background ?? (isActive ? Color.NatureGreen : Color.Background))
            .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

// MARK: - 4a 문의 유형 드롭다운

private struct InquiryCategoryDropdown: View {
    let categories: [InquiryCategoryDto]
    let selected: InquiryCategoryDto?
    let isOpen: Bool
    let onToggle: () -> Void
    let onSelect: (InquiryCategoryDto) -> Void

    private let headerHeight: CGFloat = 30
    private let rowHeight: CGFloat = 26
    private let maxHeight: CGFloat = 194

    var body: some View {
        ZStack(alignment: .top) {
            if isOpen {
                optionList
            }
            header
        }
        // 펼친 목록은 아래 콘텐츠 위로 겹쳐 보이도록 레이아웃 높이는 헤더만 차지한다
        .frame(height: headerHeight, alignment: .top)
    }

    private var header: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Text(selected?.label ?? "문의하실 내용의 유형을 선택해주세요.")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                    .tracking(-0.408)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image("DropdownArrowIcon")
                    .resizable()
                    .frame(width: 12.71, height: 7.06)
                    .rotationEffect(.degrees(isOpen ? 180 : 0))
            }
            .padding(.horizontal, 16)
            .frame(height: headerHeight)
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

    private var optionList: some View {
        let listHeight = min(headerHeight + 4 + rowHeight * CGFloat(categories.count) + 4, maxHeight)
        return ScrollView(.vertical) {
            VStack(spacing: 0) {
                ForEach(categories, id: \.code) { category in
                    Button {
                        onSelect(category)
                    } label: {
                        Text(category.label)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                            .tracking(-0.408)
                            .lineLimit(1)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, minHeight: rowHeight, alignment: .leading)
                            .background(selected?.code == category.code ? Color.Background : Color.clear)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, headerHeight + 4)
            .padding(.bottom, 4)
        }
        .frame(height: listHeight)
        .background(Color.CleanWhite)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Background, lineWidth: 1)
        )
    }
}

// MARK: - 5a 문의 내역 유닛

private struct InquiryItemView: View {
    let inquiry: InquiryDto
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Text(inquiry.title)
                            .pretendardFont(.bold, size: 14)
                            .foregroundColor(.DarkBlack)
                            .tracking(-0.408)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        if !inquiry.statusText.isEmpty {
                            statusChip
                                .fixedSize()
                        }
                    }

                    Spacer(minLength: 0)

                    Image("NextIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 7, height: 11)
                        .rotationEffect(.degrees(90))
                }
                .padding(24)
                .inquiryCardStyle()
            }
            .buttonStyle(.plain)

            if isExpanded {
                detailCard
            }
        }
    }

    /// 답변완료: 검정 배경 / 접수완료·답변대기: 회색 배경
    private var statusChip: some View {
        let answered = inquiry.inquiryStatus == .answered
        return InquiryChip(
            title: inquiry.statusText,
            background: answered ? .DarkBlack : .Background,
            foreground: answered ? .CleanWhite : .DarkBlack
        )
    }

    /// 펼침: 내용 (+ 답변완료 시 답변) - 글자 잘림 없이 전체 노출
    private var detailCard: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    label("내용")
                    Spacer(minLength: 0)
                    Image("NextIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 7, height: 11)
                        .rotationEffect(.degrees(-90))
                }

                Rectangle()
                    .fill(Color.DarkBlack)
                    .frame(height: 0.5)

                bodyText(inquiry.content ?? "")

                if inquiry.isAnswered, let answer = inquiry.answer {
                    VStack(alignment: .leading, spacing: 18) {
                        label("답변")
                        bodyText(answer)
                    }
                    .padding(.top, 6)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .inquiryCardStyle()
        }
        .buttonStyle(.plain)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .pretendardFont(.bold, size: 14)
            .foregroundColor(.DarkBlack)
            .tracking(-0.408)
    }

    private func bodyText(_ text: String) -> some View {
        Text(text)
            .pretendardFont(.medium, size: 12)
            .foregroundColor(.Info)
            .tracking(-0.408)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 카드 스타일 (흰 배경 + 회색 테두리)

private extension View {
    /// 드롭다운처럼 카드 밖으로 겹쳐 그려지는 콘텐츠가 잘리지 않도록 clip 없이 배경만 둥글게 그린다
    func inquiryCardStyle() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.CleanWhite)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: 1)
            )
            .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        InquiryView()
    }
}
