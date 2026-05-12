//
//  ScheduleModuleView.swift
//  YOGHEE
//

import SwiftUI

/// 6a 수련 시간표 캘린더(하루수련) / 시간표 그리드(정규수련) + 6b 수업 유닛
struct ScheduleModuleView: View {
    let detail: YogaClassDetailDTO
    let onScheduleTap: (String) -> Void

    @State private var selectedDate: String = Self.todayString()

    private var reservedDates: Set<String> {
        Set(detail.schedules.compactMap { Self.dayString(from: $0.specificDate) })
    }

    private var filteredSchedules: [ScheduleInfo] {
        detail.schedules.filter { Self.dayString(from: $0.specificDate) == selectedDate }
    }

    var body: some View {
        if detail.type == "R" {
            RegularScheduleSectionView(schedules: detail.schedules, className: detail.name)
        } else {
            VStack(alignment: .leading, spacing: 16) {
                scheduleHeaderLabel

                VStack(spacing: 8) {
                    CalendarView(
                        reservedDates: reservedDates,
                        selectedDate: $selectedDate,
                        userRole: .yogini
                    )

                    VStack(spacing: 8) {
                        ForEach(filteredSchedules, id: \.scheduleId) { schedule in
                            ScheduleItemView(
                                schedule: schedule,
                                className: detail.name,
                                onTap: { onScheduleTap(schedule.scheduleId) }
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                        }
                    }
                    .animation(.easeOut(duration: 0.4), value: filteredSchedules.map { $0.scheduleId })
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var scheduleHeaderLabel: some View {
        Text("수련 시간표")
            .pretendardFont(.bold, size: 14)
            .foregroundColor(.DarkBlack)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.DarkBlack, lineWidth: 1)
            )
    }

    private static func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    fileprivate static func dayString(from raw: String?) -> String? {
        guard let raw, raw.count >= 10 else { return nil }
        return String(raw.prefix(10))
    }
}

// MARK: - 6a 정규수련 시간표

private struct RegularScheduleSectionView: View {
    let schedules: [ScheduleInfo]
    let className: String

    private let hourHeight: CGFloat = 70
    private let dayLabels = ["월", "화", "수", "목", "금", "토", "일"]

    @State private var displayYear: Int
    @State private var displayMonth: Int
    @State private var isExpanded: Bool = false

    init(schedules: [ScheduleInfo], className: String) {
        self.schedules = schedules
        self.className = className
        let cal = Calendar.current
        let now = Date()
        _displayYear = State(initialValue: cal.component(.year, from: now))
        _displayMonth = State(initialValue: cal.component(.month, from: now))
    }

    private var weeklySchedules: [ScheduleInfo] {
        schedules.filter { $0.dayOfWeek != nil }
    }

    private var minHour: Int {
        weeklySchedules
            .compactMap { decimalHour(from: $0.startTime).map { Int($0) } }
            .min() ?? 9
    }

    private var maxEndHour: Int {
        weeklySchedules
            .compactMap { decimalHour(from: $0.endTime).map { Int(ceil($0)) } }
            .max() ?? 18
    }

    private var hourCount: Int { max(0, maxEndHour - minHour) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            scheduleLabel
            monthNavigationRow

            if weeklySchedules.isEmpty {
                emptyView
            } else if hourCount >= 4 && !isExpanded {
                expandButton
            } else {
                dayOfWeekHeader
                timetableGrid
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Header views

    private var scheduleLabel: some View {
        Text("수련 시간표")
            .pretendardFont(.bold, size: 14)
            .foregroundColor(.DarkBlack)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.DarkBlack, lineWidth: 1)
            )
    }

    private var monthNavigationRow: some View {
        HStack(spacing: 0) {
            Text(String(displayYear))
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)

            Spacer()

            Button { goBack() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(canGoBack ? Color.DarkBlack : Color.gray.opacity(0.3))
            }
            .buttonStyle(.plain)
            .disabled(!canGoBack)

            Text("\(displayMonth)월")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
                .frame(minWidth: 44, alignment: .center)

            Button { goForward() } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(canGoForward ? Color.DarkBlack : Color.gray.opacity(0.3))
            }
            .buttonStyle(.plain)
            .disabled(!canGoForward)
        }
    }

    private var dayOfWeekHeader: some View {
        HStack(spacing: 0) {
            ForEach(Array(dayLabels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
        }
        .background(Color.gray.opacity(0.08))
    }

    // MARK: - Timetable grid

    private var timetableGrid: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(1...7, id: \.self) { day in
                ZStack(alignment: .topLeading) {
                    // 시간 슬롯 배경 (1시간 단위 격자)
                    VStack(spacing: 0) {
                        ForEach(0..<hourCount, id: \.self) { _ in
                            Color.clear
                                .frame(height: hourHeight)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.15))
                                        .frame(height: 0.5),
                                    alignment: .bottom
                                )
                        }
                    }

                    // 수업 셀 (VStack 상단 spacer로 Y 위치 결정)
                    ForEach(schedulesForDay(day), id: \.scheduleId) { schedule in
                        let topOffset = yOffset(for: schedule)
                        let cellH = cellHeight(for: schedule)
                        VStack(spacing: 0) {
                            Color.clear.frame(height: topOffset)
                            TimetableCell(
                                schedule: schedule,
                                className: className,
                                day: day
                            )
                            .frame(height: cellH)
                            Spacer(minLength: 0)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: CGFloat(hourCount) * hourHeight)
                .clipped()
            }
        }
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 0.5),
            alignment: .top
        )
    }

    // MARK: - Expand / Empty

    private var expandButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { isExpanded = true }
        } label: {
            VStack(spacing: 8) {
                Text("클릭해서 전체 시간표 확인하기")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                Image(systemName: "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(.DarkBlack)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 48)
        }
        .buttonStyle(.plain)
    }

    private var emptyView: some View {
        Text("등록된 시간표가 없습니다.")
            .pretendardFont(.medium, size: 12)
            .foregroundColor(.Info)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 40)
    }

    // MARK: - Helpers

    private func schedulesForDay(_ day: Int) -> [ScheduleInfo] {
        weeklySchedules.filter { $0.dayOfWeek == day }
    }

    private func decimalHour(from timeString: String?) -> Double? {
        guard let time = timeString else { return nil }
        let parts = time.split(separator: ":")
        guard !parts.isEmpty, let hour = Double(String(parts[0])) else { return nil }
        let minute = parts.count >= 2 ? Double(String(parts[1])) ?? 0.0 : 0.0
        return hour + minute / 60.0
    }

    private func yOffset(for schedule: ScheduleInfo) -> CGFloat {
        guard let start = decimalHour(from: schedule.startTime) else { return 0 }
        return max(0, CGFloat(start - Double(minHour)) * hourHeight)
    }

    private func cellHeight(for schedule: ScheduleInfo) -> CGFloat {
        guard let start = decimalHour(from: schedule.startTime),
              let end = decimalHour(from: schedule.endTime),
              end > start else { return hourHeight }
        return CGFloat(end - start) * hourHeight
    }

    // MARK: - Month navigation

    private var canGoBack: Bool {
        let cal = Calendar.current
        let now = Date()
        let y = cal.component(.year, from: now)
        let m = cal.component(.month, from: now)
        return displayYear > y || (displayYear == y && displayMonth > m)
    }

    private var canGoForward: Bool {
        let cal = Calendar.current
        guard let maxDate = cal.date(byAdding: .month, value: 12, to: Date()) else { return false }
        let maxY = cal.component(.year, from: maxDate)
        let maxM = cal.component(.month, from: maxDate)
        return displayYear < maxY || (displayYear == maxY && displayMonth < maxM)
    }

    private func goBack() {
        guard canGoBack else { return }
        if displayMonth == 1 { displayMonth = 12; displayYear -= 1 }
        else { displayMonth -= 1 }
    }

    private func goForward() {
        guard canGoForward else { return }
        if displayMonth == 12 { displayMonth = 1; displayYear += 1 }
        else { displayMonth += 1 }
    }
}

// MARK: - 시간표 셀

private struct TimetableCell: View {
    let schedule: ScheduleInfo
    let className: String
    let day: Int

    private var bgColor: Color {
        // 월(1) 수(3) 금(5) 일(7) → #CAE1FD / 화(2) 목(4) 토(6) → #D6F695
        switch day {
        case 1, 3, 5, 7: return Color(red: 202/255, green: 225/255, blue: 253/255)
        default:          return Color(red: 214/255, green: 246/255, blue: 149/255)
        }
    }

    private var displayClassName: String {
        if let c = schedule.content, !c.isEmpty { return c }
        return className
    }

    private func hhMM(_ t: String?) -> String {
        guard let t else { return "" }
        let p = t.split(separator: ":")
        guard p.count >= 2 else { return t }
        return "\(p[0]):\(p[1])"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(hhMM(schedule.startTime))
                .pretendardFont(.regular, size: 8)
                .foregroundColor(.DarkBlack)
                .lineLimit(1)
            Text("~\(hhMM(schedule.endTime))")
                .pretendardFont(.regular, size: 8)
                .foregroundColor(.DarkBlack)
                .lineLimit(1)
            Text(displayClassName)
                .pretendardFont(.bold, size: 9)
                .foregroundColor(.DarkBlack)
                .lineLimit(2)
                .truncationMode(.tail)
            // TODO: 서버 필드 추가 후 schedule.instructorName으로 교체
            Text("김의영 지도자")
                .pretendardFont(.regular, size: 8)
                .foregroundColor(.DarkBlack)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding(.horizontal, 1)
    }
}

// MARK: - 6b 수업 유닛 (하루수련 전용)

private struct ScheduleItemView: View {
    let schedule: ScheduleInfo
    let className: String
    let onTap: () -> Void

    private var dayNumber: String {
        guard let date = ScheduleModuleView.dayString(from: schedule.specificDate) else { return "" }
        let parts = date.split(separator: "-")
        guard parts.count >= 3, let day = Int(parts[2]) else { return "" }
        return String(format: "%02d", day)
    }

    private var dayOfWeekString: String {
        guard let dateString = ScheduleModuleView.dayString(from: schedule.specificDate) else { return "" }
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        guard let date = parser.date(from: dateString) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }

    private var timeRangeString: String {
        guard let start = schedule.startTime, let end = schedule.endTime else { return "" }
        return "\(formatTime(start)) ~ \(formatTime(end))"
    }

    private func formatTime(_ time: String) -> String {
        let parts = time.split(separator: ":")
        guard let hourStr = parts.first, let hour = Int(hourStr) else { return time }
        let minuteStr = parts.count >= 2 ? String(parts[1]) : "00"
        let period = hour < 12 ? "오전" : "오후"
        let displayHour: Int = {
            if hour == 0 { return 12 }
            if hour > 12 { return hour - 12 }
            return hour
        }()
        return "\(period) \(displayHour):\(minuteStr)"
    }

    private var capacityString: String {
        guard let max = schedule.maxCapacity else { return "" }
        return "예약 가능 인원 : \(max)명"
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Color.GheeYellow
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack(spacing: 13) {
                    VStack(spacing: 0) {
                        Text(dayNumber)
                            .pretendardFont(.bold, size: 17)
                            .foregroundColor(.DarkBlack)
                        Text(dayOfWeekString)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                    }
                    .frame(width: 36, height: 53)
                    .background(Color.CleanWhite)
                    .clipShape(RoundedRectangle(cornerRadius: 19.5))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(className)
                            .pretendardFont(.bold, size: 12)
                            .foregroundColor(.DarkBlack)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        HStack(spacing: 6) {
                            if !timeRangeString.isEmpty {
                                Text(timeRangeString)
                                    .pretendardFont(.medium, size: 10)
                                    .foregroundColor(.DarkBlack)
                            }
                            if !timeRangeString.isEmpty && !capacityString.isEmpty {
                                Rectangle()
                                    .fill(Color.DarkBlack)
                                    .frame(width: 1, height: 10)
                            }
                            if !capacityString.isEmpty {
                                Text(capacityString)
                                    .pretendardFont(.medium, size: 10)
                                    .foregroundColor(.DarkBlack)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .frame(height: 74)
        }
        .buttonStyle(.plain)
    }
}
