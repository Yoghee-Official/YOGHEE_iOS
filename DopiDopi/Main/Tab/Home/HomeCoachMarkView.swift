//
//  HomeCoachMarkView.swift
//  YOGHEE
//

import SwiftUI

// MARK: - Preference Key
struct ToggleAnchorKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}

// MARK: - Coach Mark Overlay
struct HomeCoachMarkOverlay: View {
    let toggleFrame: CGRect
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            toggleBorder
            coachMarkContent
        }
    }

    private var toggleBorder: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.black, lineWidth: 1.5)
            .frame(width: toggleFrame.width + 12, height: toggleFrame.height + 12)
            .position(x: toggleFrame.midX, y: toggleFrame.midY)
            .allowsHitTesting(false)
    }

    private var coachMarkContent: some View {
        HStack(alignment: .center, spacing: 6) {
            // TODO: 에셋 전달받으면 Image("코치마크 화살표 에셋명")으로 교체
            Image(systemName: "arrow.down.left")
                .font(.system(size: 20))
                .foregroundColor(.black)

            VStack(alignment: .leading, spacing: 1) {
                Text("하루 수련과")
                    .pretendardFont(.regular, size: 13)
                Text("정규 수련을 볼 수 있어요!")
                    .pretendardFont(.regular, size: 13)
            }
            .foregroundColor(.black)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black)
                    .padding(6)
            }
        }
        .position(x: toggleFrame.maxX + 80, y: toggleFrame.midY)
    }
}
