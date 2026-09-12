//
//  ClassRegisterPreviewView.swift
//  DopiDopi
//
//  클래스 등록 중 "결과보기" 버튼으로 여는 미리보기 모달 (피그마 preview_popup, node 6343-17867 기준).
//  실제 ClassDetailView와 같은 모듈(ClassInfoModuleView 등)을 재사용하되,
//  아직 서버에 등록되지 않은 데이터라 아래는 의도적으로 제외한다:
//  - 리뷰 모듈 (아직 리뷰가 있을 수 없음)
//  - 가격/예약 하단바 (아직 실제 예약이 불가능함)
//  - 지도자/수련원 소개 플립카드 (프로필 이미지·소개말 등 별도 데이터가 필요해 미리보기 범위 밖)
//

import SwiftUI
import UIKit

struct ClassRegisterPreviewView: View {
    let detail: YogaClassDetailDTO
    /// 아직 업로드/서버 반영 전이라 로컬 이미지 Data를 직접 사용 (URL 아님)
    let localImages: [Data]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                headerImageCarousel

                ClassInfoModuleView(
                    detail: detail,
                    onReviewTap: {},
                    onFeatureTap: { _ in }
                )

                InstructorClassModuleView(detail: detail, showsCard: false)

                FacilitiesModuleView(detail: detail)

                ScheduleModuleView(detail: detail, onScheduleTap: { _ in })

                LocationModuleView(detail: detail)

                Spacer(minLength: 40)
            }
        }
        .background(Color.SandBeige)
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topTrailing) {
            closeButton
        }
    }

    private var closeButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.DarkBlack)
                .padding(12)
                .background(Color.CleanWhite)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .padding(.top, 16)
        .padding(.trailing, 16)
    }

    @ViewBuilder
    private var headerImageCarousel: some View {
        if localImages.isEmpty {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 375)
                .overlay(
                    Text("등록된 이미지가 없습니다")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.gray)
                )
        } else {
            TabView {
                ForEach(Array(localImages.enumerated()), id: \.offset) { _, data in
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 375)
                            .clipped()
                    }
                }
            }
            .tabViewStyle(.page)
            .frame(height: 375)
        }
    }
}
