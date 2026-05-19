//
//  ReviewModuleView.swift
//  YOGHEE
//

import SwiftUI

/// 8a~8d 리뷰 모듈
struct ReviewModuleView: View {
    let detail: YogaClassDetailDTO
    let onShowAll: () -> Void
    let onItemTap: (String) -> Void

    private var reviews: [YogaReviewDTO] { detail.recentReviews }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 8a~8d 메인 콘텐츠
            VStack(alignment: .leading, spacing: 16) {
                sectionDivider

                // 8a 평점 pill(좌) + 8b 리뷰 개수(우)
                HStack(alignment: .center) {
                    reviewPillLabel
                    Spacer()
                    if !reviews.isEmpty {
                        Text(reviewCountText)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                            .underline()
                    }
                }

                // 8c 리뷰 유닛 (가로 스크롤)
                if reviews.isEmpty {
                    emptyView
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(reviews, id: \.reviewId) { review in
                                ReviewItemCard(
                                    review: review,
                                    onTap: { onItemTap(review.reviewId) }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, -16)
                }

                // 8d 전체보기
                showAllButton
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
    }

    // MARK: - 8a 헤더 pill: "리뷰 ★4.0"

    private var reviewPillLabel: some View {
        let label: Text = Text("리뷰 ").font(Font.pretendard(.bold, size: 14))
            + Text("★").font(Font.pretendard(.regular, size: 14))
            + Text(String(format: "%.1f", detail.rating)).font(Font.pretendard(.bold, size: 14))
        return label
            .foregroundColor(.DarkBlack)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.DarkBlack, lineWidth: 1)
            )
    }

    // MARK: - 8b 리뷰 개수

    private var reviewCountText: String {
        if detail.reviewCount > 99_999 { return "99,999+" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: detail.reviewCount)) ?? "\(detail.reviewCount)") + "개"
    }

    // MARK: - 리뷰 없음

    private var emptyView: some View {
        Text("등록된 리뷰가 없습니다.")
            .pretendardFont(.medium, size: 12)
            .foregroundColor(.Info)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 40)
    }

    // MARK: - 8d 리뷰 전체보기 버튼

    private var showAllButton: some View {
        Button(action: onShowAll) {
            Text("리뷰 전체보기")
                .pretendardFont(.bold, size: 12)
                .foregroundColor(.DarkBlack)
                .padding(10)
                .background(reviews.isEmpty ? Color.gray.opacity(0.2) : Color.GheeYellow)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(reviews.isEmpty)
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private var sectionDivider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 1)
    }
}

// MARK: - 리뷰 카드 (8c)

struct ReviewItemCard: View {
    let review: YogaReviewDTO
    let onTap: () -> Void
    var contentLineLimit: Int = 4

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // 대표 이미지
                reviewThumbnail
                    .frame(height: 134)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                // 컨텐츠 영역
                VStack(alignment: .leading, spacing: 12) {
                    profileRow

                    VStack(alignment: .leading, spacing: 8) {
                        dateAndStarsRow
                        contentRow
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 27)
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            .frame(width: 255, height: 323, alignment: .top)
            .background(Color.CleanWhite)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 대표 이미지

    private var reviewThumbnail: some View {
        Group {
            if let urlStr = review.thumbnail, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        thumbnailPlaceholder
                    }
                }
            } else {
                thumbnailPlaceholder
            }
        }
    }

    private var thumbnailPlaceholder: some View {
        Rectangle().fill(Color.gray.opacity(0.15))
    }

    // MARK: - 프로필 행

    private var profileRow: some View {
        HStack(alignment: .center, spacing: 8) {
            profileImage
            VStack(alignment: .leading, spacing: 4) {
                Text(review.nickname ?? "")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                    .lineLimit(1)
                Text("Lv.\(review.userLevel ?? 0)")
                    .pretendardFont(.regular, size: 10)
                    .foregroundColor(.DarkBlack)
            }
        }
    }

    private var profileImage: some View {
        Group {
            if let urlStr = review.profileUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        profilePlaceholder
                    }
                }
            } else {
                profilePlaceholder
            }
        }
        .frame(width: 33, height: 33)
        .clipShape(Circle())
    }

    private var profilePlaceholder: some View {
        Circle().fill(Color.gray.opacity(0.2))
    }

    // MARK: - 날짜 + 별점 행

    private var dateAndStarsRow: some View {
        HStack {
            Text(formattedDate)
                .pretendardFont(.medium, size: 10)
                .foregroundColor(.Info)
            Spacer()
            StarRatingView(rating: review.rating ?? 0)
        }
    }

    // MARK: - 리뷰 내용 + 더보기 텍스트

    private var contentRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(review.content ?? "")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .lineLimit(contentLineLimit)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let content = review.content, !content.isEmpty {
                Text("더보기")
                    .pretendardFont(.medium, size: 10)
                    .foregroundColor(.DarkBlack)
                    .underline()
            }
        }
    }

    // MARK: - 날짜 포맷

    private var formattedDate: String {
        guard let raw = review.createdAt else { return "" }
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd'T'HH:mm:ssZ", "yyyy-MM-dd"] {
            input.dateFormat = fmt
            if let date = input.date(from: raw) {
                let output = DateFormatter()
                output.locale = Locale(identifier: "ko_KR")
                output.dateFormat = "yyyy년 M월 d일"
                return output.string(from: date)
            }
        }
        return raw
    }
}

// MARK: - Preview

#Preview {
    ReviewModuleView(
        detail: YogaClassDetailDTO(
            classId: "1",
            type: "R",
            name: "자연에서 즐기는 야외 요가",
            description: nil,
            price: 50000,
            images: [],
            thumbnail: nil,
            categories: [],
            features: [],
            favoriteCount: 0,
            isFavorite: false,
            reviewCount: 12333,
            rating: 4.0,
            recentReviews: [
                YogaReviewDTO(
                    reviewId: "1",
                    userUuid: "uuid-1",
                    nickname: "yoghee.love",
                    userLevel: 12,
                    profileUrl: nil,
                    thumbnail: nil,
                    content: "처음 야외에서 요가 수련 경험했는데, 잊지못할 경험이었습니다. 선생님이 전해주신 따스한 배려와 꼼꼼한 수업 잊지 못할 것 같습니다~ 다음 수업도 참여할게영",
                    rating: 5.0,
                    createdAt: "2025-10-24T00:00:00Z"
                ),
                YogaReviewDTO(
                    reviewId: "2",
                    userUuid: "uuid-2",
                    nickname: "yoga.user",
                    userLevel: 5,
                    profileUrl: nil,
                    thumbnail: nil,
                    content: "좋은 수업이었습니다.",
                    rating: 4.0,
                    createdAt: "2025-11-01T00:00:00Z"
                )
            ],
            policy: nil,
            schedules: [],
            tickets: [],
            center: nil
        ),
        onShowAll: { print("전체보기 탭") },
        onItemTap: { reviewId in print("리뷰 탭 - \(reviewId)") }
    )
}
