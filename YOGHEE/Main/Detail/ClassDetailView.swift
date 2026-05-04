//
//  ClassDetailView.swift
//  YOGHEE
//

import SwiftUI

struct ClassDetailView: View {
    let classId: String

    @StateObject private var container = ClassDetailContainer()
    @Environment(\.dismiss) private var dismiss

    @State private var scrollOffsetY: CGFloat = 0

    private let rainbowColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .indigo, .purple,
        .red, .orange, .yellow, .green, .blue, .indigo, .purple
    ]

    var body: some View {
        // ignoresSafeArea 없이 읽어야 geo.safeAreaInsets.top이 실제 값을 반환함
        GeometryReader { geo in
            let safeTop = geo.safeAreaInsets.top
            let screenWidth = geo.size.width
            // 배경 이미지 visual 높이 = screenWidth (safeArea 포함)
            let imageHeight = screenWidth
            // 카드는 이미지 visual 하단을 20pt 덮음 → safeArea 기준 offset
            let cardTopOffset = max(0, imageHeight - safeTop - 20)
            // 카드 상단이 헤더 하단(safeTop + 60)에 도달하는 스크롤 양
            let headerThreshold = max(0, cardTopOffset - 60)
            let showHeader = scrollOffsetY >= headerThreshold

            ZStack(alignment: .top) {
                // 0. 배경 fallback (이미지 기본색과 동일)
                Color.gray.opacity(0.2)
                    .ignoresSafeArea(edges: .all)

                // 1. 배경 이미지 — safeArea 까지 확장
                backgroundImageView
                    .frame(width: screenWidth, height: imageHeight)
                    .ignoresSafeArea(edges: .top)

                // 2. 스크롤 컨텐츠 (디테일 시트)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(width: screenWidth, height: cardTopOffset)

                        // 디테일 시트 — 이후 모듈별 개발 예정
                        VStack(spacing: 0) {
                            ForEach(Array(rainbowColors.enumerated()), id: \.offset) { _, color in
                                color.frame(height: 300)
                            }
                        }
                        .frame(width: screenWidth)
                        .frame(minHeight: geo.size.height)
                        .background(Color.white)
                        .clipShape(UnevenRoundedRectangle(
                            topLeadingRadius: 24,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 24
                        ))
                    }
                    .frame(width: screenWidth)
                }
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y
                } action: { _, newValue in
                    scrollOffsetY = newValue
                }

                // 3. 뒤로가기 헤더
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        Button { dismiss() } label: {
                            Image("BackArrow")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 23.ratio(), height: 20.ratio())
                        }
                        .padding(.top, showHeader ? 24 : 27)
                        .padding(.leading, showHeader ? 24 : 32)
                        .padding(.bottom, showHeader ? 16 : 0)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 60, alignment: .top)
                    .background(
                        (showHeader ? Color.SandBeige : Color.clear)
                            .ignoresSafeArea(edges: .top)
                            .animation(.easeInOut(duration: 0.15), value: showHeader)
                    )

                    Spacer()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            container.handleIntent(.load(classId: classId))
        }
    }

    // MARK: - Background Image
    private var backgroundImageView: some View {
        Group {
            if let urlString = container.state.detail?.images.first,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .clipped()
    }
}
