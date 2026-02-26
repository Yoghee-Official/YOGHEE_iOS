//
//  ClassRegisterContainer.swift
//  YOGHEE
//
//  Created by 0ofKim on 2/25/26.
//

import SwiftUI
import Foundation

// MARK: - Intent
enum ClassRegisterIntent {
    /// 운영 방식 선택 (oneDay, regular, season, workshop)
    case selectClassType(String)
}

// MARK: - State
struct ClassRegisterState: Equatable {
    /// 선택된 수련 타입 ID (oneDay, regular, season, workshop)
    var selectedClassTypeId: String?
}

// MARK: - Container
@MainActor
class ClassRegisterContainer: ObservableObject {
    @Published private(set) var state = ClassRegisterState()
    
    func handleIntent(_ intent: ClassRegisterIntent) {
        switch intent {
        case .selectClassType(let typeId):
            state.selectedClassTypeId = typeId
        }
    }
}
