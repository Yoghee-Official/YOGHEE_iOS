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
        let nativeAppKey: String = "4658f101e43fb7489f830c7dfa84e1e9" // info로 숨기기
        KakaoSDK.initSDK(appKey: nativeAppKey)
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
