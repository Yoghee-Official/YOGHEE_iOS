//
//  PullToRefresh.swift
//  DopiDopi
//
//  당겨서 새로고침 (로딩 아이콘은 LoadingIconView · Elastic 사용)
//  기본 .refreshable은 시스템 회전 아이콘만 쓸 수 있어서, 스크롤 위치를 직접 추적해 구현함.
//
//  사용법: 세로 ScrollView에 붙임
//      ScrollView { ... }
//          .pullToRefresh(isRefreshing: container.state.isRefreshing) {
//              container.handleIntent(.refresh)
//          }
//  - isRefreshing: 새로고침 요청이 진행 중인지 (컨테이너 상태). false가 되면 아이콘이 사라짐
//  - 새로고침 중에도 기존 목록은 그대로 두고, 맨 위에만 아이콘 영역(Metric.refreshingHeight)을 띄워 보여줌
//

import SwiftUI

extension View {
    /// 세로 ScrollView에 당겨서 새로고침을 붙인다.
    /// - Parameters:
    ///   - isRefreshing: 새로고침 요청이 진행 중인지. 당겨서 시작한 경우에만 아이콘을 띄우고, false가 되면 닫는다
    ///   - onRefresh: 충분히 당겼다가 손을 뗐을 때 호출
    func pullToRefresh(isRefreshing: Bool, onRefresh: @escaping () -> Void) -> some View {
        modifier(PullToRefreshModifier(isRefreshing: isRefreshing, onRefresh: onRefresh))
    }
}

private struct PullToRefreshModifier: ViewModifier {
    let isRefreshing: Bool
    let onRefresh: () -> Void

    /// 맨 위에서 아래로 당긴 거리 (0 = 정위치, 음수 = 아래로 스크롤됨)
    @State private var pull: CGFloat = 0
    @State private var isDragging = false
    /// 당겨서 새로고침을 시작했는지 (다른 이유로 isRefreshing이 true여도 아이콘은 띄우지 않음)
    @State private var isTriggered = false
    /// 응답이 너무 빨리 와도 아이콘이 깜빡이지 않도록 최소 노출 시간을 보장 (튕겨 돌아오는 시간 약 0.9초 + 여유)
    @State private var isMinimumTimeElapsed = true

    private var isShowingIndicator: Bool {
        isTriggered && (isRefreshing || !isMinimumTimeElapsed)
    }

    private var isArmed: Bool {
        pull >= Metric.threshold
    }

    func body(content: Content) -> some View {
        content
            // 새로고침 중에는 맨 위에 아이콘 영역만큼 여백을 둠 (중첩된 가로 스크롤에는 영향 없음)
            .safeAreaPadding(.top, isShowingIndicator ? Metric.refreshingHeight : 0)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                let distance = -(geometry.contentOffset.y + geometry.contentInsets.top)
                // 목록 깊이 스크롤했을 때는 값이 바뀌지 않도록 범위를 제한해 불필요한 갱신을 막음
                return min(max(distance, -Metric.refreshingHeight), Metric.maxTrackedPull)
            } action: { _, newValue in
                pull = newValue
            }
            .onScrollPhaseChange { oldPhase, newPhase in
                if newPhase == .interacting {
                    isDragging = true
                } else if oldPhase == .interacting {
                    isDragging = false
                    // 충분히 당긴 상태에서 손을 뗐을 때만 새로고침
                    if isArmed && !isTriggered {
                        startRefresh()
                    }
                }
            }
            .overlay(alignment: .top) {
                indicator
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .clipped()
                    .allowsHitTesting(false)
            }
            // 손을 떼면 새로고침되는 지점을 넘을 때 가벼운 진동
            .sensoryFeedback(.impact(weight: .light), trigger: isArmed) { wasArmed, armed in
                !wasArmed && armed && isDragging && !isTriggered
            }
            .animation(.spring(duration: 0.35), value: isShowingIndicator)
            .onChange(of: isShowingIndicator) { _, isShowing in
                if !isShowing { isTriggered = false }
            }
    }

    // MARK: 아이콘

    @ViewBuilder
    private var indicator: some View {
        let reserved = isShowingIndicator ? Metric.refreshingHeight : 0
        // 스크롤 영역 맨 위부터 콘텐츠 시작점까지의 빈 공간 높이
        let gap = pull + reserved

        if gap > 1 {
            let progress = isShowingIndicator ? 1 : min(max(pull / Metric.threshold, 0), 1)
            // 빈 공간이 아이콘 영역보다 작으면 콘텐츠 바로 위에 붙어 함께 내려오고, 크면 빈 공간 가운데에 위치
            let centerY = gap - max(Metric.refreshingHeight, gap) / 2

            // 크기는 91x41 고정, 당기는 정도에 따라 투명도만 변함
            LoadingIconView()
                .opacity(progress)
                .frame(height: Metric.refreshingHeight)
                .offset(y: centerY - Metric.refreshingHeight / 2)
        }
    }

    // MARK: 동작

    private func startRefresh() {
        isTriggered = true
        isMinimumTimeElapsed = false
        onRefresh()
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(Metric.minimumVisibleDuration))
            isMinimumTimeElapsed = true
        }
    }

    private enum Metric {
        /// 이만큼 당긴 뒤 손을 떼면 새로고침
        static let threshold: CGFloat = 64
        /// 새로고침 중 맨 위에 띄워두는 아이콘 영역 높이
        static let refreshingHeight: CGFloat = 56
        /// 이보다 더 당긴 거리는 추적하지 않음
        static let maxTrackedPull: CGFloat = 240
        /// 아이콘 최소 노출 시간 (초)
        static let minimumVisibleDuration: Double = 1.2
    }
}
