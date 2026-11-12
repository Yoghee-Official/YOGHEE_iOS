//
//  PolicyType.swift
//  YOGHEE
//
//  약관 문서 종류 및 웹 URL (TM_MO_1 메뉴 / TU_MO_1 ~ TU_MO_4)
//

import Foundation

enum PolicyType: String, CaseIterable, Hashable, Identifiable {
    /// 서비스 이용약관 (TU_MO_1)
    case service
    /// 개인정보 처리방침 (TU_MO_2)
    case privacy
    /// 위치정보 이용약관 (TU_MO_3)
    case location
    /// 마케팅 활용 동의서 (TU_MO_4)
    case marketing

    var id: String { rawValue }

    /// 웹뷰 상단 타이틀
    var title: String {
        switch self {
        case .service: return "서비스 이용약관"
        case .privacy: return "개인정보 처리방침"
        case .location: return "위치정보 이용약관"
        case .marketing: return "마케팅 활용 동의서"
        }
    }

    /// TM_MO_1 메뉴에 노출되는 이름 (피그마 문구 그대로)
    var menuTitle: String {
        switch self {
        case .service: return "서비스 이용약관 (Service Terms)"
        case .privacy: return "개인정보 처리방침 (Privacy Policy)"
        case .location: return "위치정보 이용약관 (Location Terms)"
        case .marketing: return "마케팅 활용 동의서 (Marketing Agreement)"
        }
    }

    var url: URL {
        URL(string: "\(Self.baseURL)/\(rawValue)")!
    }

    private static let baseURL = "https://www.dopidopi.xyz/policies"
}
