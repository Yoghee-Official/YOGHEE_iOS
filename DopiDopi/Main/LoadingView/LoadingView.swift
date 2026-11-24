//
//  LoadingView.swift
//  DopiDopi
//
//  공통 로딩 인디케이터 (피그마 LD_MO_1 / LoadingIcon 컴포넌트 기준)
//  기존에 로딩 표시로 쓰던 ProgressView()를 대체하는 용도.
//
//  애니메이션: 피그마 "LoadingIcon · Elastic"을 Lottie로 내보낸 파일 (103x47, 3.6초 주기 무한 반복)
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

/// 로딩 애니메이션 아이콘 (피그마 기준 103x47)
struct LoadingIconView: View {
    enum Size {
        /// 피그마 원본 크기 (103x47) - 화면 전체 / 오버레이 로딩
        case regular
        /// 60% 크기 (약 62x28) - 섹션 안, 목록 하단, 버튼, 이미지 셀 로딩
        case small

        var scale: CGFloat {
            switch self {
            case .regular: return 1
            case .small: return 0.6
            }
        }
    }

    /// 피그마 크기(103x47) 대비 배율. 화면 비율(ratio)은 내부에서 함께 적용됨
    var scale: CGFloat = 1

    init(size: Size = .regular) {
        self.scale = size.scale
    }

    init(scale: CGFloat) {
        self.scale = scale
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// 여러 곳에서 동시에 떠도 JSON은 한 번만 읽도록 공유
    private static let animation = LottieAnimation.asset("LoadingIconLottie")

    var body: some View {
        let factor = CGFloat(1).ratio() * scale

        LottieView(animation: Self.animation)
            .playbackMode(reduceMotion ? .paused(at: .progress(0)) : .playing(.toProgress(1, loopMode: .loop)))
            .resizable()
            .frame(width: Metric.width * factor, height: Metric.height * factor)
            .accessibilityElement()
            .accessibilityLabel("로딩 중")
    }

    private enum Metric {
        static let width: CGFloat = 103
        static let height: CGFloat = 47
    }
}

#Preview {
    VStack(spacing: 40) {
        LoadingView()
            .frame(height: 300)
            .background(Color.SandBeige)
        LoadingIconView(size: .small)
    }
}
