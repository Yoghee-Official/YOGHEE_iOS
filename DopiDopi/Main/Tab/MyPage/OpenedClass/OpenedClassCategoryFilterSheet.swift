//
//  OpenedClassCategoryFilterSheet.swift
//  YOGHEE
//
//  개설한 수련 목록(OC_MO_1) 2a 카테고리 필터 팝업 (OC_MO_1_filter, Figma 3-13814)
//  - 적용: 선택한 카테고리로 리로드
//  - 시트를 내려 닫으면 변경 사항 반영 안 함
//

import SwiftUI

struct OpenedClassCategoryFilterSheet: View {
    let onApply: (Set<String>) -> Void

    @State private var selectedCodes: Set<String>

    init(selectedCodes: Set<String>, onApply: @escaping (Set<String>) -> Void) {
        _selectedCodes = State(initialValue: selectedCodes)
        self.onApply = onApply
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    chipGroup(title: "전문 수련 유형", items: YogaCodeHardcoded.types)
                    chipGroup(title: "수련 태그 선택", items: YogaCodeHardcoded.categories)
                    chipGroup(title: "이용 대상", items: YogaCodeHardcoded.targets)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }

            applyButtonArea
        }
        .background(Color.CleanWhite)
        .presentationDetents([.fraction(0.65), .large])
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("카테고리 필터")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
                .padding(.horizontal, 12)
            Rectangle()
                .fill(Color.Background)
                .frame(height: 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 32)
    }

    private func chipGroup(title: String, items: [CodeInfoDTO]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .padding(.horizontal, 16)

            FlowLayout(spacing: 8) {
                ForEach(items) { item in
                    SelectionChipView(title: item.name, isSelected: selectedCodes.contains(item.id)) {
                        if selectedCodes.contains(item.id) {
                            selectedCodes.remove(item.id)
                        } else {
                            selectedCodes.insert(item.id)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }

    // MARK: - 적용 버튼 (탐색 상세 필터와 동일한 스타일)
    private var applyButtonArea: some View {
        HStack {
            Spacer()
            Button {
                onApply(selectedCodes)
            } label: {
                Text("적용")
                    .pretendardFont(.medium, size: 14)
                    .foregroundColor(.DarkBlack)
                    .frame(width: 208, height: 48)
                    .background(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.929, blue: 0.451),
                                Color(red: 1.0, green: 0.945, blue: 0.600),
                                Color(red: 1.0, green: 0.965, blue: 0.745)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 104
                        )
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.CleanWhite)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.Background)
                .frame(height: 1)
        }
    }
}
