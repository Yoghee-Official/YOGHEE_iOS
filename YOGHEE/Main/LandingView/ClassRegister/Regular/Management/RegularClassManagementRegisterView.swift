//
//  RegularClassManagementRegisterView.swift
//  YOGHEE
//
//  정규 수련 등록 — 운영 정보 (CRC_MO_6)
//

import SwiftUI

// MARK: - Main

struct RegularClassManagementRegisterView: View {
    @ObservedObject var container: ClassRegisterContainer
    @Environment(\.dismiss) private var dismiss
    
    private let totalSteps = 7
    private let currentStep = 6
    
    @State private var sheetContext: RegularOperationSheetContext?
    @State private var schedulePendingDelete: NewScheduleDTO?
    @State private var showDeleteConfirm = false
    
    private var canProceed: Bool {
        !container.state.schedules.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerRow
                        .padding(.bottom, 16.ratio())
                    scheduleTimeline
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 16.ratio())
                .padding(.top, 24.ratio())
            }
            .scrollDismissesKeyboard(.immediately)
            
            bottomNavigation
        }
        .background(Color.SandBeige)
        .customNavigationBar(
            title: "운영 정보",
            trailingTitle: "문의하기",
            onTrailingTap: { handleInquiryTap() }
        )
        .sheet(item: $sheetContext) { context in
            RegularOperationBottomSheet(
                context: context,
                existingSchedules: container.state.schedules,
                onApply: { schedule, replacingId in
                    if let id = replacingId {
                        container.handleIntent(.removeSchedule(id))
                    }
                    container.handleIntent(.addSchedule(schedule))
                    sheetContext = nil
                }
            )
        }
        .alert("수련을 삭제할까요?", isPresented: $showDeleteConfirm) {
            Button("삭제", role: .destructive) {
                if let s = schedulePendingDelete {
                    container.handleIntent(.removeSchedule(s.id))
                }
                schedulePendingDelete = nil
            }
            Button("취소", role: .cancel) {
                schedulePendingDelete = nil
            }
        } message: {
            Text("삭제한 수련은 복구할 수 없습니다.")
        }
    }
    
    private var headerRow: some View {
        HStack(spacing: 8.ratio()) {
            Text("수련 시간")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            Text("한 타임 기준")
                .pretendardFont(.bold, size: 10)
                .foregroundColor(.Info)
        }
    }
    
    private var scheduleTimeline: some View {
        RegularScheduleTimelineView(
            schedules: container.state.schedules,
            weeklyOffDays: container.state.regularWeeklyOffWeekdays,
            onAdd: { weekday in
                sheetContext = .add(preselectedWeekday: weekday)
            },
            onEdit: { sheetContext = .edit($0) },
            onCopy: { sheetContext = .copy($0) },
            onDelete: { s in
                schedulePendingDelete = s
                showDeleteConfirm = true
            }
        )
    }
    
    private var bottomNavigation: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.DarkBlack)
                        .frame(width: geo.size.width * CGFloat(currentStep) / CGFloat(totalSteps))
                }
            }
            .frame(height: 4.ratio())
            .padding(.horizontal, 16.ratio())
            .padding(.bottom, 16.ratio())
            
            HStack(spacing: 12.ratio()) {
                Button(action: { dismiss() }) {
                    Text("이전페이지")
                        .pretendardFont(.medium, size: 15)
                        .foregroundColor(.DarkBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48.ratio())
                        .background(Color.Background)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    OnedayClassSetPriceView(container: container)
                } label: {
                    Text("계속")
                        .pretendardFont(.medium, size: 15)
                        .foregroundColor(canProceed ? .DarkBlack : .Info)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48.ratio())
                        .background(canProceed ? Color.GheeYellow : Color.Background)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(!canProceed)
            }
            .padding(.horizontal, 16.ratio())
            .padding(.bottom, 24.ratio())
        }
        .background(Color.SandBeige)
    }
    
    private func handleInquiryTap() {
        // TODO: 문의하기 채널 연결
    }
}

// MARK: - Sheet context

private enum RegularOperationSheetContext: Identifiable {
    case add(preselectedWeekday: Int?)
    case edit(NewScheduleDTO)
    case copy(NewScheduleDTO)
    
    var id: String {
        switch self {
        case .add(let w): return "add-\(w.map(String.init) ?? "none")"
        case .edit(let s): return "edit-\(s.id)"
        case .copy(let s): return "copy-\(s.id)"
        }
    }
}

// MARK: - Timeline

private struct RegularScheduleTimelineView: View {
    let schedules: [NewScheduleDTO]
    let weeklyOffDays: Set<Int>
    let onAdd: (Int) -> Void
    let onEdit: (NewScheduleDTO) -> Void
    let onCopy: (NewScheduleDTO) -> Void
    let onDelete: (NewScheduleDTO) -> Void
    
    /// 시간 눈금 간격 (디자인 100pt)
    private let hourWidth: CGFloat = 100
    private let dayLabelWidth: CGFloat = 28.ratio()
    /// 추가 버튼 열 (고정 영역, 휴무일은 빈 칸으로 폭 유지)
    private let addColumnWidth: CGFloat = 36.ratio()
    private let weekdayToAddSpacing: CGFloat = 8.ratio()
    private let rowHeight: CGFloat = 58.ratio()
    private let timeLabelRowHeight: CGFloat = 24.ratio()
    private let timeHeaderBottomSpacing: CGFloat = 8.ratio()
    private let hours = Array(0..<24)
    
    private var timeHeaderBlockHeight: CGFloat {
        timeLabelRowHeight + timeHeaderBottomSpacing
    }
    
    private static let weekdayLabels: [(Int, String)] = [
        (1, "월"), (2, "화"), (3, "수"), (4, "목"),
        (5, "금"), (6, "토"), (7, "일")
    ]
    
    var body: some View {
        ScrollViewReader { proxy in
            HStack(alignment: .top, spacing: weekdayToAddSpacing) {
                weekdayOnlyColumn
                HStack(alignment: .top, spacing: 0) {
                    addButtonColumnWithGuideLine
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            timeHeaderRow
                            ForEach(Self.weekdayLabels, id: \.0) { appWeekday, _ in
                                timelineGridRow(appWeekday: appWeekday)
                            }
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            proxy.scrollTo("hour-6", anchor: .leading)
                        }
                    }
                }
            }
        }
    }
    
    /// 상단 행: 요일 열과 같은 높이의 빈 칸 + 시간 눈금(스크롤) — 추가 열 상단과 한 줄로 맞춤
    private var timeHeaderRow: some View {
        HStack(spacing: 0) {
            ForEach(hours, id: \.self) { h in
                Text(String(format: "%02d:00", h))
                    .pretendardFont(.bold, size: 10)
                    .foregroundColor(.Info)
                    .frame(width: hourWidth, alignment: .leading)
                    .id("hour-\(h)")
            }
        }
        .frame(height: timeLabelRowHeight)
        .padding(.bottom, timeHeaderBottomSpacing)
    }
    
    /// 좌측 고정: 요일만 (추가 버튼은 오른쪽 열)
    private var weekdayOnlyColumn: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(width: dayLabelWidth, height: timeHeaderBlockHeight)
            ForEach(Self.weekdayLabels, id: \.0) { appWeekday, label in
                weekdayLabelRow(appWeekday: appWeekday, label: label)
            }
        }
        .frame(width: dayLabelWidth)
    }
    
    @ViewBuilder
    private func weekdayLabelRow(appWeekday: Int, label: String) -> some View {
        let isOff = weeklyOffDays.contains(appWeekday)
        ZStack {
            Text(label)
                .pretendardFont(isOff ? .regular : .bold, size: 14)
                .foregroundColor(isOff ? .Info : .DarkBlack)
            if isOff {
                Image("EraseIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16.ratio(), height: 13.ratio())
                    .allowsHitTesting(false)
            }
        }
        .frame(width: dayLabelWidth, height: rowHeight)
    }
    
    /// 추가 버튼 열 + 주황 세로 가이드(플러스 버튼 뒤 레이어)
    private var addButtonColumnWithGuideLine: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(width: addColumnWidth, height: timeHeaderBlockHeight)
            ForEach(Self.weekdayLabels, id: \.0) { appWeekday, _ in
                addButtonCell(appWeekday: appWeekday)
            }
        }
        .frame(width: addColumnWidth)
        .background(alignment: .trailing) {
            Rectangle()
                .fill(Color.MindOrange)
                .frame(width: 2)
        }
    }
    
    @ViewBuilder
    private func addButtonCell(appWeekday: Int) -> some View {
        let isOff = weeklyOffDays.contains(appWeekday)
        Group {
            if isOff {
                Color.clear
            } else {
                Button(action: { onAdd(appWeekday) }) {
                    Image("PlusCircleIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20.ratio(), height: 20.ratio())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: addColumnWidth, height: rowHeight)
    }
    
    /// 스크롤되는 시간축 그리드 한 줄 (수업 블록·가이드 라인만)
    @ViewBuilder
    private func timelineGridRow(appWeekday: Int) -> some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                ForEach(hours, id: \.self) { _ in
                    Color.clear
                        .frame(width: hourWidth)
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(Color.Background.opacity(0.6))
                                .frame(width: 1)
                        }
                }
            }
            
            ForEach(schedulesForDay(appWeekday)) { schedule in
                let w = blockWidth(schedule: schedule)
                if w > 0 {
                    scheduleBlock(schedule: schedule, width: w)
                        .offset(x: xOffset(for: schedule.startTime))
                }
            }
        }
        .frame(width: CGFloat(hours.count) * hourWidth, height: rowHeight, alignment: .topLeading)
    }
    
    private func schedulesForDay(_ appWeekday: Int) -> [NewScheduleDTO] {
        schedules.filter { RegularScheduleDateHelper.schedule($0, appliesToAppWeekday: appWeekday) }
    }
    
    private func xOffset(for time: LocalTimeDTO) -> CGFloat {
        let minutes = CGFloat(time.hour * 60 + time.minute)
        return minutes / 60.0 * hourWidth
    }
    
    private func blockWidth(schedule: NewScheduleDTO) -> CGFloat {
        let sm = schedule.startTime.hour * 60 + schedule.startTime.minute
        let em = schedule.endTime.hour * 60 + schedule.endTime.minute
        let span = max(0, em - sm)
        return CGFloat(span) / 60.0 * hourWidth
    }
    
    private func scheduleBlock(schedule: NewScheduleDTO, width w: CGFloat) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 4.ratio()) {
                Text("\(schedule.startTime.timeString) ~ \(schedule.endTime.timeString)")
                    .pretendardFont(.bold, size: 10)
                    .foregroundColor(.DarkBlack)
                Text(schedule.name)
                    .pretendardFont(.bold, size: 10)
                    .foregroundColor(.DarkBlack)
                    .lineLimit(2)
                if !schedule.instructorNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("T. \(schedule.instructorNote)")
                        .pretendardFont(.medium, size: 10)
                        .foregroundColor(.DarkBlack)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12.ratio())
            .padding(.vertical, 8.ratio())
            .frame(width: w, height: rowHeight - 4)
            .background(Color.FlowBlue)
            .cornerRadius(8)
            
            Menu {
                Button("수정") { onEdit(schedule) }
                Button("복사") { onCopy(schedule) }
                Button("삭제", role: .destructive) { onDelete(schedule) }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.DarkBlack)
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
        .frame(width: w)
        .padding(.top, 2)
    }
}

// MARK: - Date / weekday helpers

private enum RegularScheduleDateHelper {
    private static let df: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f
    }()
    
    /// Apple weekday (1=일 … 7=토) → 앱 규칙 1=월 … 7=일
    static func appWeekday(fromCalendarWeekday c: Int) -> Int {
        switch c {
        case 1: return 7
        case 2: return 1
        case 3: return 2
        case 4: return 3
        case 5: return 4
        case 6: return 5
        case 7: return 6
        default: return 1
        }
    }
    
    static func weekdays(in schedule: NewScheduleDTO) -> Set<Int> {
        let cal = Calendar.current
        var set = Set<Int>()
        for s in schedule.dates {
            guard let d = df.date(from: s) else { continue }
            let c = cal.component(.weekday, from: d)
            set.insert(appWeekday(fromCalendarWeekday: c))
        }
        return set
    }
    
    static func schedule(_ schedule: NewScheduleDTO, appliesToAppWeekday w: Int) -> Bool {
        weekdays(in: schedule).contains(w)
    }
    
    static func anchorDates(for weekdays: Set<Int>, withinDays: Int = 42) -> [String] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var found = Set<Int>()
        var dates: [String] = []
        for offset in 0..<withinDays {
            guard let d = cal.date(byAdding: .day, value: offset, to: today) else { continue }
            let aw = appWeekday(fromCalendarWeekday: cal.component(.weekday, from: d))
            if weekdays.contains(aw), !found.contains(aw) {
                found.insert(aw)
                dates.append(df.string(from: d))
                if found == weekdays { break }
            }
        }
        return dates.sorted()
    }
    
    static func hasTimeConflict(
        schedules: [NewScheduleDTO],
        excludingId: String?,
        weekdays: Set<Int>,
        start: LocalTimeDTO,
        end: LocalTimeDTO
    ) -> Bool {
        let sm = start.hour * 60 + start.minute
        let em = end.hour * 60 + end.minute
        guard em > sm else { return true }
        for s in schedules {
            if s.id == excludingId { continue }
            let swd = Self.weekdays(in: s)
            guard !swd.isDisjoint(with: weekdays) else { continue }
            let ssm = s.startTime.hour * 60 + s.startTime.minute
            let sem = s.endTime.hour * 60 + s.endTime.minute
            if sm < sem && ssm < em {
                return true
            }
        }
        return false
    }
}

// MARK: - Bottom sheet (2a1)

private struct RegularOperationBottomSheet: View {
    let context: RegularOperationSheetContext
    let existingSchedules: [NewScheduleDTO]
    let onApply: (NewScheduleDTO, String?) -> Void
    
    @State private var selectedWeekdays: Set<Int> = []
    @State private var startHour = 7
    @State private var startMinute = 0
    @State private var endHour = 8
    @State private var endMinute = 0
    @State private var practiceName = ""
    @State private var instructorNote = ""
    @State private var minCapacity = 0
    @State private var maxCapacity = 0
    @State private var showStartPicker = false
    @State private var showEndPicker = false
    
    private var replacingId: String? {
        if case .edit(let s) = context { return s.id }
        return nil
    }
    
    private var trimmedName: String { practiceName.trimmingCharacters(in: .whitespacesAndNewlines) }
    
    private var hasDuplicate: Bool {
        guard !selectedWeekdays.isEmpty else { return false }
        let start = LocalTimeDTO(hour: startHour, minute: startMinute)
        let end = LocalTimeDTO(hour: endHour, minute: endMinute)
        return RegularScheduleDateHelper.hasTimeConflict(
            schedules: existingSchedules,
            excludingId: replacingId,
            weekdays: selectedWeekdays,
            start: start,
            end: end
        )
    }
    
    private var canApply: Bool {
        guard !trimmedName.isEmpty else { return false }
        guard !selectedWeekdays.isEmpty else { return false }
        let sm = startHour * 60 + startMinute
        let em = endHour * 60 + endMinute
        guard em > sm else { return false }
        guard minCapacity <= maxCapacity, minCapacity >= 0, maxCapacity <= 999 else { return false }
        if hasDuplicate { return false }
        if case .copy(let s) = context {
            let dates = RegularScheduleDateHelper.anchorDates(for: selectedWeekdays)
            if Set(dates) == Set(s.dates),
               startHour == s.startTime.hour, startMinute == s.startTime.minute,
               endHour == s.endTime.hour, endMinute == s.endTime.minute,
               trimmedName == s.name,
               minCapacity == s.minCapacity, maxCapacity == s.maxCapacity,
               instructorNote == s.instructorNote {
                return false
            }
        }
        return true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.Info)
                .frame(width: 80.ratio(), height: 4.ratio())
                .padding(.top, 16.ratio())
                .padding(.bottom, 12.ratio())
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12.ratio()) {
                    weekdayChipsRow
                    
                    HStack(spacing: 5.ratio()) {
                        timeField(title: "시작 시간", hour: startHour, minute: startMinute) { showStartPicker = true }
                        timeField(title: "종료 시간", hour: endHour, minute: endMinute) { showEndPicker = true }
                    }
                    
                    labeledField(title: "수련명", required: true, content: {
                        TextField("", text: $practiceName)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                    })
                    
                    labeledField(title: "지도자 (메모)", required: false, content: {
                        TextField("", text: $instructorNote)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                    })
                    
                    Rectangle()
                        .fill(Color.Background)
                        .frame(height: 1)
                        .padding(.vertical, 8.ratio())
                    
                    capacityRow(label: "최소 수련 가능 인원", value: $minCapacity, isMinSide: true)
                    capacityRow(label: "최대 수련 가능 인원", value: $maxCapacity, isMinSide: false)
                    
                    if hasDuplicate {
                        Text("* 동일한 시간에 중복된 내용 있습니다. 시간을 조정해주세요!")
                            .pretendardFont(.regular, size: 10)
                            .foregroundColor(.MindOrange)
                            .padding(.top, 8.ratio())
                    }
                }
                .padding(.horizontal, 16.ratio())
                .padding(.bottom, 120.ratio())
            }
            
            VStack(spacing: 0) {
                Button(action: apply) {
                    Text("적용")
                        .pretendardFont(.semiBold, size: 15)
                        .foregroundColor(canApply ? .DarkBlack : .Info)
                        .frame(width: 208.ratio(), height: 48.ratio())
                        .background(
                            Group {
                                if canApply {
                                    RoundedRectangle(cornerRadius: 79)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 1, green: 0.93, blue: 0.45),
                                                    Color(red: 1, green: 0.96, blue: 0.75)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 79)
                                        .fill(Color.Background)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canApply)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(16.ratio())
            }
            .background(Color.CleanWhite)
            .overlay(
                Rectangle()
                    .stroke(Color.Background, lineWidth: 1)
                    .frame(maxHeight: .infinity, alignment: .top)
            )
        }
        .background(Color.CleanWhite)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .onAppear(perform: loadContext)
        .sheet(isPresented: $showStartPicker) {
            RegularOperationTimePickerSheet(
                initialHour: startHour,
                initialMinute: startMinute,
                onConfirm: { h, m in
                    startHour = h
                    startMinute = m
                    showStartPicker = false
                }
            )
            .id("op-time-start-\(startHour)-\(startMinute)")
        }
        .sheet(isPresented: $showEndPicker) {
            RegularOperationTimePickerSheet(
                initialHour: endHour,
                initialMinute: endMinute,
                onConfirm: { h, m in
                    endHour = h
                    endMinute = m
                    showEndPicker = false
                }
            )
            .id("op-time-end-\(endHour)-\(endMinute)")
        }
    }
    
    private var weekdayChipsRow: some View {
        FlowLayout(spacing: 8.ratio()) {
            ForEach([(1, "월"), (2, "화"), (3, "수"), (4, "목"), (5, "금"), (6, "토"), (7, "일")], id: \.0) { w, label in
                Button {
                    if selectedWeekdays.contains(w) {
                        selectedWeekdays.remove(w)
                    } else {
                        selectedWeekdays.insert(w)
                    }
                } label: {
                    Text(label)
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                        .padding(.horizontal, 12.ratio())
                        .padding(.vertical, 8.ratio())
                        .background(selectedWeekdays.contains(w) ? Color.NatureGreen : Color.Background)
                        .cornerRadius(32)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func timeField(title: String, hour: Int, minute: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4.ratio()) {
                HStack(spacing: 0) {
                    Text("\(title) ")
                        .pretendardFont(.regular, size: 10)
                        .foregroundColor(.DarkBlack)
                    Text("* (24시간 기준)")
                        .pretendardFont(.regular, size: 10)
                        .foregroundColor(.MindOrange)
                }
                Text(String(format: "%02d:%02d", hour, minute))
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16.ratio())
            .padding(.vertical, 8.ratio())
            .frame(height: 49.ratio())
            .background(Color.CleanWhite)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.Background, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
    
    private func labeledField<Content: View>(title: String, required: Bool, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4.ratio()) {
            HStack(spacing: 0) {
                Text(title)
                    .pretendardFont(.regular, size: 10)
                    .foregroundColor(.DarkBlack)
                if required {
                    Text(" *")
                        .pretendardFont(.regular, size: 10)
                        .foregroundColor(.MindOrange)
                }
            }
            content()
                .padding(8.ratio())
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 36.ratio())
                .background(Color.CleanWhite)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.Background, lineWidth: 1))
        }
        .frame(height: 49.ratio())
    }
    
    private func capacityRow(label: String, value: Binding<Int>, isMinSide: Bool) -> some View {
        HStack {
            Text(label)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
            Spacer()
            HStack(spacing: 12.ratio()) {
                Button {
                    if value.wrappedValue > 0 {
                        value.wrappedValue -= 1
                        if isMinSide, minCapacity > maxCapacity {
                            maxCapacity = minCapacity
                        }
                        if !isMinSide, maxCapacity < minCapacity {
                            minCapacity = maxCapacity
                        }
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24.ratio()))
                        .foregroundColor(value.wrappedValue > 0 ? Color(hex: "B3B3B3") : Color.Background)
                }
                .disabled(value.wrappedValue <= 0)
                .buttonStyle(.plain)
                
                Text("\(value.wrappedValue)")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                
                Button {
                    if value.wrappedValue < 999 {
                        value.wrappedValue += 1
                        if isMinSide, minCapacity > maxCapacity {
                            maxCapacity = minCapacity
                        }
                        if !isMinSide, maxCapacity < minCapacity {
                            minCapacity = maxCapacity
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24.ratio()))
                        .foregroundColor(value.wrappedValue < 999 ? Color(hex: "B3B3B3") : Color.Background)
                }
                .disabled(value.wrappedValue >= 999)
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16.ratio())
    }
    
    private func loadContext() {
        switch context {
        case .add(let pre):
            selectedWeekdays = pre.map { Set([$0]) } ?? []
            startHour = 7
            startMinute = 0
            endHour = 8
            endMinute = 0
            practiceName = ""
            instructorNote = ""
            minCapacity = 0
            maxCapacity = 0
        case .edit(let s), .copy(let s):
            selectedWeekdays = RegularScheduleDateHelper.weekdays(in: s)
            startHour = s.startTime.hour
            startMinute = s.startTime.minute
            endHour = s.endTime.hour
            endMinute = s.endTime.minute
            practiceName = s.name
            instructorNote = s.instructorNote
            minCapacity = s.minCapacity
            maxCapacity = s.maxCapacity
        }
    }
    
    private func apply() {
        let dates = RegularScheduleDateHelper.anchorDates(for: selectedWeekdays)
        guard !dates.isEmpty else { return }
        let dto = NewScheduleDTO(
            scheduleId: nil,
            localId: UUID().uuidString,
            dates: dates,
            startTime: LocalTimeDTO(hour: startHour, minute: startMinute),
            endTime: LocalTimeDTO(hour: endHour, minute: endMinute),
            minCapacity: minCapacity,
            maxCapacity: maxCapacity,
            name: trimmedName,
            instructorNote: instructorNote.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        onApply(dto, replacingId)
    }
}

// MARK: - Time picker (운영 정보 시트 전용)

private struct RegularOperationTimePickerSheet: View {
    let initialHour: Int
    let initialMinute: Int
    let onConfirm: (Int, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    
    init(initialHour: Int, initialMinute: Int, onConfirm: @escaping (Int, Int) -> Void) {
        self.initialHour = initialHour
        self.initialMinute = initialMinute
        self.onConfirm = onConfirm
        _selectedHour = State(initialValue: initialHour)
        _selectedMinute = State(initialValue: initialMinute)
    }
    
    var body: some View {
        VStack(spacing: 16.ratio()) {
            HStack(spacing: 24.ratio()) {
                Picker("시", selection: $selectedHour) {
                    ForEach(0..<24, id: \.self) { h in
                        Text(String(format: "%02d", h)).tag(h)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80.ratio())
                Text(":")
                    .pretendardFont(.bold, size: 20)
                Picker("분", selection: $selectedMinute) {
                    ForEach(0..<60, id: \.self) { m in
                        Text(String(format: "%02d", m)).tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80.ratio())
            }
            .frame(height: 150.ratio())
            Button {
                onConfirm(selectedHour, selectedMinute)
                dismiss()
            } label: {
                Text("확인")
                    .pretendardFont(.medium, size: 15)
                    .foregroundColor(.CleanWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48.ratio())
                    .background(Color.DarkBlack)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16.ratio())
        }
        .padding(.vertical, 24.ratio())
        .onAppear {
            // 휠 피커가 초기값과 어긋나 30분 등으로 스냅되는 경우 방지
            selectedHour = initialHour
            selectedMinute = initialMinute
        }
    }
}

#Preview {
    NavigationStack {
        RegularClassManagementRegisterView(container: ClassRegisterContainer())
    }
}
