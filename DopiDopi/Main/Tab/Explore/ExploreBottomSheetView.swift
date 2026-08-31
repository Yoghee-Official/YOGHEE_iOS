//
//  ExploreBottomSheetView.swift
//  YOGHEE
//

import SwiftUI

// MARK: - 필터 옵션

enum ExploreFilter: CaseIterable, Identifiable {
    case filter
    case yogheeClubOnly
    case popular
    case distance
    case highRating
    case femaleOnly

    var id: Self { self }

    var title: String {
        switch self {
        case .filter:         return "필터 ▼"
        case .yogheeClubOnly: return "요기클럽 전용"
        case .popular:        return "인기순"
        case .distance:       return "거리순"
        case .highRating:     return "3.5점 이상"
        case .femaleOnly:     return "여성전용"
        }
    }
}

// MARK: - 바텀시트

struct ExploreBottomSheetView: View {
    let classes: [ClassMapSearchDTO]
    /// 키보드 표시 여부 — true이면 시트를 화면 밖으로 완전히 숨김
    let isKeyboardVisible: Bool

    private let expandedHeight:  CGFloat = 665
    private let collapsedOffset: CGFloat = 565  // expandedHeight - collapsedHeight(100)

    /// 정착된 offset — 제스처가 끝날 때만 업데이트 (0 = 완전 열림, 565 = 접힘, 665 = 완전 숨김)
    @State private var currentOffset: CGFloat = 565

    /// 실시간 드래그 델타 — @State로 관리해야 onEnded에서 원자적으로 리셋 가능
    /// (@GestureState는 onEnded 호출 전에 이미 0으로 리셋되어 점프 발생)
    @State private var dragOffset: CGFloat = 0

    @State private var selectedFilters: Set<ExploreFilter> = []

    /// 화면에 적용되는 실제 offset: 정착 위치 + 실시간 델타 + 경계 고무줄
    private var displayOffset: CGFloat {
        let raw = currentOffset + dragOffset
        if raw < 0 {
            return raw * 0.12                   // 상단 초과 시 저항
        } else if raw > expandedHeight {
            return expandedHeight + (raw - expandedHeight) * 0.12  // 완전 숨김 초과 시 저항
        }
        return raw
    }

    /// 확장 진행률 (0 = 완전 접힘, 1 = 완전 열림) — 페이드 및 히트 테스트에 활용
    private var expandProgress: CGFloat {
        let progress = 1.0 - (displayOffset / collapsedOffset)
        return max(0, min(1, progress))
    }

    /// currentOffset 기준 확장 여부 (스냅 방향 결정용)
    private var isExpanded: Bool {
        currentOffset < collapsedOffset / 2
    }

    var body: some View {
        VStack(spacing: 0) {
            // 드래그 영역: 핸들 + 필터 칩만 제스처 수신 (ScrollView와 충돌 방지)
            VStack(spacing: 0) {
                dragHandle
                filterChipsRow
            }
            .contentShape(Rectangle())
            .gesture(dragGesture)

            // 클래스 목록: 확장 진행률에 따라 부드럽게 페이드인
            classListView
                .opacity(expandProgress)
                .allowsHitTesting(expandProgress > 0.5)
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .frame(height: expandedHeight, alignment: .top)
        .background(Color.white)
        .clipShape(TopRoundedShape(radius: 16))
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: -4)
        .offset(y: displayOffset)
        .onChange(of: isKeyboardVisible) { _, visible in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.80)) {
                // 키보드 표시 → 시트 완전히 숨김 / 키보드 닫힘 → 접힌 상태로 복귀
                currentOffset = visible ? expandedHeight : collapsedOffset
            }
        }
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.Info)
            .frame(width: 80, height: 4)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
            .padding(.bottom, 14)
    }

    // MARK: - 필터 칩 Row

    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ExploreFilter.allCases) { filter in
                    ExploreFilterChip(
                        title: filter.title,
                        isSelected: selectedFilters.contains(filter)
                    ) {
                        if selectedFilters.contains(filter) {
                            selectedFilters.remove(filter)
                        } else {
                            selectedFilters.insert(filter)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - 클래스 목록

    private var classListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(classes, id: \.classId) { item in
                    ExploreClassCard(item: item)
                    Divider()
                        .padding(.horizontal, 16)
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - 드래그 제스처

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                // 스냅 방향: 제스처 시작 위치(currentOffset) 기준으로 예측
                let predictedEnd = currentOffset + value.predictedEndTranslation.height
                let shouldExpand = predictedEnd < collapsedOffset / 2

                // currentOffset과 dragOffset을 같은 렌더 사이클에서 원자적으로 업데이트
                // → displayOffset = (currentOffset_new + 0) = (currentOffset_old + dragOffset_current)
                // → 시각적으로 변화 없이 손 뗀 위치에서 바로 애니메이션 시작
                currentOffset = max(0, min(collapsedOffset, displayOffset))
                dragOffset = 0

                UIImpactFeedbackGenerator(style: .light).impactOccurred()

                withAnimation(.spring(response: 0.35, dampingFraction: 0.78, blendDuration: 0)) {
                    currentOffset = shouldExpand ? 0 : collapsedOffset
                }
            }
    }
}

// MARK: - 필터 칩

struct ExploreFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(isSelected ? Color.MindOrange : Color.DarkBlack)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.MindOrange : Color.Background, lineWidth: 1)
                )
        }
    }
}

// MARK: - 클래스 카드

struct ExploreClassCard: View {
    let item: ClassMapSearchDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            thumbnailRow
            classNameRow
            ratingRow
            priceRow
            typeAndScheduleRow
        }
        .padding(16)
    }

    // MARK: - 썸네일 3장

    @ViewBuilder
    private var thumbnailRow: some View {
        let urls: [String] = [item.classThumbnail, item.thumbnail].compactMap { $0 }
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                let urlString: String? = index < urls.count ? urls[index] : nil
                Group {
                    if let str = urlString, let url = URL(string: str) {
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
                .frame(maxWidth: .infinity)
                .frame(height: 86)
                .clipped()
                .cornerRadius(8)
            }
        }
    }

    // MARK: - 클래스명 + 찜 아이콘

    private var classNameRow: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(item.className)
                .pretendardFont(.bold, size: 14)
                .foregroundColor(Color.DarkBlack)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: item.isFavorite == true ? "heart.fill" : "heart")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(item.isFavorite == true ? Color.MindOrange : Color.Info)
        }
    }

    // MARK: - 원장명 + 평점

    private var ratingRow: some View {
        HStack(spacing: 0) {
            Text("T. \(item.centerName)")
                .pretendardFont(.regular, size: 12)
                .foregroundColor(Color.Info)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let rating = item.avgRating {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .foregroundColor(Color.GheeYellow)
                    Text(String(format: "%.1f", rating))
                        .pretendardFont(.regular, size: 12)
                        .foregroundColor(Color.DarkBlack)
                    if let count = item.reviewCount {
                        Text(" (\(count))")
                            .pretendardFont(.regular, size: 12)
                            .foregroundColor(Color.Info)
                    }
                }
            }
        }
    }

    // MARK: - 가격

    @ViewBuilder
    private var priceRow: some View {
        if let price = item.price {
            Text("\(formattedPrice(price))원")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(Color.DarkBlack)
        }
    }

    // MARK: - 타입 칩 + 시간 슬롯 칩

    private var typeAndScheduleRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                typeChip
                ForEach(scheduleLabels, id: \.self) { label in
                    Text(label)
                        .pretendardFont(.regular, size: 11)
                        .foregroundColor(Color.DarkBlack)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.Background)
                        .cornerRadius(4)
                }
            }
        }
    }

    private var typeChip: some View {
        let isRegular = item.type == "R"
        return Text(isRegular ? "정규수련" : "하루수련")
            .pretendardFont(.medium, size: 11)
            .foregroundColor(Color.DarkBlack)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isRegular ? Color.FlowBlue : Color.NatureGreen)
            .cornerRadius(4)
    }

    private var scheduleLabels: [String] {
        guard let schedules = item.schedules else { return [] }
        return schedules.prefix(3).compactMap { schedule in
            guard let start = schedule.startTime, let end = schedule.endTime else { return nil }
            if let dow = schedule.dayOfWeek {
                return "\(dowString(dow)) \(start)~\(end)"
            } else if let date = schedule.date {
                return "\(String(date.suffix(5))) \(start)~\(end)"
            }
            return "\(start)~\(end)"
        }
    }

    private func dowString(_ dow: Int) -> String {
        guard dow >= 1, dow <= 7 else { return "" }
        return ["월", "화", "수", "목", "금", "토", "일"][dow - 1]
    }

    private func formattedPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
}

// MARK: - 상단 모서리만 둥근 Shape

private struct TopRoundedShape: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addArc(
            center: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: 0))
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: radius),
            radius: radius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
