//
//  Extension+Color.swift
//  YOGHEE
//
//  Created by 0ofKim on 8/17/25.
//

import SwiftUI

extension Color {
    static let GheeYellow: Color = Color(red: 1, green: 0.93, blue: 0.45)
    static let NatureGreen: Color = Color(red: 0.84, green: 0.96, blue: 0.58)
    static let NatureGreenLight: Color = Color(red: 0.94, green: 1, blue: 0.83)
    static let MindOrange: Color = Color(red: 1, green: 0.33, blue: 0.13)
    static let LandBrown: Color = Color(red: 0.37, green: 0.28, blue: 0.21)
    static let FlowBlue: Color = Color(red: 0.79, green: 0.88, blue: 0.99)
    static let Notice: Color = Color(red: 0.94, green: 0.93, blue: 0.92)
    static let Info: Color = Color(red: 0.7, green: 0.7, blue: 0.7)
    static let CleanWhite: Color = .white
    static let DarkBlack: Color = .black
    static let SandBeige: Color = Color(red: 0.99, green: 0.98, blue: 0.96)
    static let Background: Color = Color(red: 0.94, green: 0.93, blue: 0.92)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
