//
//  ExploreClassCardView.swift
//  YOGHEE
//

import SwiftUI

// MARK: - 4a 요가 수업 유닛 캐러셀 (핀 선택 시 하단 노출)

/// 동일 위치 수련을 최근 등록순으로 좌우 스와이프 — 1개일 경우 스와이프 없음, 끝이 있는 스와이프
struct ExploreClassCardCarousel: View {
    let items: [ClassMapMarkerDTO]
    let classType: ExploreClassType
    /// classId별 시·구·동 — 상세 API 응답 전에는 없음
    let addresses: [String: String]
    let onTap: (String) -> Void
    let onFavoriteToggle: (String) -> Void

    private let cardHeight: CGFloat = 114
    private let spacing: CGFloat = 12
    /// 다음 카드 노출 폭 — 피그마 360 기준 (좌 12 + 카드 319 + 간격 12 + 다음 카드 17)
    private let peekWidth: CGFloat = 17

    private var isSwipeable: Bool { items.count > 1 }

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width - spacing * 2 - (isSwipeable ? peekWidth : 0)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: spacing) {
                    ForEach(items, id: \.classId) { item in
                        ExploreClassCardView(
                            item: item,
                            classType: classType,
                            address: addresses[item.classId],
                            onTap: { onTap(item.classId) },
                            onFavoriteToggle: { onFavoriteToggle(item.classId) }
                        )
                        .frame(width: cardWidth)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, spacing, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollDisabled(!isSwipeable)
        }
        .frame(height: cardHeight)
    }
}

// MARK: - 4a 요가 수업 유닛 (AdBanner(SHORT))

struct ExploreClassCardView: View {
    let item: ClassMapMarkerDTO
    let classType: ExploreClassType
    /// 시·구·동 — 상세 API 응답 전에는 nil
    let address: String?
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
                infoSection
                Spacer(minLength: 0)
                favoriteButton
            }
            Spacer(minLength: 0)
            typeChip
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(thumbnail)
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .contentShape(RoundedRectangle(cornerRadius: 7))
        .onTapGesture(perform: onTap)
        .debugViewName(kind: .item)
    }

    // MARK: - 배경 썸네일

    private var thumbnail: some View {
        ZStack {
            Color.LandBrown
            if let urlString = item.thumbnail, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                    }
                }
            }
        }
    }

    // MARK: - 타이틀 / 주소 / 별점

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 타이틀 1줄
            Text(item.name)
                .pretendardFont(.bold, size: 14)
                .foregroundColor(.white)
                .lineLimit(1)

            // 주소 1줄 (시, 구, 동) + 별점·리뷰
            HStack(spacing: 4) {
                if let address {
                    Text(address)
                }
                Text("★ \(String(format: "%.1f", item.avgRating ?? 0)) (\(item.reviewCount ?? 0))")
            }
            .pretendardFont(.regular, size: 10)
            .foregroundColor(.white)
            .lineLimit(1)
        }
    }

    // MARK: - 정규/하루 구분값

    private var typeChip: some View {
        Text(classType.label)
            .pretendardFont(.regular, size: 10)
            .foregroundColor(.DarkBlack)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(classType == .regular ? Color.FlowBlue : Color.NatureGreen)
            .clipShape(Capsule())
    }

    // MARK: - 찜 버튼

    private var favoriteButton: some View {
        Button(action: onFavoriteToggle) {
            Image(item.isFavorite == true ? "SaveIconSmall" : "SaveIconEmptySmall")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 14)
                .opacity(0.8)
                .shadow(color: .black.opacity(0.05), radius: 5)
                // 아이콘 크기는 유지하고 터치 영역만 확장
                .padding(10)
                .contentShape(Rectangle())
                .padding(-10)
        }
    }
}

#Preview {
    let items = [
        ClassMapMarkerDTO(
            classId: "1", name: "아메리카요가앤필라테스", thumbnail: nil,
            avgRating: 4.6, reviewCount: 194, isFavorite: false,
            latitude: 37.5651, longitude: 126.9812
        ),
        ClassMapMarkerDTO(
            classId: "2", name: "빈야사와 한정선 요가", thumbnail: nil,
            avgRating: 4.5, reviewCount: 12, isFavorite: true,
            latitude: 37.5651, longitude: 126.9812
        )
    ]
    ExploreClassCardCarousel(
        items: items,
        classType: .regular,
        addresses: ["1": "서울 용산구 한남동"],
        onTap: { _ in },
        onFavoriteToggle: { _ in }
    )
}
