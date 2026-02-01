//
//  GlassUIBox.swift
//  YOGHEE
//
//  Created by 0ofKim on 1/24/26.
//

import SwiftUI

// MARK: - GlassUI Style Enum
enum GlassUIStyle {
    case mySmall
    case myBig
    case reservedClass
    
    var width: CGFloat {
        switch self {
        case .mySmall: return 92.ratio()
        case .myBig: return 156.ratio()
        case .reservedClass: return 36.ratio()
        }
    }
    
    var height: CGFloat {
        switch self {
        case .mySmall: return 32.ratio()
        case .myBig: return 130.ratio()
        case .reservedClass: return 54.ratio()
        }
    }
    
    var radius: CGFloat {
        switch self {
        case .mySmall: return 5
        case .myBig: return 5
        case .reservedClass: return 27
        }
    }
    
    var opacity: Double {
        switch self {
        case .mySmall: return 0.15
        case .myBig: return 0.15
        case .reservedClass: return 0.12
        }
    }
    
    var strokeBorderPoints: (start: UnitPoint, end: UnitPoint) {
        switch self {
        case .mySmall: return (UnitPoint(x: 0.35, y: 0), UnitPoint(x: 0.45, y: 1.0))
        case .myBig: return (UnitPoint(x: 0.4, y: 0), UnitPoint(x: 0.85, y: 0.7))
        case .reservedClass: return (UnitPoint(x: 0.1, y: 0.7), UnitPoint(x: 0.3, y: 0.8))
        }
    }
}

struct GlassUI: View {
    let width: CGFloat
    let height: CGFloat
    let radius: CGFloat
    let opacity: Double
    let strokeBorderPoints: (start: UnitPoint, end: UnitPoint)
    
    init(style: GlassUIStyle) {
        self.width = style.width
        self.height = style.height
        self.radius = style.radius
        self.opacity = style.opacity
        self.strokeBorderPoints = style.strokeBorderPoints
        
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .strokeBorder(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(1.0), location: 0),
                            .init(color: Color.white.opacity(0), location: 0.5),
                            .init(color: Color.white.opacity(1.0), location: 1.0)
                        ]),
                        startPoint: strokeBorderPoints.start,
                        endPoint: strokeBorderPoints.end
                    ),
                    lineWidth: 1.0
                )
            
            RoundedRectangle(cornerRadius: radius)
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
            
            RoundedRectangle(cornerRadius: radius)
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

            RoundedRectangle(cornerRadius: radius)
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
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Static Factory Methods
extension GlassUI {
    static func mySmall() -> GlassUI {
        GlassUI(style: .mySmall)
    }
    
    static func myBig() -> GlassUI {
        GlassUI(style: .myBig)
    }
    
    static func reservedClass() -> GlassUI {
        GlassUI(style: .reservedClass)
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack {
            GlassUI.mySmall()
            GlassUI.mySmall()
        }
        
        Spacer().frame(height: 20)
        
        HStack {
            GlassUI.myBig()
            GlassUI.myBig()
        }
        
        Spacer().frame(height: 20)
        
        HStack {
            GlassUI.reservedClass()
            GlassUI.reservedClass()
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.init(hex: "#272727"))
}
