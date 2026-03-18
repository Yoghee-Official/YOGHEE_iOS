//
//  ClassRegisterEnvironment.swift
//  YOGHEE
//
//  클래스 등록 완료 시 네비게이션 스택 비우기(마이페이지 첫 뎁스로) 콜백
//

import SwiftUI

private struct ClassRegisterPopToRootKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    /// 클래스 등록 완료 시 호출. 마이페이지 NavigationStack path를 비워 첫 뎁스로 돌아가게 함.
    var classRegisterPopToRoot: (() -> Void)? {
        get { self[ClassRegisterPopToRootKey.self] }
        set { self[ClassRegisterPopToRootKey.self] = newValue }
    }
}
