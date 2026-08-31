//
//  LoadingView.swift
//  DopiDopi
//
//  공통 로딩 인디케이터 (피그마 LD_MO_1 / LoadingIcon 컴포넌트 기준)
//  기존에 로딩 표시로 쓰던 ProgressView()를 대체하는 용도.
//  화면 중앙에 아이콘만 노출 (점 애니메이션 없음)
//
//  아이콘 에셋 안내:
//  Assets.xcassets에 "LoadingIcon" 이름으로 SVG(Single Icon)를 추가해주세요.
//  (피그마 LoadingIcon 컴포넌트의 라인 아트, 색상 Mind Orange #FF5520 기준 55x47 비율)

import SwiftUI

struct LoadingView: View {
    /// 아이콘 크기 (피그마 기준 55x47)
    private let iconWidth: CGFloat = 55
    private let iconHeight: CGFloat = 47

    var body: some View {
        Image("LoadingIcon")
            .resizable()
            .scaledToFit()
            .frame(width: iconWidth.ratio(), height: iconHeight.ratio())
            // 배경색은 칠하지 않고(화면마다 배경이 달라 caller가 이미 그리고 있음),
            // 주어진 공간을 꽉 채우면서 아이콘만 정중앙에 위치시킴
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
}
