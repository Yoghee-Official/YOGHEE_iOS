//
//  AttendanceCheckBottomSheetView.swift
//  YOGHEE
//
//  마이페이지(지도자) "오늘의 수업" 3d 영역 클릭 시 노출되는 출석체크 바텀시트
//  피그마 참고: node-id 3-13279
//

import SwiftUI

struct AttendanceCheckBottomSheetView: View {
    let classItem: YogaClassScheduleDTO

    @StateObject private var container: AttendanceCheckContainer
    @Environment(\.dismiss) private var dismiss

    init(classItem: YogaClassScheduleDTO) {
        self.classItem = classItem
        _container = StateObject(wrappedValue: AttendanceCheckContainer(sessionId: classItem.sessionId))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Home Indicator
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.Info)
                .frame(width: 80.ratio(), height: 4.ratio())
                .padding(.top, 16.ratio())
                .padding(.bottom, 20.ratio())

            // 클릭한 수련 유닛 상단 노출
            YogaClassScheduleItemView(item: classItem, onTap: {}, userRole: .instructor)
                .allowsHitTesting(false)
                .padding(.horizontal, 16.ratio())

            header
                .padding(.horizontal, 16.ratio())
                .padding(.top, 12.ratio())

            content
        }
        .background(Color.CleanWhite)
        .onAppear { container.handleIntent(.load) }
        .overlay {
            if container.state.reservationIdPendingCancel != nil {
                ReservationCancelAlertView(
                    onConfirm: { container.handleIntent(.confirmCancelReservation) },
                    onDismiss: { container.handleIntent(.dismissCancelAlert) }
                )
            }
        }
    }

    // MARK: - 요기니 만나보기 / 한 번에 출석
    private var header: some View {
        HStack {
            Text("요기니 만나보기")
                .pretendardFont(.bold, size: 14)
                .foregroundColor(.DarkBlack)

            Spacer()

            Button(action: { container.handleIntent(.checkAllAttendance) }) {
                Text("한 번에 출석")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.MindOrange)
                    .underline()
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var content: some View {
        if container.state.isLoading {
            LoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = container.state.errorMessage {
            VStack(spacing: 16.ratio()) {
                Text(errorMessage)
                    .pretendardFont(.regular, size: 12)
                    .foregroundColor(.gray)
                Button("다시 시도") {
                    container.handleIntent(.load)
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if container.state.members.isEmpty {
            MyPageEmptyView(message: "예약한 회원이 없습니다.")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(spacing: 15.ratio()) {
                    ForEach(container.state.members) { member in
                        AttendanceMemberRowView(
                            member: member,
                            reservedDateText: sessionDateText,
                            reservedTimeText: sessionTimeText,
                            onToggleAttendance: {
                                container.handleIntent(.toggleAttendance(reservationId: member.reservationId))
                            },
                            onRequestCancel: {
                                container.handleIntent(.requestCancelReservation(reservationId: member.reservationId))
                            }
                        )
                    }
                }
                .padding(.horizontal, 16.ratio())
                .padding(.top, 12.ratio())
                .padding(.bottom, 16.ratio())
            }

            completeButton
        }
    }

    private var completeButton: some View {
        Button(action: { dismiss() }) {
            Text("출석체크 완료")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56.ratio())
                .background(Color.MindOrange)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 세션 일자/시간 포맷 (모든 회원 유닛 공통)

    private var sessionStartDate: Date? {
        guard let startsAt = container.state.session?.startsAt else { return nil }
        if let date = Self.isoFormatterWithFraction.date(from: startsAt) {
            return date
        }
        return Self.isoFormatter.date(from: startsAt)
    }

    private var sessionDateText: String {
        guard let date = sessionStartDate else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }

    private var sessionTimeText: String {
        guard let date = sessionStartDate else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter.string(from: date)
    }

    private static let isoFormatter: ISO8601DateFormatter = ISO8601DateFormatter()
    private static let isoFormatterWithFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

#Preview {
    AttendanceCheckBottomSheetView(
        classItem: YogaClassScheduleDTO(
            classId: "1",
            className: "자연에서 즐기는 야외 요가",
            day: "2025-12-24",
            dayOfWeek: 2,
            thumbnailUrl: "https://via.placeholder.com/48",
            address: "서울 관악구",
            attendance: 23,
            isPast: false,
            categories: [],
            sessionId: "session-1"
        )
    )
}
