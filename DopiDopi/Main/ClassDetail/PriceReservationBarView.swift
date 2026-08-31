//
//  PriceReservationBarView.swift
//  YOGHEE
//

import SwiftUI

/// 9a~9d 가격/예약 고정 하단바
struct PriceReservationBarView: View {
    let detail: YogaClassDetailDTO
    let onInquiry: () -> Void
    let onReservation: () -> Void

    private var discountRate: Int? {
        guard let rate = detail.policy?.discountRate, rate > 0 else { return nil }
        return rate
    }

    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: detail.price)) ?? "\(detail.price)") + "원"
    }

    var body: some View {
        VStack(spacing: 0) {
            // 9a 할인율 뱃지 — green bar 위에 독립 노출, left: 16pt
            if let rate = discountRate {
                HStack(spacing: 0) {
                    discountBadge(rate: rate)
                        .padding(.leading, 16)
                    Spacer(minLength: 0)
                }
            }

            // 9b + 9c + 9d — 92pt NatureGreen 바
            HStack(spacing: 0) {
                // 9b 회당 금액
                HStack(spacing: 4) {
                    Text("1회 금액")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                        .lineLimit(1)
                    Text(formattedPrice)
                        .pretendardFont(.bold, size: 16)
                        .foregroundColor(.DarkBlack)
                        .lineLimit(1)
                }
                .fixedSize(horizontal: true, vertical: false)

                Spacer(minLength: 16)

                // 9c 문의하기 | divider | 9d 예약하기
                HStack(spacing: 28) {
                    Button(action: onInquiry) {
                        Text("문의하기")
                            .pretendardFont(.bold, size: 16)
                            .foregroundColor(.DarkBlack)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .buttonStyle(.plain)

                    Rectangle()
                        .fill(Color.DarkBlack)
                        .frame(width: 1, height: 19)

                    Button(action: onReservation) {
                        Text("예약하기")
                            .pretendardFont(.bold, size: 16)
                            .foregroundColor(.MindOrange)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .buttonStyle(.plain)
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, 24)
            .padding(.top, 25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .frame(height: 92-16)
            .background(Color.NatureGreen.ignoresSafeArea(edges: .bottom))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 9a 할인율 뱃지
    private func discountBadge(rate: Int) -> some View {
        HStack(spacing: 4) {
            Text("할인율")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.CleanWhite)
            Text("\(rate)%")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.CleanWhite)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.MindOrange)
        .clipShape(UnevenRoundedRectangle(
            topLeadingRadius: 4,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: 4
        ))
    }
}

#Preview {
    VStack {
        Spacer()
        PriceReservationBarView(
            detail: YogaClassDetailDTO(
                classId: "1",
                type: "R",
                name: "야외 요가",
                description: nil,
                price: 12000,
                images: [],
                thumbnail: nil,
                categories: [],
                features: [],
                favoriteCount: 0,
                isFavorite: false,
                reviewCount: 0,
                rating: 0,
                recentReviews: [],
                policy: PolicyInfo(
                    discountPrice: nil,
                    discountRate: 47,
                    reservationNote: nil,
                    refundPolicies: []
                ),
                schedules: [],
                tickets: [],
                center: nil
            ),
            onInquiry: { print("문의하기") },
            onReservation: { print("예약하기") }
        )
    }
    .ignoresSafeArea(edges: .bottom)
}
