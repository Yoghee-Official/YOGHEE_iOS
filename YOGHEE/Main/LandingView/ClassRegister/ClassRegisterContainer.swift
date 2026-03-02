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
    
    // Step 1: 수련 설명
    /// 수련 설명 업데이트 (제목, 설명)
    case updateExplanation(name: String, description: String)
    /// 특징(수련 장점) 토글 선택 (최대 3개)
    case toggleFeature(String)
    
    // Step 2: 유형 선택
    /// 전문 수련 유형 토글 (최대 13개)
    case toggleType(String)
    /// 수련 카테고리 토글 (최대 9개)
    case toggleCategory(String)
    /// 이용 대상 토글 (최대 7개)
    case toggleTarget(String)
}

// MARK: - State
struct ClassRegisterState: Equatable {
    /// 선택된 수련 타입 ID (oneDay, regular, season, workshop)
    var selectedClassTypeId: String?
    
    // Step 1: 수련 설명
    /// 클래스 이름 (API: name, 최대 22자)
    var name: String = ""
    /// 클래스 설명 (API: description, 최대 3000자)
    var description: String = ""
    /// 선택된 특징 ID (API: featureIds, 최대 3개)
    var featureIds: Set<String> = []
    
    /// 코드 목록 (features 등)
    var features: [CodeInfoDTO] = []
    var isLoadingCodeList: Bool = false
    var codeListError: String?
    
    // Step 2: 유형 선택
    /// 전문 수련 유형 목록 (CodeListDto > categories > type)
    var types: [CodeInfoDTO] = []
    /// 수련 카테고리 목록 (CodeListDto > categories > category)
    var categories: [CodeInfoDTO] = []
    /// 이용 대상 목록 (CodeListDto > categories > target)
    var targets: [CodeInfoDTO] = []
    /// 선택된 전문 수련 유형 ID (최대 13개)
    var typeIds: Set<String> = []
    /// 선택된 수련 카테고리 ID (최대 9개)
    var categoryIds: Set<String> = []
    /// 선택된 이용 대상 ID (최대 7개)
    var targetIds: Set<String> = []
}

// MARK: - Container
@MainActor
class ClassRegisterContainer: ObservableObject {
    @Published private(set) var state = ClassRegisterState()
    
    func handleIntent(_ intent: ClassRegisterIntent) {
        switch intent {
        case .selectClassType(let typeId):
            state.selectedClassTypeId = typeId
            
        case .updateExplanation(let name, let description):
            state.name = String(name.prefix(22))
            state.description = String(description.prefix(3000))
            
        case .toggleFeature(let featureId):
            if state.featureIds.contains(featureId) {
                state.featureIds.remove(featureId)
            } else if state.featureIds.count < 3 {
                state.featureIds.insert(featureId)
            }
            
        case .toggleType(let typeId):
            if state.typeIds.contains(typeId) {
                state.typeIds.remove(typeId)
            } else if state.typeIds.count < 13 {
                state.typeIds.insert(typeId)
            }
            
        case .toggleCategory(let categoryId):
            if state.categoryIds.contains(categoryId) {
                state.categoryIds.remove(categoryId)
            } else if state.categoryIds.count < 9 {
                state.categoryIds.insert(categoryId)
            }
            
        case .toggleTarget(let targetId):
            if state.targetIds.contains(targetId) {
                state.targetIds.remove(targetId)
            } else if state.targetIds.count < 7 {
                state.targetIds.insert(targetId)
            }
        }
    }
    
    /// 코드 목록 로드 (features)
    func loadCodeList() {
        state.isLoadingCodeList = true
        state.codeListError = nil
        
        Task {
            do {
                let response = try await APIService.shared.getCodeList()
                await MainActor.run {
                    self.state.features = response.data.features
                    self.state.types = response.data.categories.type
                    self.state.categories = response.data.categories.category
                    self.state.targets = response.data.categories.target
                    self.state.isLoadingCodeList = false
                }
            } catch {
                await MainActor.run {
                    self.state.codeListError = error.localizedDescription
                    self.state.isLoadingCodeList = false
                }
            }
        }
    }
}
