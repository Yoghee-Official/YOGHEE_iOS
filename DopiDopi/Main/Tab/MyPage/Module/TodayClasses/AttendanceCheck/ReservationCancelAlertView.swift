//
//  ReservationCancelAlertView.swift
//  YOGHEE
//
//  출석체크 바텀시트 "예약 취소하기" 확인 팝업
//  피그마 참고: Alert_5 (예약을 취소 하시겠습니까?)
//

import SwiftUI

struct ReservationCancelAlertView: View {
    /// "취소하기" - 예약 취소 확정
    let onConfirm: () -> Void
    /// "닫기" - 팝업 닫고 유지
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 17.ratio()) {
                Text("예약을 취소 하시겠습니까?")
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
                        Text("취소하기")
                            .pretendardFont(.regular, size: 14)
                            .foregroundColor(.white)
                            .frame(width: 82.ratio(), height: 35.ratio())
                            .background(Color.MindOrange)
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

#Preview {
    ReservationCancelAlertView(onConfirm: {}, onDismiss: {})
}
