//
//  LicenseCertificationAlertView.swift
//  YOGHEE
//
//  마이페이지에서 지도자 토글에 새로 진입했는데 아직 지도자 인증(자격증 등록)을 받지 않은 경우 노출하는 안내 팝업
//  피그마 참고: node-id 698-20054 (Alert_18)
//

import SwiftUI

struct LicenseCertificationAlertView: View {
    /// "확인" - 자격증 등록 화면으로 이동
    let onConfirm: () -> Void
    /// "닫기" - 요기니 마이페이지로 되돌아감
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 17.ratio()) {
                Text("지도자 인증을 하시겠습니까?")
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
                            .background(Color.LandBrown)
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
    LicenseCertificationAlertView(onConfirm: {}, onDismiss: {})
}
