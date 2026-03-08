//
//  Extension+String.swift
//  YOGHEE
//

import Foundation

extension String {
    /// 빈 문자열이면 nil, 아니면 self 반환 (옵셔널 바인딩/API 바디 등에 활용)
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
    
    /// trim 후 빈 문자열이면 nil, 아니면 trimmed 문자열 반환
    func trimmedNilIfEmpty() -> String? {
        let t = trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}
