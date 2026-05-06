//
//  ScheduleModuleView.swift
//  YOGHEE
//

import SwiftUI

/// 6a 수련 시간표 캘린더 + 6b 수업 유닛 모듈
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
        VStack(alignment: .leading, spacing: 16) {
            // 라벨
            Text("수련 시간표")
                .pretendardFont(.bold, size: 14)
                .foregroundColor(.DarkBlack)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.DarkBlack, lineWidth: 1)
                )

            VStack(spacing: 8) {
                // 캘린더 (마이페이지 CalendarView 재활용, 요기니 색상 사용)
                CalendarView(
                    reservedDates: reservedDates,
                    selectedDate: $selectedDate,
                    userRole: .yogini
                )

                // 선택 날짜의 수업 유닛 리스트
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

    private static func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    /// "2026-03-30T15:00:00.000+00:00" 또는 "2026-03-30" 형식에서 yyyy-MM-dd만 추출
    fileprivate static func dayString(from raw: String?) -> String? {
        guard let raw, raw.count >= 10 else { return nil }
        return String(raw.prefix(10))
    }
}

// MARK: - 수업 유닛 (6b)

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
                    // 좌측 날짜 박스
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

                    // 중앙 정보
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
