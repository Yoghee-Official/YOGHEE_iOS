//
//  GlassUIBox.swift
//  YOGHEE
//
//  Created by 0ofKim on 1/24/26.
//

import SwiftUI

struct GlassUI: View {
    let text: String
    let width: CGFloat
    let height: CGFloat
    let opacity: Double
    
    init(text: String, width: CGFloat, height: CGFloat, opacity: Double) {
        self.text = text
        self.width = width
        self.height = height
        self.opacity = opacity
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(1.0), location: 0),
                            .init(color: Color.white.opacity(0), location: 0.5),
                            .init(color: Color.white.opacity(1.0), location: 1.0)
                        ]),
                        startPoint: UnitPoint(x: 0.35, y: 0),
                        endPoint: UnitPoint(x: 0.45, y: 1.0)
                    ),
                    lineWidth: 1.0
                )
            
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0), location: -0.1),
                            .init(color: Color.white.opacity(opacity*1.5), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(opacity), location: 0),
                            .init(color: Color.clear, location: 0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 4)

            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.clear, location: 0.9),
                            .init(color: Color.white.opacity(opacity), location: 1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 4)
            
            Text(text)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .tracking(-0.408)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(width: width, height: height)
    }
}

#Preview {
    VStack(spacing: 20) {
        GlassUI(text: "누적된 수련:0", width: 92, height: 32, opacity: 0.15)
        GlassUI(text: "예정된 수련:0", width: 92, height: 32, opacity: 0.15)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(hex: "#272727"))
}
