//
//  MessageBoxView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//
//  마이페이지 > 메세지함 (MS_MO_1, Figma 3-6174)
//  - 1c 모두 읽음: 현재 탭의 안읽은 메세지를 모두 비활성화 컬러로 변경 (없으면 변화 없음)
//  - 2a 탭: 전체 / 신규알림 / 공지사항 / 문의사항
//  - 2b 유닛 클릭: 읽음 처리 + 펼치기 / 다시 클릭하면 접기
//  - 2d 유닛 우→좌 스와이프: 삭제 아이콘 노출, 클릭 시 A2 삭제 얼럿
//

import SwiftUI

struct MessageBoxView: View {
    @StateObject private var container = MessageBoxContainer()

    /// 삭제 아이콘이 노출된(스와이프된) 메세지 - 한 번에 하나만 열린다
    @State private var swipedMessageId: String?
    @State private var pendingDeleteMessageId: String?
    @State private var hasLoaded = false

    var body: some View {
        VStack(spacing: 0) {
            // 2a: 메세지 탭
            tabBar
                .padding(.horizontal, 16.ratio())
                .padding(.top, 16.ratio())

            messageList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.SandBeige)
        .customNavigationBar(
            title: "메세지함",
            trailingTitle: "모두 읽음",
            onTrailingTap: {
                swipedMessageId = nil
                container.handleIntent(.markAllAsRead)
            }
        )
        .onAppear {
            guard !hasLoaded else { return }
            hasLoaded = true
            container.handleIntent(.loadMessages)
        }
        .overlay {
            if let messageId = pendingDeleteMessageId {
                MessageBoxAlertView(
                    message: "메세지를 삭제하시겠습니까?",
                    confirmTitle: "삭제하기",
                    cancelTitle: "닫기",
                    confirmColor: .MindOrange,
                    onConfirm: {
                        pendingDeleteMessageId = nil
                        swipedMessageId = nil
                        container.handleIntent(.deleteMessage(messageId))
                    },
                    onDismiss: { pendingDeleteMessageId = nil }
                )
            } else if let message = container.state.alertMessage {
                MessageBoxAlertView(
                    message: message,
                    onConfirm: { container.handleIntent(.dismissAlert) },
                    onDismiss: { container.handleIntent(.dismissAlert) }
                )
            }
        }
    }

    // MARK: - 2a: 메세지 탭
    private var tabBar: some View {
        HStack(spacing: 8.ratio()) {
            ForEach(MessageBoxTab.allCases, id: \.self) { tab in
                let isSelected = container.state.selectedTab == tab
                Button {
                    swipedMessageId = nil
                    container.handleIntent(.selectTab(tab))
                } label: {
                    Text(tab.title)
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                        .tracking(-0.408)
                        .padding(.horizontal, 12.ratio())
                        .padding(.vertical, 8.ratio())
                        .background(isSelected ? Color.NatureGreen : Color.Background)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - 2b: 메세지 목록
    @ViewBuilder
    private var messageList: some View {
        if container.state.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
        } else if let errorMessage = container.state.errorMessage {
            MyPageEmptyView(message: errorMessage)
        } else if container.state.messages.isEmpty {
            MyPageEmptyView(message: container.state.selectedTab == .unread ? "새로운 메세지가 없습니다." : "받은 메세지가 없습니다.")
        } else {
            ScrollView {
                LazyVStack(spacing: 12.ratio()) {
                    ForEach(container.state.messages) { message in
                        MessageBoxItemView(
                            message: message,
                            detail: container.state.details[message.id],
                            isExpanded: container.state.expandedMessageIds.contains(message.id),
                            isLoadingDetail: container.state.loadingDetailIds.contains(message.id),
                            swipedMessageId: $swipedMessageId,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    container.handleIntent(.toggleMessage(message.id))
                                }
                            },
                            onDeleteTap: { pendingDeleteMessageId = message.id }
                        )
                        .onAppear {
                            if message.id == container.state.messages.last?.id {
                                container.handleIntent(.loadNextPage)
                            }
                        }
                    }

                    if container.state.isLoadingMore {
                        ProgressView()
                            .padding(.vertical, 16.ratio())
                    }
                }
                .padding(.horizontal, 16.ratio())
                .padding(.top, 22.ratio())
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - 메세지 유닛 (2b 접힌 카드 + 2c 펼친 내용 + 2d 스와이프 삭제)
private struct MessageBoxItemView: View {
    let message: NotificationListItemDTO
    let detail: NotificationDetailDTO?
    let isExpanded: Bool
    let isLoadingDetail: Bool
    @Binding var swipedMessageId: String?
    let onTap: () -> Void
    let onDeleteTap: () -> Void

    @State private var dragOffset: CGFloat = 0

    private let cardHeight: CGFloat = 74.ratio()
    private let deleteButtonWidth: CGFloat = 74.ratio()

    private var isSwiped: Bool { swipedMessageId == message.id }

    private var cardOffset: CGFloat {
        let base: CGFloat = isSwiped ? -deleteButtonWidth : 0
        return min(0, max(-deleteButtonWidth, base + dragOffset))
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .trailing) {
                deleteButton
                    .opacity(cardOffset < 0 ? 1 : 0)

                // 탭·드래그 영역이 카드와 함께 이동하도록 offset은 제스처 뒤에 적용 (열린 상태에서 삭제 버튼이 가려지지 않게)
                cardHeader
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if swipedMessageId != nil {
                            // 삭제 아이콘이 열려 있으면 먼저 닫기만 한다
                            let wasThisCard = isSwiped
                            withAnimation(.easeOut(duration: 0.2)) { swipedMessageId = nil }
                            if wasThisCard { return }
                        }
                        onTap()
                    }
                    .simultaneousGesture(swipeGesture)
                    .offset(x: cardOffset)
            }
            .frame(height: cardHeight)

            // 2c: 메세지 내용
            if isExpanded {
                messageContent
            }
        }
        .debugViewName(kind: .item)
    }

    // MARK: 접힌 카드
    private var cardHeader: some View {
        HStack(spacing: 13.ratio()) {
            thumbnailView

            VStack(alignment: .leading, spacing: 4.5) {
                Text(primaryTitle)
                    .pretendardFont(.bold, size: 12)
                    .foregroundColor(.DarkBlack)
                    .lineLimit(1)
                    .truncationMode(.tail)

                subInfoView
            }
            .tracking(-0.408)
            .frame(maxWidth: .infinity, alignment: .leading)

            dateBadge
        }
        .padding(.horizontal, 16.ratio())
        .padding(.vertical, 10.ratio())
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        // 2b: 활성화(안읽음) #FFEC73, 비활성화(읽음) #EFEDEB
        .background(message.isRead ? Color.Background : Color.GheeYellow)
        .cornerRadius(8)
    }

    /// 대표이미지 - 전체 공지는 앱 기본 로고
    @ViewBuilder
    private var thumbnailView: some View {
        if message.isLeaderMessage {
            AsyncImage(url: URL(string: message.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 48.ratio(), height: 48.ratio())
            .clipShape(Circle())
        } else {
            Circle()
                .fill(Color.CleanWhite)
                .frame(width: 48.ratio(), height: 48.ratio())
                .overlay(
                    Image("Yoghee")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34.ratio())
                )
        }
    }

    /// 수업명 (전체 공지는 제목). 영역 초과 시 말줄임
    private var primaryTitle: String {
        if message.isLeaderMessage, let className = message.className, !className.isEmpty {
            return className
        }
        return message.title
    }

    /// 지도자 메시지: 수업장소(시·구) | 수련 인원, 전체 공지: 발신자
    @ViewBuilder
    private var subInfoView: some View {
        if message.isLeaderMessage {
            HStack(spacing: 6.ratio()) {
                if !location.isEmpty {
                    Text(location)
                        .pretendardFont(.medium, size: 10)
                        .foregroundColor(.DarkBlack)
                        .lineLimit(1)
                }

                if !location.isEmpty, reservedCountText != nil {
                    Rectangle()
                        .fill(Color.DarkBlack)
                        .frame(width: 1, height: 10.ratio())
                }

                if let reservedCountText {
                    Text("수련 인원 \(reservedCountText)명")
                        .pretendardFont(.medium, size: 10)
                        .foregroundColor(.DarkBlack)
                        .lineLimit(1)
                }
            }
        } else {
            Text(message.senderName ?? "팀 요기")
                .pretendardFont(.medium, size: 10)
                .foregroundColor(.DarkBlack)
                .lineLimit(1)
        }
    }

    /// 수업장소: 시, 구 단위까지만 노출 (서버에서 내려준 값 그대로)
    private var location: String {
        [message.sido, message.sigungu]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// 수업인원: 999명 초과 시 999+ (서버에서 "999+"로 내려주지만 숫자로 와도 처리)
    private var reservedCountText: String? {
        guard let count = message.reservedCount, !count.isEmpty else { return nil }
        if let number = Int(count), number > 999 { return "999+" }
        return count
    }

    // MARK: 일자/요일
    private var dateBadge: some View {
        VStack(spacing: 0) {
            Text(dayNumber)
                .pretendardFont(.bold, size: 20)
                .foregroundColor(.DarkBlack)
            Text(dayOfWeekString)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .tracking(-0.408)
        }
        .frame(width: 36.ratio(), height: 53.ratio())
        .background(GlassUI.reservedClass())
    }

    /// publishedAt(yyyy-MM-ddTHH:mm:ss)에서 일자만 추출 (예: 2026-10-05T.. → 5)
    private var dayNumber: String {
        guard let publishedAt = message.publishedAt else { return "" }
        let components = publishedAt.prefix(10).split(separator: "-")
        guard components.count >= 3, let day = Int(components[2]) else { return "" }
        return String(day)
    }

    /// 요일 (1=월 ~ 7=일). dayOfWeek가 없으면 publishedAt으로 계산
    private var dayOfWeekString: String {
        let weekdays = ["", "mon", "tue", "wed", "thu", "fri", "sat", "sun"]
        if let dayOfWeek = message.dayOfWeek, (1...7).contains(dayOfWeek) {
            return weekdays[dayOfWeek]
        }
        guard let publishedAt = message.publishedAt else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: String(publishedAt.prefix(10))) else { return "" }
        // Calendar weekday: 1=일 ~ 7=토 → 1=월 ~ 7=일
        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: date)
        return weekdays[(weekday + 5) % 7 + 1]
    }

    // MARK: 2c: 메세지 내용
    private var messageContent: some View {
        VStack(alignment: .leading, spacing: 14.ratio()) {
            if let detail {
                // 타이틀: 최대 1줄, 영역 초과 시 말줄임, 볼드
                Text(detail.title ?? message.title)
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(.DarkBlack)
                    .lineLimit(1)
                    .truncationMode(.tail)

                // 텍스트: 입력한 글자 전체 노출
                Text(detail.content ?? "")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                    .fixedSize(horizontal: false, vertical: true)
            } else if isLoadingDetail {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .tracking(-0.408)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20.ratio())
        .background(Color.CleanWhite)
        .cornerRadius(8)
    }

    // MARK: 2d: 삭제
    private var deleteButton: some View {
        Button(action: onDeleteTap) {
            Image("TrashIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 26.ratio(), height: 29.ratio())
                .frame(width: deleteButtonWidth, height: cardHeight)
                .background(Color.MindOrange)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    /// 우 → 좌 스와이프 시 삭제 아이콘 노출, 좌 → 우 스와이프 시 닫기
    /// 세로 스크롤을 막지 않도록 simultaneousGesture로 붙이고 가로 이동이 더 클 때만 반응한다
    private var swipeGesture: some Gesture {
        // 카드가 손가락을 따라 이동하므로 local 좌표 대신 global 좌표로 이동량을 계산
        DragGesture(minimumDistance: 20, coordinateSpace: .global)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                if swipedMessageId != nil && !isSwiped {
                    // 다른 카드가 열려 있으면 닫는다
                    withAnimation(.easeOut(duration: 0.2)) { swipedMessageId = nil }
                }
                dragOffset = value.translation.width
            }
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else {
                    dragOffset = 0
                    return
                }
                let base: CGFloat = isSwiped ? -deleteButtonWidth : 0
                let shouldOpen = base + value.translation.width < -deleteButtonWidth / 2
                withAnimation(.easeOut(duration: 0.2)) {
                    if shouldOpen {
                        swipedMessageId = message.id
                    } else if isSwiped {
                        swipedMessageId = nil
                    }
                    dragOffset = 0
                }
            }
    }
}

#Preview {
    NavigationStack {
        MessageBoxView()
    }
}
