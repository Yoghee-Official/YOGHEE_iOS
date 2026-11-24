//
//  LoadingView.swift
//  DopiDopi
//
//  공통 로딩 인디케이터 (피그마 LD_MO_1 / LoadingIcon 컴포넌트 기준)
//  기존에 로딩 표시로 쓰던 ProgressView()를 대체하는 용도.
//
//  애니메이션: 피그마 "LoadingIcon · Elastic"을 Lottie로 내보낸 파일 (91x41, 3.6초 주기 무한 반복)
//  - 에셋: Assets.xcassets/LoadingIconLottie (데이터 에셋, JSON)
//  - 전체 화면 / 섹션 / 목록 하단 / 버튼 / 당겨서 새로고침 로딩이 모두 LoadingIconView 하나를 사용
//

import SwiftUI
import Lottie

struct LoadingView: View {
    var body: some View {
        LoadingIconView()
            // 배경색은 칠하지 않고(화면마다 배경이 달라 caller가 이미 그리고 있음),
            // 주어진 공간을 꽉 채우면서 아이콘만 정중앙에 위치시킴
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - LoadingIconView

/// 로딩 애니메이션 아이콘. 어느 화면에서든 피그마 가이드 크기 91x41pt로 고정
struct LoadingIconView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// 여러 곳에서 동시에 떠도 JSON은 한 번만 읽도록 공유
    private static let animation = LottieAnimation.asset("LoadingIconLottie")

    var body: some View {
        LottieView(animation: Self.animation)
            .playbackMode(reduceMotion ? .paused(at: .progress(0)) : .playing(.toProgress(1, loopMode: .loop)))
            .resizable()
            .frame(width: Metric.width, height: Metric.height)
            .accessibilityElement()
            .accessibilityLabel("로딩 중")
    }

    enum Metric {
        static let width: CGFloat = 91
        static let height: CGFloat = 41
    }
}

#Preview {
    VStack(spacing: 40) {
        LoadingView()
            .frame(height: 300)
            .background(Color.SandBeige)
        LoadingIconView()
    }
}
