//
//  MemberLookupView.swift
//  YOGHEE
//
//  회원 조회(SM_MO_1, Figma 3-13160 하루수련 / 3-13074 정규수련)
//  - 1a 뒤로가기: 마이페이지로 이동, 1b 타이틀: 회원 조회
//  - 2a 하루수련/정규수련 토글
//  - 2b 하루수련 유닛: 회원명, 회원ID, 하루수련 태그, 신규회원 태그, 주 이용 유형, 최근방문, 누적방문
//  - 2c 정규수련 유닛: 회원명, 회원ID, 정규수련 태그, 재등록회원 태그, 등록 기간, 잔여기간, 잔여/총 횟수
//  - 2d 더보기(정규수련 탭만): 활성 회원 → 수강권 정지, 비활성 회원 → 수강권 재개
//

import SwiftUI

struct MemberLookupView: View {
    @StateObject private var container = MemberLookupContainer()

    var body: some View {
        VStack(spacing: 0) {
            // 2a 하루수련 / 정규수련 토글
            MemberLookupTabToggle(selectedTab: container.state.selectedTab) { tab in
                container.handleIntent(.selectTab(tab))
            }
            .padding(.top, 16)
            .padding(.bottom, 16)

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.SandBeige)
        .customNavigationBar(title: "회원 조회")
        .onAppear {
            container.handleIntent(.load)
        }
        .overlay {
            if let member = container.state.pendingMember, let action = container.state.pendingAction {
                MessageBoxAlertView(
                    message: action.confirmMessage,
                    cancelTitle: "닫기",
                    onConfirm: { container.handleIntent(.confirmTicketAction) },
                    onDismiss: { container.handleIntent(.dismissTicketAction) }
                )
                .id(member.userUuid)
            } else if let message = container.state.alertMessage {
                MessageBoxAlertView(
                    message: message,
                    onConfirm: { container.handleIntent(.dismissAlert) },
                    onDismiss: { container.handleIntent(.dismissAlert) }
                )
            } else if container.state.isProcessing {
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
            }
        }
    }

    // MARK: - 2b / 2c 회원 유닛 목록
    @ViewBuilder
    private var content: some View {
        let list = container.state.currentList
        let tab = container.state.selectedTab

        if !list.hasLoaded {
            Spacer()
            LoadingView()
            Spacer()
        } else if let errorMessage = list.errorMessage, list.members.isEmpty {
            Spacer()
            VStack(spacing: 16) {
                Text(errorMessage)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
                    .multilineTextAlignment(.center)
                Button("다시 시도") {
                    container.handleIntent(.retry)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)
            Spacer()
        } else if list.members.isEmpty {
            // 회원이 없을 경우 방어 화면 (피그마 node-id 1926-27246)
            Spacer()
            Text("조회할 회원이 없습니다.")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .tracking(-0.408)
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(list.members) { member in
                        let isMenuOpen = container.state.moreMenuMemberId == member.userUuid
                        MemberLookupCardView(
                            member: member,
                            tab: tab,
                            isMoreMenuOpen: isMenuOpen,
                            onMoreTap: { container.handleIntent(.toggleMoreMenu(member.userUuid)) },
                            onTicketActionTap: { container.handleIntent(.requestTicketAction(member)) }
                        )
                        // 더보기 메뉴가 아래 카드 위로 보이도록
                        .zIndex(isMenuOpen ? 1 : 0)
                        .onAppear {
                            container.handleIntent(.loadMoreIfNeeded(currentId: member.userUuid))
                        }
                    }

                    if list.isLoading {
                        ProgressView()
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 16.ratio())
                .padding(.bottom, 40.ratio())
                // 2d 버튼 외 영역 클릭 시 커스텀 팝업 비노출
                .contentShape(Rectangle())
                .onTapGesture {
                    if container.state.moreMenuMemberId != nil {
                        container.handleIntent(.toggleMoreMenu(nil))
                    }
                }
            }
        }
    }
}

// MARK: - 2a 하루수련 / 정규수련 토글 (하루수련: NatureGreen, 정규수련: FlowBlue)
private struct MemberLookupTabToggle: View {
    let selectedTab: MemberLookupTab
    let onSelect: (MemberLookupTab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MemberLookupTab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab
                Button {
                    onSelect(tab)
                } label: {
                    Text(tab.title)
                        .pretendardFont(isSelected ? .bold : .regular, size: 14)
                        .foregroundColor(.DarkBlack)
                        .tracking(-0.408)
                        .opacity(isSelected ? 1 : 0.2)
                        .frame(width: 72, height: 32)
                        .background(
                            Capsule()
                                .fill(isSelected ? tab.selectedColor : Color.clear)
                                .shadow(color: .black.opacity(isSelected ? 0.1 : 0), radius: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            Capsule()
                .fill(Color.CleanWhite)
                // 피그마 inset shadow(0 0 4 rgba(0,0,0,0.15)) 근사
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.15), lineWidth: 2)
                        .blur(radius: 2)
                        .clipShape(Capsule())
                )
        )
        .animation(.easeInOut(duration: 0.15), value: selectedTab)
    }
}

private extension MemberLookupTab {
    var selectedColor: Color {
        switch self {
        case .oneDay: return .NatureGreen
        case .regular: return .FlowBlue
        }
    }
}

// MARK: - 2b / 2c 회원 유닛
private struct MemberLookupCardView: View {
    let member: LeaderMemberDTO
    let tab: MemberLookupTab
    let isMoreMenuOpen: Bool
    let onMoreTap: () -> Void
    let onTicketActionTap: () -> Void

    /// 2d 더보기는 정규수련 탭에서만 노출
    private var showsMoreButton: Bool { tab == .regular }
    /// 수강권 정지 회원은 비활성화(회색) 처리
    private var isPaused: Bool { member.isTicketPaused }
    private var textColor: Color { isPaused ? .Info : .DarkBlack }

    var body: some View {
        VStack(spacing: 16) {
            header

            Rectangle()
                .fill(Color.Background)
                .frame(width: 280.ratio(), height: 1)

            stats
        }
        .tracking(-0.408)
        .padding(.horizontal, 12)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color.CleanWhite)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Background, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            if showsMoreButton {
                Button(action: onMoreTap) {
                    Image("MoreIcon")
                        .resizable()
                        .frame(width: 4, height: 16)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
                .padding(.trailing, 2)
            }
        }
        .overlay(alignment: .topTrailing) {
            if showsMoreButton && isMoreMenuOpen {
                MemberTicketMenu(
                    title: isPaused ? MemberTicketAction.resume.menuTitle : MemberTicketAction.pause.menuTitle,
                    action: onTicketActionTap
                )
                .padding(.top, 24)
                .padding(.trailing, 28)
            }
        }
    }

    // 회원명 / 회원ID / 수련 유형 태그 / 신규·재등록 태그
    private var header: some View {
        HStack(spacing: 12) {
            Text(member.name ?? member.nickname ?? "회원")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(textColor)
                .lineLimit(1)

            Text(member.displayId ?? member.nickname ?? "")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(textColor)
                .lineLimit(1)

            HStack(spacing: 8) {
                Text(tab.title)
                    .pretendardFont(.regular, size: 10)
                    .foregroundColor(.DarkBlack)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isPaused ? Color.Info : tab.selectedColor)
                    .clipShape(Capsule())

                if !isPaused, let badge = badge {
                    Text(badge.text)
                        .pretendardFont(.medium, size: 10)
                        .foregroundColor(.CleanWhite)
                        .padding(.horizontal, 4)
                        .frame(height: 17)
                        .background(badge.color)
                        .cornerRadius(2)
                }
            }
            .fixedSize()
        }
        // 더보기 아이콘 영역과 겹치지 않도록
        .padding(.horizontal, showsMoreButton ? 12 : 0)
    }

    /// 하루수련: 신규회원 태그 유/무, 정규수련: 재등록회원 태그 유/무
    private var badge: (text: String, color: Color)? {
        switch tab {
        case .oneDay:
            return member.memberStatus == .NEW ? ("신규회원", .MindOrange) : nil
        case .regular:
            return member.reRegistered == true ? ("재등록회원", .SkyBlue) : nil
        }
    }

    private var stats: some View {
        HStack(spacing: 28) {
            switch tab {
            case .oneDay:
                stat(value: member.usageTypeText ?? "-", label: "주 이용 유형")
                stat(value: MemberVisitFormatter.recentVisitText(member.lastReservedAt), label: "최근방문")
                stat(value: "\(member.attendedCount ?? 0)회", label: "누적방문")
            case .regular:
                stat(value: member.registeredMonths.map { "\($0)개월" } ?? "-", label: "등록 기간")
                stat(value: member.remainingDays.map { "\($0)일" } ?? "-", label: "잔여기간")
                stat(value: sessionsText, label: "잔여/총 횟수")
            }
        }
        .foregroundColor(textColor)
    }

    /// 잔여횟수: (잔여횟수 / 총 횟수). 횟수제 이용권이 없으면 "-"
    private var sessionsText: String {
        guard let remaining = member.remainingSessions, let total = member.totalSessions else { return "-" }
        return "\(remaining) / \(total)"
    }

    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .pretendardFont(.bold, size: 16)
                .lineLimit(1)
            Text(label)
                .pretendardFont(.medium, size: 12)
                .lineLimit(1)
                .fixedSize()
        }
        .frame(minWidth: 48)
    }
}

// MARK: - 2d 더보기 메뉴 (수강권 정지 / 수강권 재개)
private struct MemberTicketMenu: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .pretendardFont(.regular, size: 14)
                .foregroundColor(.DarkBlack)
                .tracking(-0.408)
                .padding(12)
                .background(Color.CleanWhite)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.Background, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 최근 방문 표기
/// 마지막 예약 일자 기준. 일 단위로 노출, 14일 이상이면 주 단위, 30일 이상이면 월 단위
enum MemberVisitFormatter {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        return calendar
    }()

    static func recentVisitText(_ dateString: String?, now: Date = Date()) -> String {
        guard let date = ReservationDateParser.date(from: dateString) else { return "-" }
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: date),
            to: calendar.startOfDay(for: now)
        ).day ?? 0

        // TODO: 기획 확정 시 당일 표기 교체 (SB에 0일 표기 미정의)
        if days <= 0 { return "오늘" }
        if days < 14 { return "\(days)일전" }
        if days < 30 { return "\(days / 7)주전" }
        return "\(days / 30)개월전"
    }
}

#Preview {
    NavigationStack {
        MemberLookupView()
    }
}
