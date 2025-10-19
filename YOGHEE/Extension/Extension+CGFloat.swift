//
//  Extension+CGFloat.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

extension CGFloat {
    private static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private static let baseWidth: CGFloat = 375.0
    
    /// 현재 디바이스의 화면 비율에 맞게 가로 값을 조정
    /// - Returns: 디바이스 비율에 맞게 조정된 값
    ///
    /// 사용 예시:
    /// ```swift
    /// .frame(width: 220.ratio()) // 375 기준 220pt를 현재 디바이스 비율로 변환
    /// .padding(.horizontal, 16.ratio())
    /// ```
    func ratio() -> CGFloat {
        return (self / Self.baseWidth) * Self.screenWidth
    }
    
    /// 특정 기준 너비를 기반으로 비율 계산
    /// - Parameter baseWidth: 기준이 되는 화면 너비 (기본값: 375)
    /// - Returns: 디바이스 비율에 맞게 조정된 값
    ///
    /// 사용 예시:
    /// ```swift
    /// .frame(width: 220.ratio(baseWidth: 390)) // 390 기준으로 비율 계산
    /// ```
    func ratio(baseWidth: CGFloat = 375.0) -> CGFloat {
        return (self / baseWidth) * Self.screenWidth
    }
}
