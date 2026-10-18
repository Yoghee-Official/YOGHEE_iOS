//
//  CenterManageAlertView.swift
//  YOGHEE
//
//  요가원 등록 및 관리(AP_MO_1) 화면 팝업
//  피그마 참고: node-id 3-11843 (A4, "등록된 주소를 삭제하시겠습니까?")
//  - 버튼은 "확인" 하나뿐이라, 취소는 바깥 딤 영역 탭으로 처리
//  - 삭제 실패 안내도 같은 스타일로 노출
//

import SwiftUI

struct CenterManageAlertView: View {
    let message: String
    /// "확인"
    let onConfirm: () -> Void
    /// 바깥 딤 영역 탭 - 팝업만 닫음
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
            .padding(.horizontal, 71.ratio())
            .padding(.vertical, 12.ratio())
            .background(Color.CleanWhite)
            .cornerRadius(7)
            .shadow(color: .black.opacity(0.07), radius: 5)
        }
    }
}

#Preview {
    CenterManageAlertView(message: "등록된 주소를 삭제하시겠습니까?", onConfirm: {}, onDismiss: {})
}
