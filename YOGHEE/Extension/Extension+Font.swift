//
//  Extension+Font.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/8/25.
//

import SwiftUI

extension Font {
    enum PretendardWeight {
        case regular
        case medium
        case semiBold
        case bold
        
        var name: String {
            switch self {
            case .regular: return "Pretendard-Regular"
            case .medium: return "Pretendard-Medium"
            case .semiBold: return "Pretendard-SemiBold"
            case .bold: return "Pretendard-Bold"
            }
        }
    }
    
    static func pretendard(_ weight: PretendardWeight = .regular, size: CGFloat) -> Font {
        return .custom(weight.name, size: size)
    }
}

extension View {
    func pretendardFont(_ weight: Font.PretendardWeight = .regular, size: CGFloat = 17) -> some View {
        font(Font.pretendard(weight, size: size))
    }
}
