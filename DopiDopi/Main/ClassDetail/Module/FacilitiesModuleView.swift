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
            sectionDivider

            facilitiesSection(
                title: "수련원 보유 물품",
                items: Array(FacilitiesDummy.amenities.prefix(21))
            )

            if !displayAmenities.isEmpty {
                sectionDivider

                facilitiesSection(
                    title: "편의시설",
                    items: displayAmenities
                )
            }
        }
        .padding(.horizontal, 16)
    }

    private var displayAmenities: [String] {
        Array((detail.center?.amenities ?? []).prefix(10))
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

// MARK: - 더미 데이터 (5a 수련원 보유 물품, 서버 필드 확정 후 교체)

private enum FacilitiesDummy {
    static let amenities: [String] = [
        "Wifi 🚧", "소독액 🚧", "물티슈 🚧",
        "싱잉볼 🚧", "블럭 🚧", "볼스터 🚧",
        "매트 🚧", "폼롤러 🚧", "담요 🚧",
        "타올 🚧", "스트랩 🚧"
    ]
}
