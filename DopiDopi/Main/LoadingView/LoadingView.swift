//
//  LoadingView.swift
//  DopiDopi
//
//  공통 로딩 인디케이터 (피그마 LD_MO_1 / LoadingIcon 컴포넌트 기준)
//  기존에 로딩 표시로 쓰던 ProgressView()를 대체하는 용도.
//
//  애니메이션: 피그마 "디자인중" 페이지의 LoadingIcon · Elastic (node 1444:28827)
//  - 3.6초 주기 무한 반복, 한 주기 안에서 같은 동작이 1.6초 간격으로 두 번 재생됨
//  - 캐릭터: 오른쪽으로 7° 기울며 가로 1.04 / 세로 0.91로 눌렸다가 스프링으로 복귀
//  - 점 3개: 0.13초 간격으로 차례로 찌그러졌다 위로 튀어 오르는 탄성 바운스
//
//  아이콘 에셋:
//  - LoadingIcon: 캐릭터 라인 아트만 (55x47, 점은 따로 움직여야 해서 SVG에서 제거함)
//  - 점 3개는 코드로 그림 (Mind Orange, 7x7)

import SwiftUI

struct LoadingView: View {
    var body: some View {
        LoadingIconView()
            // 배경색은 칠하지 않고(화면마다 배경이 달라 caller가 이미 그리고 있음),
            // 주어진 공간을 꽉 채우면서 아이콘만 정중앙에 위치시킴
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - LoadingIconView

/// 캐릭터 + 점 3개로 구성된 애니메이션 로딩 아이콘 (피그마 기준 103x47)
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

    var body: some View {
        let factor = CGFloat(1).ratio() * scale

        ZStack(alignment: .topLeading) {
            character
            ForEach(0..<Metric.dotXs.count, id: \.self) { index in
                dot(index: index)
            }
        }
        .frame(width: Metric.width, height: Metric.height, alignment: .topLeading)
        // 피그마 좌표 그대로 배치한 뒤 통째로 확대/축소
        .scaleEffect(factor)
        .frame(width: Metric.width * factor, height: Metric.height * factor)
        .accessibilityElement()
        .accessibilityLabel("로딩 중")
    }

    // MARK: 캐릭터

    @ViewBuilder
    private var character: some View {
        let image = Image("LoadingIcon")
            .resizable()
            .frame(width: Metric.characterWidth, height: Metric.height)

        if reduceMotion {
            image
        } else {
            image.keyframeAnimator(initialValue: CharacterMotion(), repeating: true) { content, motion in
                content
                    .scaleEffect(x: motion.scaleX, y: motion.scaleY)
                    .rotationEffect(.degrees(motion.rotation))
            } keyframes: { _ in
                KeyframeTrack(\.rotation) {
                    Self.characterBurst(peak: 7, rest: 0)
                    LinearKeyframe(0, duration: Timing.burstInterval - Timing.characterBurst)
                    Self.characterBurst(peak: 7, rest: 0)
                    LinearKeyframe(0, duration: Timing.cycle - Timing.burstInterval - Timing.characterBurst)
                }
                KeyframeTrack(\.scaleX) {
                    Self.characterBurst(peak: 1.04, rest: 1)
                    LinearKeyframe(1, duration: Timing.burstInterval - Timing.characterBurst)
                    Self.characterBurst(peak: 1.04, rest: 1)
                    LinearKeyframe(1, duration: Timing.cycle - Timing.burstInterval - Timing.characterBurst)
                }
                KeyframeTrack(\.scaleY) {
                    Self.characterBurst(peak: 0.91, rest: 1)
                    LinearKeyframe(1, duration: Timing.burstInterval - Timing.characterBurst)
                    Self.characterBurst(peak: 0.91, rest: 1)
                    LinearKeyframe(1, duration: Timing.cycle - Timing.burstInterval - Timing.characterBurst)
                }
            }
        }
    }

    /// 0.16초 ease-in으로 peak까지 → 0.56초 스프링으로 rest 복귀
    @KeyframeTrackContentBuilder<CGFloat>
    private static func characterBurst(peak: CGFloat, rest: CGFloat) -> some KeyframeTrackContent<CGFloat> {
        LinearKeyframe(peak, duration: 0.16, timingCurve: .easeIn)
        SpringKeyframe(rest, duration: 0.56, spring: Timing.spring(for: 0.56))
    }

    // MARK: 점

    @ViewBuilder
    private func dot(index: Int) -> some View {
        let circle = Circle()
            .fill(Color.MindOrange)
            .frame(width: Metric.dotSize, height: Metric.dotSize)

        Group {
            if reduceMotion {
                circle
            } else {
                // 첫 점은 0.1초, 이후 0.13초씩 늦게 출발
                let delay = Timing.dotFirstDelay + Timing.dotStagger * Double(index)
                let tail = Timing.cycle - delay - Timing.burstInterval - Timing.dotBurst

                circle.keyframeAnimator(initialValue: DotMotion(), repeating: true) { content, motion in
                    content
                        .scaleEffect(x: motion.scaleX, y: motion.scaleY)
                        .offset(y: motion.offsetY)
                } keyframes: { _ in
                    KeyframeTrack(\.scaleX) {
                        LinearKeyframe(1, duration: delay)
                        Self.dotScaleBurst([1.25, 0.83, 1, 1.3, 0.93, 1.14])
                        LinearKeyframe(1, duration: Timing.burstInterval - Timing.dotBurst)
                        Self.dotScaleBurst([1.25, 0.83, 1, 1.3, 0.93, 1.14])
                        LinearKeyframe(1, duration: tail)
                    }
                    KeyframeTrack(\.scaleY) {
                        LinearKeyframe(1, duration: delay)
                        Self.dotScaleBurst([0.72, 1.22, 1, 0.68, 1.08, 0.86])
                        LinearKeyframe(1, duration: Timing.burstInterval - Timing.dotBurst)
                        Self.dotScaleBurst([0.72, 1.22, 1, 0.68, 1.08, 0.86])
                        LinearKeyframe(1, duration: tail)
                    }
                    KeyframeTrack(\.offsetY) {
                        LinearKeyframe(0, duration: delay)
                        Self.dotBounceBurst()
                        LinearKeyframe(0, duration: Timing.burstInterval - Timing.dotBurst)
                        Self.dotBounceBurst()
                        LinearKeyframe(0, duration: tail)
                    }
                }
            }
        }
        .offset(x: Metric.dotXs[index], y: Metric.dotY)
    }

    /// 점 찌그러짐(스케일) 한 번 분량 (총 1.14초). values는 6개 꼭짓점 값, 마지막은 스프링으로 1 복귀
    @KeyframeTrackContentBuilder<CGFloat>
    private static func dotScaleBurst(_ v: [CGFloat]) -> some KeyframeTrackContent<CGFloat> {
        LinearKeyframe(v[0], duration: 0.14, timingCurve: .easeIn)
        LinearKeyframe(v[1], duration: 0.16, timingCurve: .easeOut)
        LinearKeyframe(v[2], duration: 0.14, timingCurve: .easeInOut)
        LinearKeyframe(v[3], duration: 0.12, timingCurve: .easeIn)
        LinearKeyframe(v[4], duration: 0.16, timingCurve: .easeOut)
        LinearKeyframe(v[5], duration: 0.16, timingCurve: .easeIn)
        SpringKeyframe(1, duration: 0.26, spring: Timing.spring(for: 0.26))
    }

    /// 점 위아래 바운스 한 번 분량 (총 1.14초): 살짝 눌렸다가 12 → 5 → 1.6pt 높이로 튀어 오름
    @KeyframeTrackContentBuilder<CGFloat>
    private static func dotBounceBurst() -> some KeyframeTrackContent<CGFloat> {
        LinearKeyframe(2, duration: 0.14, timingCurve: .easeIn)
        LinearKeyframe(-12, duration: 0.21, timingCurve: .easeOut)
        LinearKeyframe(0, duration: 0.21, timingCurve: .easeIn)
        LinearKeyframe(-5, duration: 0.16, timingCurve: .easeOut)
        LinearKeyframe(0, duration: 0.16, timingCurve: .easeIn)
        LinearKeyframe(-1.6, duration: 0.13, timingCurve: .easeOut)
        LinearKeyframe(0, duration: 0.13, timingCurve: .easeIn)
    }
}

// MARK: - 상수 / 모션 값

private extension LoadingIconView {
    enum Metric {
        static let width: CGFloat = 103
        static let height: CGFloat = 47
        static let characterWidth: CGFloat = 55
        static let dotSize: CGFloat = 7
        static let dotXs: [CGFloat] = [58, 77, 96]
        static let dotY: CGFloat = 20
    }

    enum Timing {
        /// 전체 주기
        static let cycle: Double = 3.6
        /// 한 주기 안에서 두 번째 동작이 시작되는 간격
        static let burstInterval: Double = 1.6
        /// 캐릭터 동작 한 번 길이 (0.16 + 0.56)
        static let characterBurst: Double = 0.72
        /// 점 동작 한 번 길이
        static let dotBurst: Double = 1.14
        static let dotFirstDelay: Double = 0.1
        static let dotStagger: Double = 0.13

        /// 피그마 spring 커브(약 23% 오버슈트, 구간의 20% 지점에서 최고점)에 맞춘 스프링
        static func spring(for segment: Double) -> Spring {
            Spring(duration: segment * 0.36, bounce: 0.58)
        }
    }

    struct CharacterMotion {
        var rotation: CGFloat = 0
        var scaleX: CGFloat = 1
        var scaleY: CGFloat = 1
    }

    struct DotMotion {
        var scaleX: CGFloat = 1
        var scaleY: CGFloat = 1
        var offsetY: CGFloat = 0
    }
}

#Preview {
    VStack(spacing: 40) {
        LoadingView()
            .frame(height: 300)
            .background(Color.SandBeige)
        LoadingIconView(scale: 0.6)
    }
}
