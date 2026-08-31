//
//  ClassInfoModuleView.swift
//  YOGHEE
//

import SwiftUI

/// 수련명 / 평점·리뷰수 / 요가원 주소 / 추천 텍스트 모듈
struct ClassInfoModuleView: View {
    let detail: YogaClassDetailDTO
    let onReviewTap: () -> Void
    let onFeatureTap: (FeatureInfo) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 3a 수련명 + 3b 평점/리뷰수
            HStack(alignment: .top, spacing: 12) {
                // 3a 수련명: 최대 2줄, 줄당 10글자, 초과 시 ...
                Text(displayName)
                    .pretendardFont(.bold, size: 20)
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // 3b 평점 + 리뷰수
                Button(action: onReviewTap) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("★ \(formattedRating)")
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .overlay(
                                Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        Text("리뷰수 \(formattedReviewCount)개")
                            .pretendardFont(.regular, size: 11)
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)

            // 3c 주소: 도로명 우선, 없으면 전체주소
            if let address = displayAddress {
                Text(address)
                    .pretendardFont(.regular, size: 12)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
            }

            // 3d 추천 텍스트: 가로 스크롤, 좌우 인셋 24, 아이템 간격 8
            if !detail.features.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(detail.features, id: \.featureId) { feature in
                            FeatureTagView(feature: feature) {
                                onFeatureTap(feature)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }

    // MARK: - Computed Properties

    /// 수련명 표시: 최대 2줄, 줄당 10글자
    private var displayName: String {
        let chunked = detail.name.chunked(by: 10).prefix(2)
        return chunked.joined(separator: "\n")
    }

    /// 평점: 소수점 1자리
    private var formattedRating: String {
        String(format: "%.1f", detail.rating)
    }

    /// 리뷰수: 99,999 초과 시 "99,999+"
    private var formattedReviewCount: String {
        if detail.reviewCount > 99_999 {
            return "99,999+"
        }
        return detail.reviewCount.formatted(.number.locale(Locale(identifier: "ko_KR")))
    }

    /// 주소: roadAddress 우선, 없으면 fullAddress
    private var displayAddress: String? {
        if let road = detail.center?.roadAddress, !road.isEmpty {
            return road
        }
        if let full = detail.center?.fullAddress, !full.isEmpty {
            return full
        }
        return nil
    }
}

// MARK: - Feature Tag

private struct FeatureTagView: View {
    let feature: FeatureInfo
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image("CheckCircleIconFull")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                Text(feature.description)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.black)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.SandBeige)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - String Helper

private extension String {
    /// 지정된 길이만큼 문자열을 분할 (수련명 줄당 10글자 제한용)
    func chunked(by length: Int) -> [String] {
        guard length > 0 else { return [self] }
        var result: [String] = []
        var current = ""
        for char in self {
            current.append(char)
            if current.count == length {
                result.append(current)
                current = ""
            }
        }
        if !current.isEmpty { result.append(current) }
        return result
    }
}
