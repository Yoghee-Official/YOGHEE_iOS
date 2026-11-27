//
//  KakaoChannelChat.swift
//  DopiDopi
//
//  도피도피 카카오톡 채널 채팅 연결 (고객센터 문의)
//  - 마이페이지 문의하기(A18 확인 후)와 연결 오류 화면(ER_MO_1/2 "고객센터로 문의하기")에서 공통 사용
//  - 우리 서버를 거치지 않으므로 서비스 연결 오류 상황에서도 문의 경로로 쓸 수 있다
//

import UIKit
import KakaoSDKTalk

enum KakaoChannelChat {
    static let channelPublicId = "_xcExhvn"

    /// 카카오톡 채널 채팅을 연다. (카카오톡 미설치 시 SDK가 웹으로 연결)
    /// - Parameter onFailure: 연결 실패 시 메인 스레드에서 호출
    static func open(onFailure: @escaping @MainActor () -> Void) {
        TalkApi.shared.chatChannel(channelPublicId: channelPublicId) { error in
            guard let error else { return }
            print("❌ [KakaoChannelChat] 카카오톡 채널 채팅 연결 실패: \(error)")
            Task { @MainActor in onFailure() }
        }
    }

    /// 카카오톡 채널 채팅을 열고, 실패하면 브라우저로 채널 채팅 웹 페이지를 연다.
    /// 얼럿을 띄울 자리가 마땅치 않은 화면(연결 오류 화면 등)에서 사용한다.
    static func openWithWebFallback() {
        open {
            guard let url = TalkApi.shared.makeUrlForChatChannel(channelPublicId: channelPublicId) else { return }
            UIApplication.shared.open(url)
        }
    }
}
