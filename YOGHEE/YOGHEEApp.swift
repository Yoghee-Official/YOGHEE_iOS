//
//  YOGHEEApp.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/3/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct YOGHEEApp: App {
    init() {
        guard let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String, !appKey.isEmpty else {
            assertionFailure("KAKAO_NATIVE_APP_KEY가 Info.plist에 설정되어 있지 않습니다.")
            return
        }
        KakaoSDK.initSDK(appKey: appKey)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    // 카카오 로그인 URL 스킴 처리
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
