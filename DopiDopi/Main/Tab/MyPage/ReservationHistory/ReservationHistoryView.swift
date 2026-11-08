//
//  ReservationHistoryView.swift
//  YOGHEE
//
//  요기니 마이페이지 > 예약한 수련 미리보기 "목록 더보기" > 내역 보기 (RC_MO_1, Figma 3-22331 / 3-22241 / 3-22637)
//  지도자는 이 화면이 아니라 개설한 수련 목록(OC_MO_1)으로 이동
//

import SwiftUI

struct ReservationHistoryView: View {
    @StateObject private var container = ReservationHistoryContainer()

    var body: some View {
        VStack(spacing: 0) {
            // 2a / 2c / 2d: 정렬 필터 + 탭
            filterBar
                .padding(.horizontal, 24.ratio())
                .padding(.top, 16.ratio())
                .padding(.bottom, 20.ratio())
                .zIndex(1)

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.SandBeige)
        .customNavigationBar(title: "내역 보기")
        .onAppear {
            container.handleIntent(.load)
        }
        .overlay {
            if container.state.pendingCancel != nil {
                ReservationPaymentCancelAlertView(
                    onConfirm: { container.handleIntent(.confirmCancel) },
                    onDismiss: { container.handleIntent(.dismissCancel) }
                )
            }
        }
    }

    // MARK: - 2a / 2c / 2d: 정렬 필터 + 탭
    private var filterBar: some View {
        HStack(spacing: 0) {
            sortButton
                .overlay(alignment: .topLeading) {
                    if container.state.showSortPopup {
                        ReservationSortPopup(
                            selectedSort: container.state.sort,
                            onClose: { container.handleIntent(.toggleSortPopup) },
                            onSortChange: { container.handleIntent(.changeSort($0)) }
                        )
                        .offset(x: -12, y: -12)
                    }
                }

            Spacer(minLength: 8)

            HStack(spacing: 8.ratio()) {
                ForEach(ReservationHistoryTab.allCases, id: \.self) { tab in
                    Button {
                        container.handleIntent(.selectTab(tab))
                    } label: {
                        Text(tab.title)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                            .tracking(-0.408)
                            .padding(.horizontal, 12.ratio())
                            .padding(.vertical, 8)
                            .background(container.state.selectedTab == tab ? Color.NatureGreen : Color.Background)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var sortButton: some View {
        Button {
            container.handleIntent(.toggleSortPopup)
        } label: {
            ReservationSortLabel(title: container.state.sort?.title ?? "정렬순")
        }
        .buttonStyle(.plain)
    }

    // MARK: - 3b ~ 3e: 유닛 목록
    @ViewBuilder
    private var content: some View {
        if container.state.isLoading {
            Spacer()
            LoadingView()
            Spacer()
        } else if let errorMessage = container.state.errorMessage {
            Spacer()
            VStack(spacing: 16) {
                Text(errorMessage)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
                    .multilineTextAlignment(.center)
                Button("다시 시도") {
                    container.handleIntent(.load)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)
            Spacer()
        } else if container.state.currentItems.isEmpty {
            Spacer()
            Text(container.state.selectedTab.emptyMessage)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.Info)
                .tracking(-0.408)
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 8.ratio()) {
                    ForEach(container.state.currentItems) { reservation in
                        switch container.state.selectedTab {
                        case .reserved:
                            ReservedClassCardView(
                                reservation: reservation,
                                onCancelTap: { container.handleIntent(.requestCancel(reservation)) }
                            )
                        case .expired:
                            ExpiredClassCardView(reservation: reservation)
                        }
                    }
                }
                .padding(.horizontal, 16.ratio())
                .padding(.bottom, 40.ratio())
            }
        }
    }
}

// MARK: - 3b / 3c: 예약된 수련 유닛 (취소 완료 시 결제 취소 유닛)
private struct ReservedClassCardView: View {
    let reservation: ReservationDTO
    let onCancelTap: () -> Void

    var body: some View {
        ReservationCardContainer(isCancelled: reservation.isCancelled) {
            ReservationClassInfo(reservation: reservation)
        } button: {
            if reservation.isCancelled {
                // 3c: 결제 취소 유닛 (하루수련만 결제 취소 가능), 클릭 시 반응 없음
                ReservationCardButtonLabel(title: "결제 취소 완료", style: .cancelled)
            } else if reservation.isRegular {
                // 정규수련: 상담 상태 영역 (클릭 불가능, 비활성화)
                ReservationCardButtonLabel(title: "상담 예약 완료 (답변 평균 3일)", style: .disabled)
            } else {
                Button(action: onCancelTap) {
                    ReservationCardButtonLabel(title: "예약 및 결제 취소하기", style: .outline)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - 3d / 3e: 만료 유닛 + 수련 기록 버튼
private struct ExpiredClassCardView: View {
    let reservation: ReservationDTO

    var body: some View {
        ReservationCardContainer(isCancelled: false) {
            ReservationClassInfo(reservation: reservation)
        } button: {
            if reservation.isRegular {
                // 정규수련: 상담 상태 영역 (클릭 불가능, 비활성화)
                ReservationCardButtonLabel(title: "상담 완료", style: .gray)
            } else {
                // 하루수련: 출석 완료 시에만 작성 가능, 작성한 기록이 있으면 보기
                switch reservation.review {
                case .writable:
                    Button {
                        print("✍️ [내역 보기] 수련 기록 남기기 클릭 - TODO: 수련 기록 작성 팝업(RC_MO_1_popup) 이동 (reservationId: \(reservation.reservationId))")
                    } label: {
                        ReservationCardButtonLabel(title: "수련 기록 남기기", style: .orange)
                    }
                    .buttonStyle(.plain)
                case .written:
                    Button {
                        print("📝 [내역 보기] 수련 기록 보기 클릭 - TODO: 수련 기록 목록 화면 이동 (reviewId: \(reservation.reviewId ?? "-"))")
                    } label: {
                        ReservationCardButtonLabel(title: "수련 기록 보기", style: .gray)
                    }
                    .buttonStyle(.plain)
                case .expired, nil:
                    // 작성 기간 만료, 결석·취소한 수업 등은 버튼 미노출
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - 예약 유닛 공통 정보 (정규/하루수련)
private struct ReservationClassInfo: View {
    let reservation: ReservationDTO

    var body: some View {
        // startsAt 파싱은 카드당 한 번만
        let startDate = reservation.startDate
        let dayText = ReservationDateParser.dayText(startDate)
        let timeText = ReservationDateParser.timeText(startDate)

        if reservation.isRegular {
            // 정규수련: 수련원명 / 지도자명(원장님 이름) / 구분값 / 예약일시 (만료 항목은 수련명 | 예약일시 | 예약시간)
            ReservationCardInfo(
                thumbnail: reservation.thumbnail,
                title: reservation.centerName ?? reservation.className ?? "",
                subtitle: reservation.instructorText,
                isRegular: true
            ) {
                ReservationScheduleRow(
                    texts: reservation.isCompleted ? [reservation.className ?? "", dayText, timeText] : [dayText]
                )
            }
        } else {
            // 하루수련: 수련명 / 수련원 주소 / 구분값 / 예약일시 | 예약시간
            ReservationCardInfo(
                thumbnail: reservation.thumbnail,
                title: reservation.className ?? "",
                subtitle: reservation.address,
                isRegular: false
            ) {
                ReservationScheduleRow(texts: [dayText, timeText])
            }
        }
    }
}

// MARK: - 유닛 레이아웃 공통

/// 카드 바탕 (흰 배경 + 테두리, 결제 취소 유닛은 #EFEDEB 고정)
private struct ReservationCardContainer<Info: View, ButtonContent: View>: View {
    let isCancelled: Bool
    @ViewBuilder let info: Info
    @ViewBuilder let button: ButtonContent

    var body: some View {
        VStack(spacing: 12.ratio()) {
            info
            button
        }
        .padding(.vertical, 20.ratio())
        .padding(.horizontal, 20.ratio())
        .frame(maxWidth: .infinity)
        .background(isCancelled ? Color.Background : Color.CleanWhite)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isCancelled ? Color.clear : Color.Background, lineWidth: 1)
        )
    }
}

/// 대표이미지 + 제목 / 부제 / 구분값 + 하단 정보
private struct ReservationCardInfo<Detail: View>: View {
    let thumbnail: String?
    let title: String
    let subtitle: String?
    let isRegular: Bool
    @ViewBuilder let detail: Detail

    private var thumbnailURL: URL? {
        guard let thumbnail, !thumbnail.isEmpty else { return nil }
        return URL(string: thumbnail)
    }

    var body: some View {
        let thumbnailURL = thumbnailURL
        HStack(alignment: .top, spacing: 16.ratio()) {
            // 대표이미지가 내려오지 않으면 이미지 영역 미노출
            if let thumbnailURL {
                AsyncImage(url: thumbnailURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.Background
                }
                .frame(width: 65.ratio(), height: 65.ratio())
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.07), radius: 5)
            }

            VStack(alignment: .leading, spacing: 12.ratio()) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .pretendardFont(.bold, size: 14)
                        .foregroundColor(.DarkBlack)
                        .lineLimit(1)
                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.Info)
                            .lineLimit(1)
                    }
                    ClassTypeTag(isRegular: isRegular)
                }
                .tracking(-0.408)
                // 이미지가 있을 때만 이미지 높이(65)에 맞춰 세로 가운데 정렬
                .frame(minHeight: thumbnailURL != nil ? 65.ratio() : nil, alignment: .leading)

                detail
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// 정규수련(FlowBlue) / 하루수련(NatureGreen) 구분값
private struct ClassTypeTag: View {
    let isRegular: Bool

    var body: some View {
        Text(isRegular ? "정규수련" : "하루수련")
            .pretendardFont(.regular, size: 10)
            .foregroundColor(.DarkBlack)
            .tracking(-0.408)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isRegular ? Color.FlowBlue : Color.NatureGreen)
            .cornerRadius(4)
    }
}

/// "하타 | 2026년 02월 28일 | 오전 9:00" (세로 구분선 #B3B3B3)
private struct ReservationScheduleRow: View {
    let texts: [String]

    var body: some View {
        let visibleTexts = texts.filter { !$0.isEmpty }
        HStack(spacing: 10.ratio()) {
            ForEach(Array(visibleTexts.enumerated()), id: \.offset) { index, text in
                if index > 0 {
                    Rectangle()
                        .fill(Color.Info)
                        .frame(width: 1, height: 12)
                }
                cardInfoText(text)
            }
        }
    }
}

private func cardInfoText(_ text: String) -> some View {
    Text(text)
        .pretendardFont(.medium, size: 12)
        .foregroundColor(.DarkBlack)
        .tracking(-0.408)
        .lineLimit(1)
}

private struct ReservationCardButtonLabel: View {
    enum Style {
        /// 수련 기록 남기기 (#FF5520)
        case orange
        /// 예약 및 결제 취소하기
        case outline
        /// 수련 기록 보기 / 상담 완료
        case gray
        /// 상담 예약 완료 (비활성화, 글자 #8F8F8F)
        case disabled
        /// 결제 취소 완료
        case cancelled
    }

    let title: String
    let style: Style

    private var backgroundColor: Color {
        switch style {
        case .orange: return .MindOrange
        case .outline: return .CleanWhite
        case .gray, .disabled, .cancelled: return .Background
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline, .gray, .disabled: return .Background
        case .cancelled: return .Info
        case .orange: return .clear
        }
    }

    private var textColor: Color {
        switch style {
        case .orange: return .white
        case .disabled: return Color(hex: "8F8F8F")
        case .outline, .gray, .cancelled: return .DarkBlack
        }
    }

    var body: some View {
        Text(title)
            .pretendardFont(.medium, size: 12)
            .foregroundColor(textColor)
            .tracking(-0.408)
            .frame(maxWidth: .infinity)
            .frame(height: 30.ratio())
            .background(backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}

// MARK: - Alert_13: 예약 및 결제 취소 확인 팝업
private struct ReservationPaymentCancelAlertView: View {
    /// "확인" - 취소 요청(CL_MO_1) 화면 이동
    let onConfirm: () -> Void
    /// "닫기" / 바깥 딤 영역 탭 - 팝업 닫고 유지
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 17.ratio()) {
                Text("예약 및 결제를 취소 하시겠습니까?")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                    .tracking(-0.408)
                    .multilineTextAlignment(.center)

                HStack(spacing: 17.ratio()) {
                    Button(action: onDismiss) {
                        Text("닫기")
                            .pretendardFont(.regular, size: 14)
                            .foregroundColor(.DarkBlack)
                            .frame(width: 82.ratio(), height: 35.ratio())
                            .background(Color.Background)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    Button(action: onConfirm) {
                        Text("확인")
                            .pretendardFont(.regular, size: 14)
                            .foregroundColor(.white)
                            .frame(width: 82.ratio(), height: 35.ratio())
                            .background(Color(hex: "5D4634"))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 71.ratio())
            .padding(.vertical, 12.ratio())
            .background(Color.CleanWhite)
            .cornerRadius(7)
            .shadow(color: .black.opacity(0.07), radius: 5)
        }
    }
}

// MARK: - 2a: 정렬 필터 팝업 (최신순 / 결제순 / 예약순)
private struct ReservationSortLabel: View {
    let title: String

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .tracking(-0.408)
            Image("DownArrowIcon")
                .resizable()
                .frame(width: 8, height: 4)
        }
    }
}

private struct ReservationSortPopup: View {
    let selectedSort: ReservationHistorySort?
    let onClose: () -> Void
    let onSortChange: (ReservationHistorySort) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onClose) {
                ReservationSortLabel(title: selectedSort?.title ?? "정렬순")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
            }
            .buttonStyle(.plain)

            Divider()
                .frame(height: 1)
                .background(Color.black)

            VStack(spacing: 8) {
                ForEach(ReservationHistorySort.allCases, id: \.self) { sort in
                    Button {
                        onSortChange(sort)
                    } label: {
                        Text(sort.title)
                            .pretendardFont(selectedSort == sort ? .bold : .medium, size: 12)
                            .foregroundColor(.DarkBlack)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(width: 104.ratio())
        .background(Color.SandBeige)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Background, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        ReservationHistoryView()
    }
}
