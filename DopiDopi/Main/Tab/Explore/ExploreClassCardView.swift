//
//  ExploreClassCardView.swift
//  YOGHEE
//

import SwiftUI

// MARK: - 4a 요가 수업 유닛 (핀 선택 시 하단 노출)

struct ExploreClassCardView: View {
    let item: ClassMapMarkerDTO
    let classType: ExploreClassType
    /// 시·구·동 — 상세 API 응답 전에는 nil
    let address: String?
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail
            infoSection
            favoriteButton
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .debugViewName(kind: .item)
    }

    // MARK: - 썸네일

    private var thumbnail: some View {
        Group {
            if let urlString = item.thumbnail, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Color.Background
                    }
                }
            } else {
                Color.Background
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - 타입 / 타이틀 / 주소 / 별점

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            typeChip

            // 타이틀 1줄
            Text(item.name)
                .pretendardFont(.bold, size: 14)
                .foregroundColor(.DarkBlack)
                .lineLimit(1)

            // 주소 1줄 (시, 구, 동)
            Text(address ?? " ")
                .pretendardFont(.regular, size: 12)
                .foregroundColor(.Info)
                .lineLimit(1)

            ratingRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var typeChip: some View {
        Text(classType.label)
            .pretendardFont(.medium, size: 11)
            .foregroundColor(.DarkBlack)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(classType == .regular ? Color.FlowBlue : Color.NatureGreen)
            .cornerRadius(4)
    }

    private var ratingRow: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
                .foregroundColor(.GheeYellow)
            Text(String(format: "%.1f", item.avgRating ?? 0))
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
            Text("(\(item.reviewCount ?? 0))")
                .pretendardFont(.regular, size: 12)
                .foregroundColor(.Info)
        }
    }

    // MARK: - 찜 버튼

    private var favoriteButton: some View {
        Button(action: onFavoriteToggle) {
            Image(item.isFavorite == true ? "SaveIconBig" : "SaveIconEmptyBig")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 24)
        }
    }
}

#Preview {
    ExploreClassCardView(
        item: ClassMapMarkerDTO(
            classId: "1", name: "주말 아침 힐링 요가", thumbnail: nil,
            avgRating: 4.5, reviewCount: 12, isFavorite: false,
            latitude: 37.5651, longitude: 126.9812
        ),
        classType: .oneDay,
        address: "서울 중구 태평로1가",
        onTap: {},
        onFavoriteToggle: {}
    )
    .padding()
}
