//
//  ExploreFilterLayerView.swift
//  YOGHEE
//

import SwiftUI

// MARK: - 2a 필터 레이어 (상세 필터)
// - 닫기: 선택된 필터 전체 삭제 후 종료
// - 적용: 선택된 유효값 저장 후 필터링

struct ExploreFilterLayerView: View {
    let onClose: () -> Void
    let onApply: (ExploreSearchFilter) -> Void

    @State private var filter: ExploreSearchFilter

    /// 편의시설 9개 노출 (피그마 순서)
    private let facilityCodes = [
        "shower_room", "indoor_restroom", "outdoor_restroom",
        "powder_room", "personal_locker", "shoe_rack",
        "women_changing_room", "men_changing_room", "fitness_zone"
    ]

    init(filter: ExploreSearchFilter,
         onClose: @escaping () -> Void,
         onApply: @escaping (ExploreSearchFilter) -> Void) {
        _filter = State(initialValue: filter)
        self.onClose = onClose
        self.onApply = onApply
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    categorySection
                    ExploreFilterCalendarView(selectedDates: $filter.dates)
                        .padding(.top, 24)
                    timeSection
                        .padding(.top, 40)
                    facilitySection
                        .padding(.top, 40)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            applyButtonArea
        }
        .background(Color.white.ignoresSafeArea())
    }

    // MARK: - 헤더

    private var header: some View {
        VStack(spacing: 0) {
            HStack {
                Text("상세 필터")
                    .pretendardFont(.bold, size: 16)
                    .foregroundColor(.DarkBlack)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.DarkBlack)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.leading, 24)
            .padding(.trailing, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider().padding(.horizontal, 20)
        }
    }

    // MARK: - a: 카테고리 (전문 수련 유형 / 수련 태그 / 이용 대상)

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            chipGroup(title: "전문 수련 유형", items: YogaCodeHardcoded.types, selection: $filter.trainingTypeCodes)
            chipGroup(title: "수련 태그 선택", items: YogaCodeHardcoded.categories, selection: $filter.categoryCodes)
            chipGroup(title: "이용 대상", items: YogaCodeHardcoded.targets, selection: $filter.targetCodes)
        }
        .padding(.top, 16)
    }

    private func chipGroup(title: String, items: [CodeInfoDTO], selection: Binding<Set<String>>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .padding(.leading, 4)

            FlowLayout(spacing: 8) {
                ForEach(items) { item in
                    SelectionChipView(
                        title: item.name,
                        isSelected: selection.wrappedValue.contains(item.id)
                    ) {
                        toggle(item.id, in: selection)
                    }
                }
            }
        }
    }

    // MARK: - c: 시간

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("시간")

            ExploreTimeRangeSlider(
                startHour: $filter.startHour,
                endHour: $filter.endHour
            )
            .padding(.top, 22)
        }
    }

    // MARK: - d: 수련원 편의시설

    private var facilitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("수련원 편의시설")

            FlowLayout(spacing: 8) {
                ForEach(facilityItems) { item in
                    SelectionChipView(
                        title: item.name,
                        isSelected: filter.amenityCodes.contains(item.id)
                    ) {
                        toggle(item.id, in: $filter.amenityCodes)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }

    private var facilityItems: [CodeInfoDTO] {
        let byId = Dictionary(uniqueKeysWithValues: YogaCodeHardcoded.amenities.facility.map { ($0.id, $0) })
        return facilityCodes.compactMap { byId[$0] }
    }

    // MARK: - 적용 버튼

    private var applyButtonArea: some View {
        HStack {
            Spacer()
            Button {
                onApply(filter)
            } label: {
                Text("적용")
                    .pretendardFont(.medium, size: 14)
                    .foregroundColor(.DarkBlack)
                    .frame(width: 208, height: 48)
                    .background(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.929, blue: 0.451),
                                Color(red: 1.0, green: 0.945, blue: 0.600),
                                Color(red: 1.0, green: 0.965, blue: 0.745)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 104
                        )
                    )
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 20)
        .padding(.trailing, 16)
        .padding(.bottom, 20)
        .background(Color.white)
    }

    // MARK: - Helpers

    private func sectionTitle(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
                .padding(.leading, 12)
            Rectangle()
                .fill(Color.Background)
                .frame(height: 1)
        }
    }

    private func toggle(_ id: String, in selection: Binding<Set<String>>) {
        if selection.wrappedValue.contains(id) {
            selection.wrappedValue.remove(id)
        } else {
            selection.wrappedValue.insert(id)
        }
    }
}

// MARK: - b: 날짜 (월 달력, 다중 선택)
// - 오늘 기준 월 달력 노출, < > 버튼으로 이전/다음 달
// - 오늘보다 이른 날짜 비활성화, 오늘 기준 1년 이후(전날)까지 선택 가능

private struct ExploreFilterCalendarView: View {
    @Binding var selectedDates: Set<String>
    @State private var displayedMonth: Date = Date()

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2   // 월요일 시작
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }

    private let weekDays = ["월", "화", "수", "목", "금", "토", "일"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    private var today: Date { calendar.startOfDay(for: Date()) }

    /// 선택 가능한 마지막 날 (ex. 2025-11-13 → 2026-11-12)
    private var lastSelectableDate: Date {
        let oneYearLater = calendar.date(byAdding: .year, value: 1, to: today) ?? today
        return calendar.date(byAdding: .day, value: -1, to: oneYearLater) ?? oneYearLater
    }

    var body: some View {
        VStack(spacing: 0) {
            headerRow
            Rectangle()
                .fill(Color.Background)
                .frame(height: 1)
                .padding(.top, 12)

            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(monthDays.enumerated()), id: \.offset) { _, date in
                        dayCell(date)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 14)
        }
    }

    private var headerRow: some View {
        HStack {
            Text(String(calendar.component(.year, from: displayedMonth)))
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
                .padding(.leading, 4)

            Spacer()

            HStack(spacing: 30) {
                Button(action: { moveMonth(by: -1) }) {
                    Image(systemName: "arrowtriangle.left.fill")
                        .resizable()
                        .frame(width: 8, height: 8)
                        .foregroundColor(canMove(by: -1) ? .DarkBlack : .Info)
                }
                .disabled(!canMove(by: -1))

                Text("\(calendar.component(.month, from: displayedMonth))월")
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(.DarkBlack)
                    .frame(minWidth: 30)

                Button(action: { moveMonth(by: 1) }) {
                    Image(systemName: "arrowtriangle.right.fill")
                        .resizable()
                        .frame(width: 8, height: 8)
                        .foregroundColor(canMove(by: 1) ? .DarkBlack : .Info)
                }
                .disabled(!canMove(by: 1))
            }
            .padding(.trailing, 4)
        }
    }

    @ViewBuilder
    private func dayCell(_ date: Date?) -> some View {
        if let date {
            let dateString = Self.dateFormatter.string(from: date)
            let isSelectable = date >= today && date <= lastSelectableDate
            let isSelected = selectedDates.contains(dateString)

            Button {
                if isSelected {
                    selectedDates.remove(dateString)
                } else {
                    selectedDates.insert(dateString)
                }
            } label: {
                ZStack {
                    if isSelected {
                        EllipticalGradient(
                            stops: [
                                .init(color: .NatureGreen, location: 0.40),
                                .init(color: .NatureGreenLight, location: 1.00)
                            ],
                            center: .center
                        )
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                    }
                    Text("\(calendar.component(.day, from: date))")
                        .pretendardFont(isSelected ? .bold : .medium, size: 12)
                        .foregroundColor(isSelectable ? .DarkBlack : .Info)
                }
                .frame(height: 28)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .disabled(!isSelectable)
        } else {
            Color.clear.frame(height: 28)
        }
    }

    /// 표시 월의 날짜 목록 (월요일 시작 기준 앞쪽 빈칸은 nil)
    private var monthDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let dayRange = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in dayRange {
            days.append(calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start))
        }
        return days
    }

    private func canMove(by value: Int) -> Bool {
        guard let target = calendar.date(byAdding: .month, value: value, to: displayedMonth),
              let targetMonth = calendar.dateInterval(of: .month, for: target),
              let firstMonth = calendar.dateInterval(of: .month, for: today),
              let lastMonth = calendar.dateInterval(of: .month, for: lastSelectableDate) else { return false }
        return targetMonth.start >= firstMonth.start && targetMonth.start <= lastMonth.start
    }

    private func moveMonth(by value: Int) {
        guard canMove(by: value),
              let target = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = target
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// MARK: - c: 시간 레인지 슬라이더
// - 핸들 2개, 0시 ~ 24시 트랙 / 기본 9시 ~ 17시
// - 1시간 단위 조정, 최소 1시간 간격 유지, 정지한 핸들 위치의 값 표시

private struct ExploreTimeRangeSlider: View {
    @Binding var startHour: Int
    @Binding var endHour: Int

    private let maxHour = 24
    private let handleSize: CGFloat = 16
    private let tickHours = [0, 6, 12, 18, 24]

    /// 드래그 시작 시점의 값 — translation 누적 계산용
    @State private var dragStartValue: Int?

    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width - handleSize
            let startX = xPosition(for: startHour, trackWidth: trackWidth)
            let endX = xPosition(for: endHour, trackWidth: trackWidth)

            ZStack(alignment: .topLeading) {
                // 핸들 값 라벨
                handleLabel(startHour, centerX: startX)
                handleLabel(endHour, centerX: endX)

                // 트랙
                Capsule()
                    .fill(Color.Background)
                    .frame(width: trackWidth, height: 4)
                    .offset(x: handleSize / 2, y: 28)

                // 활성 구간
                Capsule()
                    .fill(Color.NatureGreen)
                    .frame(width: max(0, endX - startX), height: 4)
                    .offset(x: startX, y: 28)

                // 눈금
                ForEach(tickHours, id: \.self) { hour in
                    let x = xPosition(for: hour, trackWidth: trackWidth)
                    Rectangle()
                        .fill(Color.Background)
                        .frame(width: 1, height: 8)
                        .offset(x: x, y: 36)
                    Text(String(format: "%02d:00", hour))
                        .pretendardFont(.regular, size: 9)
                        .foregroundColor(.Info)
                        .fixedSize()
                        .frame(width: 40)
                        .offset(x: x - 20, y: 46)
                }

                handle(centerX: startX, trackWidth: trackWidth, isStart: true)
                handle(centerX: endX, trackWidth: trackWidth, isStart: false)
            }
        }
        .frame(height: 58)
    }

    private func xPosition(for hour: Int, trackWidth: CGFloat) -> CGFloat {
        handleSize / 2 + trackWidth * CGFloat(hour) / CGFloat(maxHour)
    }

    private func handleLabel(_ hour: Int, centerX: CGFloat) -> some View {
        Text(Self.displayTime(hour))
            .pretendardFont(.bold, size: 12)
            .foregroundColor(.DarkBlack)
            .fixedSize()
            .frame(width: 60)
            .offset(x: centerX - 30, y: 0)
    }

    private func handle(centerX: CGFloat, trackWidth: CGFloat, isStart: Bool) -> some View {
        Circle()
            .fill(Color.NatureGreen)
            .frame(width: handleSize, height: handleSize)
            .contentShape(Circle().inset(by: -12))   // 터치 영역 확장
            .offset(x: centerX - handleSize / 2, y: 22)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let base = dragStartValue ?? (isStart ? startHour : endHour)
                        if dragStartValue == nil { dragStartValue = base }
                        let delta = Int((value.translation.width / trackWidth * CGFloat(maxHour)).rounded())
                        if isStart {
                            startHour = min(max(0, base + delta), endHour - 1)
                        } else {
                            endHour = max(min(maxHour, base + delta), startHour + 1)
                        }
                    }
                    .onEnded { _ in
                        dragStartValue = nil
                    }
            )
    }

    /// 9 → "9:00 AM", 17 → "5:00 PM", 24 → "12:00 AM"
    static func displayTime(_ hour: Int) -> String {
        let normalized = hour % 24
        let period = normalized < 12 ? "AM" : "PM"
        let displayHour = normalized % 12 == 0 ? 12 : normalized % 12
        return "\(displayHour):00 \(period)"
    }
}

#Preview {
    ExploreFilterLayerView(filter: ExploreSearchFilter(), onClose: {}, onApply: { _ in })
}
