//
//  FacilitiesModuleView.swift
//  YOGHEE
//

import SwiftUI

/// 5a 수련원 보유 물품 / 5b 편의시설 모듈
struct FacilitiesModuleView: View {
    let detail: YogaClassDetailDTO

    var body: some View {
        VStack(spacing: 32) {
            if !displayAmenityItems.isEmpty {
                sectionDivider

                facilitiesSection(
                    title: "수련원 보유 물품",
                    items: displayAmenityItems
                )
            }

            if !displayFacilityItems.isEmpty {
                sectionDivider

                facilitiesSection(
                    title: "편의시설",
                    items: displayFacilityItems
                )
            }
        }
        .padding(.horizontal, 16)
    }

    /// 요가원의 amenities 코드 목록을 "제공물품"/"편의시설" 코드북(YogaCodeHardcoded.amenities) 기준으로 분리해 한글명으로 변환.
    /// 코드북에 없는 값은 표시라도 되도록 원문 그대로 편의시설 쪽에 노출한다.
    private var displayAmenityItems: [String] {
        let codes = detail.center?.amenities ?? []
        let amenityIds = Set(YogaCodeHardcoded.amenities.amenity.map(\.id))
        let nameById = Dictionary(uniqueKeysWithValues: YogaCodeHardcoded.amenities.amenity.map { ($0.id, $0.name) })
        return codes.filter { amenityIds.contains($0) }.compactMap { nameById[$0] }
    }

    private var displayFacilityItems: [String] {
        let codes = detail.center?.amenities ?? []
        let amenityIds = Set(YogaCodeHardcoded.amenities.amenity.map(\.id))
        let facilityIds = Set(YogaCodeHardcoded.amenities.facility.map(\.id))
        let nameById = Dictionary(uniqueKeysWithValues: YogaCodeHardcoded.amenities.facility.map { ($0.id, $0.name) })
        return codes.compactMap { code in
            if let name = nameById[code] { return name }
            // 코드북 어디에도 없는 값은 편의시설 쪽에 원문 그대로 노출 (물품 코드북에 있는 값은 위에서 이미 처리했으니 제외)
            if !amenityIds.contains(code) && !facilityIds.contains(code) { return code }
            return nil
        }
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 1)
    }

    private func facilitiesSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .pretendardFont(.bold, size: 14)
                .foregroundColor(.DarkBlack)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.DarkBlack, lineWidth: 1)
                )

            FacilitiesGridView(items: items)
                .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 3열 그리드 (bullet + 텍스트)

private struct FacilitiesGridView: View {
    let items: [String]

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 6, alignment: .leading),
        GridItem(.flexible(), spacing: 6, alignment: .leading),
        GridItem(.flexible(), spacing: 6, alignment: .leading)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 11) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .center, spacing: 6) {
                    Circle()
                        .fill(Color.DarkBlack)
                        .frame(width: 3, height: 3)
                    Text(item)
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                        .lineLimit(1)
                }
            }
        }
    }
}
