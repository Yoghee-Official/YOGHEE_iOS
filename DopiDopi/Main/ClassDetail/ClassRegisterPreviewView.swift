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
    /// [정규 전용] 정규수련은 달마다 다른 시간표(monthlySchedules)로 등록되므로,
    /// 등록 화면(2b)과 동일하게 이번 달~+6개월 각 달의 스케줄을 미리 담아 여기서 달을 넘겨가며 볼 수 있게 한다.
    /// 비어있으면(하루수련) 달 선택 UI 없이 `detail.schedules`를 그대로 보여준다.
    var scheduleMonths: [(month: Date, schedules: [ScheduleInfo])] = []
    /// 처음 열었을 때 보여줄 달의 키("yyyy-MM"). scheduleMonths가 비어있지 않을 때만 의미가 있음
    var initialMonthKey: String? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var selectedMonthKey: String = ""

    private var hasMonthSelector: Bool { !scheduleMonths.isEmpty }

    private var selectedMonthEntry: (month: Date, schedules: [ScheduleInfo])? {
        scheduleMonths.first { PracticeMonthOption.keyFormatter.string(from: $0.month) == selectedMonthKey }
    }

    /// 지금 선택된 달의 스케줄로 교체한 detail (달 선택 UI가 없으면 원본 그대로)
    private var effectiveDetail: YogaClassDetailDTO {
        guard let entry = selectedMonthEntry else { return detail }
        return detail.withSchedules(entry.schedules)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                headerImageCarousel

                ClassInfoModuleView(
                    detail: effectiveDetail,
                    onReviewTap: {},
                    onFeatureTap: { _ in }
                )

                InstructorClassModuleView(detail: effectiveDetail, showsCard: false)

                FacilitiesModuleView(detail: effectiveDetail)

                ScheduleModuleView(
                    detail: effectiveDetail,
                    onScheduleTap: { _ in },
                    monthOptions: hasMonthSelector ? scheduleMonths.map(\.month) : nil,
                    selectedMonth: selectedMonthEntry?.month,
                    onMonthChange: hasMonthSelector ? { newMonth in
                        selectedMonthKey = PracticeMonthOption.keyFormatter.string(from: newMonth)
                    } : nil
                )

                LocationModuleView(detail: effectiveDetail)

                Spacer(minLength: 40)
            }
        }
        .background(Color.SandBeige)
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topTrailing) {
            closeButton
        }
        .onAppear {
            guard selectedMonthKey.isEmpty else { return }
            selectedMonthKey = initialMonthKey ?? scheduleMonths.first.map {
                PracticeMonthOption.keyFormatter.string(from: $0.month)
            } ?? ""
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

private extension YogaClassDetailDTO {
    /// schedules만 다른 값으로 바꾼 복사본 (달 선택에 따라 스케줄만 교체해서 다시 보여주기 위함)
    func withSchedules(_ schedules: [ScheduleInfo]) -> YogaClassDetailDTO {
        YogaClassDetailDTO(
            classId: classId, type: type, name: name, description: description,
            price: price, images: images, thumbnail: thumbnail,
            categories: categories, features: features,
            favoriteCount: favoriteCount, isFavorite: isFavorite,
            reviewCount: reviewCount, rating: rating,
            recentReviews: recentReviews, policy: policy,
            schedules: schedules, tickets: tickets, center: center,
            trainingTypes: trainingTypes, trainingTargets: trainingTargets,
            masterInfo: masterInfo
        )
    }
}
