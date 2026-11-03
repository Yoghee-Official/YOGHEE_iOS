//
//  MessageBoxAlertView.swift
//  YOGHEE
//
//  메세지함(MS_MO_1) 화면 팝업
//  - 2d 삭제: A2 메세지 삭제 얼럿 ("닫기" / "삭제하기")
//  - 삭제·모두 읽음 실패 안내: cancelTitle 없이 "확인" 버튼 하나만 노출
//

import SwiftUI

struct MessageBoxAlertView: View {
    let message: String
    var confirmTitle: String = "확인"
    /// nil이면 확인 버튼 하나만 노출
    var cancelTitle: String? = nil
    var confirmColor: Color = .LandBrown
    let onConfirm: () -> Void
    /// 닫기 버튼 · 바깥 딤 영역 탭 - 팝업만 닫음
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 17.ratio()) {
                Text(message)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                    .tracking(-0.408)
                    .multilineTextAlignment(.center)

                HStack(spacing: 17.ratio()) {
                    if let cancelTitle {
                        Button(action: onDismiss) {
                            Text(cancelTitle)
                                .pretendardFont(.regular, size: 14)
                                .foregroundColor(.DarkBlack)
                                .frame(width: 82.ratio(), height: 35.ratio())
                                .background(Color.Background)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }

                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .pretendardFont(.regular, size: 14)
                            .foregroundColor(.white)
                            .frame(width: 82.ratio(), height: 35.ratio())
                            .background(confirmColor)
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
    MessageBoxAlertView(
        message: "메세지를 삭제하시겠습니까?",
        confirmTitle: "삭제하기",
        cancelTitle: "닫기",
        confirmColor: .MindOrange,
        onConfirm: {},
        onDismiss: {}
    )
}
