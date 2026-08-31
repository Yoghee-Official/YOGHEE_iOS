//
//  ReviewListView.swift
//  YOGHEE
//

import SwiftUI

struct ReviewListView: View {
    let classId: String
    let initialRating: Double
    let initialReviewCount: Int

    @StateObject private var container: ReviewListContainer
    @Environment(\.dismiss) private var dismiss

    init(classId: String, initialRating: Double, initialReviewCount: Int) {
        self.classId = classId
        self.initialRating = initialRating
        self.initialReviewCount = initialReviewCount
        _container = StateObject(wrappedValue: ReviewListContainer(classId: classId))
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ratingHeader
                    dividerLine
                    sortChips
                    reviewList
                }
            }
        }
        .background(Color.SandBeige.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .task {
            container.handleIntent(.load)
        }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        ZStack {
            Color.SandBeige
            HStack {
                Button { dismiss() } label: {
                    Image("BackArrow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 23.ratio(), height: 20.ratio())
                }
                Spacer()
            }
            .padding(.horizontal, 24)

            Text("리뷰 목록")
                .pretendardFont(.bold, size: 20)
                .foregroundColor(.DarkBlack)
        }
        .frame(height: 60)
    }

    // MARK: - Rating Header

    private var ratingHeader: some View {
        ZStack {
            HStack(alignment: .top, spacing: 0) {
                Image("StarDrawingIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 106.ratio(), height: 98.ratio())
                    .padding(.leading, 28.ratio())
                    .padding(.top, 14)
                Spacer()
                Image("SunFaceIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 124.ratio(), height: 145.ratio())
                    .padding(.trailing, 12.ratio())
            }

            VStack(spacing: 8) {
                Text(String(format: "%.1f", initialRating))
                    .pretendardFont(.bold, size: 36)
                    .foregroundColor(.DarkBlack)

                Text("총 리뷰 수 \(reviewCountFormatted)건")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
    }

    private var reviewCountFormatted: String {
        let count = container.state.totalCount > 0 ? container.state.totalCount : initialReviewCount
        if count > 99_999 { return "99,999+" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: count)) ?? "\(count)"
    }
    
    // MARK: - Divider

    private var dividerLine: some View {
        Rectangle()
            .fill(Color.Background)
            .frame(height: 1)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
    }

    // MARK: - Sort Chips

    private var sortChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ReviewSortOption.allCases, id: \.rawValue) { option in
                    sortChip(option)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }

    private func sortChip(_ option: ReviewSortOption) -> some View {
        let isSelected = container.state.sort == option
        return Button {
            container.handleIntent(.changeSort(option))
        } label: {
            Text(option.title)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? Color(red: 214/255, green: 246/255, blue: 149/255)
                        : Color.Background
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Review List

    private var reviewList: some View {
        Group {
            if container.state.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
            } else if container.state.reviews.isEmpty {
                Text("등록된 리뷰가 없습니다.")
                    .pretendardFont(.medium, size: 14)
                    .foregroundColor(.Info)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(container.state.reviews, id: \.reviewId) { review in
                        ReviewListItemView(review: review)
                    }

                    if container.state.hasNext {
                        if container.state.isLoadingMore {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        } else {
                            Color.clear
                                .frame(height: 1)
                                .onAppear {
                                    container.handleIntent(.loadNextPage)
                                }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Review List Item

private struct ReviewListItemView: View {
    let review: YogaReviewDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 이미지가 있을 경우 상단에 표시
            // TODO: thumbnail이 현재 String으로 내려오고 있으나, 서버 수정 후 [String]으로 변경 예정
            if let urlStr = review.thumbnail, !urlStr.isEmpty {
                reviewImage(urlStr)
            }

            // 프로필 + 날짜/별점 + 리뷰 텍스트
            VStack(alignment: .leading, spacing: 12) {
                profileRow
                dateAndStarsRow
                if let content = review.content, !content.isEmpty {
                    Text(content)
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 16)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Background, lineWidth: 1)
        )
    }

    // MARK: - Review Image

    private func reviewImage(_ urlStr: String) -> some View {
        Group {
            if let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        Rectangle().fill(Color.Background)
                    }
                }
            } else {
                Rectangle().fill(Color.Background)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 233)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    // MARK: - Profile Row

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
                        Circle().fill(Color.Background)
                    }
                }
            } else {
                Circle().fill(Color.Background)
            }
        }
        .frame(width: 33, height: 33)
        .clipShape(Circle())
    }

    // MARK: - Date + Stars Row

    private var dateAndStarsRow: some View {
        HStack {
            Text(formattedDate)
                .pretendardFont(.medium, size: 10)
                .foregroundColor(.Info)
            Spacer()
            StarRatingView(rating: review.rating ?? 0)
        }
    }

    // MARK: - Date Format

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
