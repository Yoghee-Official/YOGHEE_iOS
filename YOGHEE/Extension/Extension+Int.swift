//
//  Extension+Int.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI

extension Int {
    /// Int 값을 CGFloat로 변환 후 디바이스 비율에 맞게 조정
    /// - Returns: 디바이스 비율에 맞게 조정된 값
    ///
    /// 사용 예시:
    /// ```swift
    /// .frame(width: 220.ratio()) // Int 220을 비율 계산
    /// ```
    func ratio() -> CGFloat {
        return CGFloat(self).ratio()
    }
    
    /// 특정 기준 너비를 기반으로 비율 계산
    /// - Parameter baseWidth: 기준이 되는 화면 너비 (기본값: 375)
    /// - Returns: 디바이스 비율에 맞게 조정된 값
    func ratio(baseWidth: CGFloat = 375.0) -> CGFloat {
        return CGFloat(self).ratio(baseWidth: baseWidth)
    }
}

//extension Double {
//    /// Double 값을 CGFloat로 변환 후 디바이스 비율에 맞게 조정
//    /// - Returns: 디바이스 비율에 맞게 조정된 값
//    ///
//    /// 사용 예시:
//    /// ```swift
//    /// .frame(width: 220.5.ratio()) // Double 220.5를 비율 계산
//    /// ```
//    func ratio() -> CGFloat {
//        return CGFloat(self).ratio()
//    }
//
//    /// 특정 기준 너비를 기반으로 비율 계산
//    /// - Parameter baseWidth: 기준이 되는 화면 너비 (기본값: 375)
//    /// - Returns: 디바이스 비율에 맞게 조정된 값
//    func ratio(baseWidth: CGFloat = 375.0) -> CGFloat {
//        return CGFloat(self).ratio(baseWidth: baseWidth)
//    }
//}
