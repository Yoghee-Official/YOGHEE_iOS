//
//  AttendanceMemberRowView.swift
//  YOGHEE
//
//  출석체크 바텀시트의 "예약한 회원" 유닛 (피그마 node-id 3-13279)
//

import SwiftUI

struct AttendanceMemberRowView: View {
    let member: LeaderSessionMemberDTO
    /// 세션 공통 예약 일자 ("2025년 12월 24일")
    let reservedDateText: String
    /// 세션 공통 예약 시간 ("오전 9:00")
    let reservedTimeText: String
    let onToggleAttendance: () -> Void
    let onRequestCancel: () -> Void

    private var isCancelled: Bool { member.attendanceStatus == .CANCELLED }
    private var isAttended: Bool { member.attendanceStatus == .ATTENDED }

    var body: some View {
        HStack(spacing: 15.ratio()) {
            memberInfoCard
            attendanceButton
        }
        .opacity(isCancelled ? 0.4 : 1.0)
        .debugViewName(kind: .item)
    }

    private var memberInfoCard: some View {
        VStack(alignment: .leading, spacing: 8.ratio()) {
            HStack(spacing: 6.ratio()) {
                Text(member.name ?? "회원")
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(.DarkBlack)
                    .lineLimit(1)

                if let memberStatus = member.memberStatus {
                    MemberBadgeView(memberStatus: memberStatus)
                }

                Spacer()

                if member.cancelable ?? false {
                    Button(action: onRequestCancel) {
                        Text("예약 취소하기")
                            .pretendardFont(.medium, size: 10)
                            .foregroundColor(.Info)
                            .underline()
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(member.displayId ?? member.nickname ?? "")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .lineLimit(1)

            HStack(spacing: 10.ratio()) {
                Text(reservedDateText)
                divider
                Text(reservedTimeText)
                divider
                Text("\(member.attendeeCount ?? 1)명")
            }
            .pretendardFont(.medium, size: 12)
            .foregroundColor(.DarkBlack)
        }
        .padding(.horizontal, 20.ratio())
        .padding(.vertical, 12.ratio())
        .frame(width: 246.ratio(), alignment: .leading)
        .background(Color.SandBeige)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Background, lineWidth: 1)
        )
        .cornerRadius(8)
    }

    private var attendanceButton: some View {
        Button(action: onToggleAttendance) {
            Group {
                if isAttended {
                    Image("CheckCircleIconFull")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44.ratio(), height: 44.ratio())
                } else {
                    Text("클릭시\n출석완료")
                        .pretendardFont(.regular, size: 14)
                        .foregroundColor(.Info)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 82.ratio(), height: 89.ratio())
            .background(Color.CleanWhite)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: 1)
            )
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .disabled(isCancelled)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.DarkBlack)
            .frame(width: 1, height: 12.ratio())
    }
}

// MARK: - 회원 유형 배지 (재등록회원 / 신규회원)
private struct MemberBadgeView: View {
    let memberStatus: MemberStatus

    private var text: String {
        memberStatus == .RETURNING ? "재등록회원" : "신규회원"
    }

    private var backgroundColor: Color {
        memberStatus == .RETURNING ? .SkyBlue : .MindOrange
    }

    var body: some View {
        Text(text)
            .pretendardFont(.medium, size: 10)
            .foregroundColor(.white)
            .padding(.horizontal, 4.ratio())
            .frame(height: 17.ratio())
            .background(backgroundColor)
            .cornerRadius(2)
    }
}

#Preview {
    VStack(spacing: 15) {
        AttendanceMemberRowView(
            member: LeaderSessionMemberDTO(
                reservationId: "1",
                userUuid: "uuid-1",
                name: "박정연",
                displayId: "Parkjomuregi",
                memberStatus: .RETURNING,
                nickname: nil,
                cancelable: true,
                attendeeCount: 1,
                attendanceStatus: .REGISTERED
            ),
            reservedDateText: "2025년 12월 24일",
            reservedTimeText: "오전 9:00",
            onToggleAttendance: {},
            onRequestCancel: {}
        )

        AttendanceMemberRowView(
            member: LeaderSessionMemberDTO(
                reservationId: "2",
                userUuid: "uuid-2",
                name: "박정연",
                displayId: "Parkjomuregi",
                memberStatus: .NEW,
                nickname: nil,
                cancelable: true,
                attendeeCount: 1,
                attendanceStatus: .ATTENDED
            ),
            reservedDateText: "2025년 12월 24일",
            reservedTimeText: "오전 9:00",
            onToggleAttendance: {},
            onRequestCancel: {}
        )
    }
    .padding()
    .background(Color.CleanWhite)
}
