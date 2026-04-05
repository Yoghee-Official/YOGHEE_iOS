//
//  ScheduleInputBottomSheet.swift
//  YOGHEE
//
//  Created by 0ofKim on 3/4/26.
//

import SwiftUI

// MARK: - Schedule Input Bottom Sheet (2aa)
struct ScheduleInputBottomSheet: View {
    let context: ScheduleSheetContext
    let onSave: (NewScheduleDTO, String?) -> Void
    
    @State private var editableDates: Set<String> = []
    @State private var startHour = 0
    @State private var startMinute = 0
    @State private var endHour = 0
    @State private var endMinute = 0
    @State private var scheduleName = ""
    @State private var minCapacity = 0
    @State private var maxCapacity = 0
    
    @State private var showStartTimePicker = false
    @State private var showEndTimePicker = false
    
    private var selectedDates: [String] { Array(editableDates).sorted() }
    private var replacingScheduleId: String? {
        if case .edit(let schedule) = context { return schedule.id }
        return nil
    }
    private var trimmedScheduleName: String { scheduleName.trimmingCharacters(in: .whitespacesAndNewlines) }
    
    /// 복사 모드에서 기존과 동일한 내용이면 true (버튼 비활성화)
    private var isSameAsOriginal: Bool {
        guard case .copy(let schedule) = context else { return false }
        
        return Set(selectedDates) == Set(schedule.dates) &&
            startHour == schedule.startTime.hour &&
            startMinute == schedule.startTime.minute &&
            endHour == schedule.endTime.hour &&
            endMinute == schedule.endTime.minute &&
            trimmedScheduleName == schedule.name &&
            minCapacity == schedule.minCapacity &&
            maxCapacity == schedule.maxCapacity
    }
    
    private var canSave: Bool {
        // 복사 시 기존과 동일하면 비활성화
        if isSameAsOriginal { return false }
        
        return !trimmedScheduleName.isEmpty &&
            minCapacity <= maxCapacity &&
            minCapacity >= 0 &&
            maxCapacity <= 999
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Home Indicator
            RoundedRectangle(cornerRadius: 100)
                .fill(Color(hex: "B3B3B3"))
                .frame(width: 80.ratio(), height: 4.ratio())
                .padding(.top, 16.ratio())
                .padding(.bottom, 20.ratio())
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12.ratio()) {
                    // 시작/종료 시간
                    HStack(spacing: 5.ratio()) {
                        timeField(
                            label: "시작 시간",
                            hour: $startHour,
                            minute: $startMinute,
                            isPresented: $showStartTimePicker
                        )
                        
                        timeField(
                            label: "종료 시간",
                            hour: $endHour,
                            minute: $endMinute,
                            isPresented: $showEndTimePicker
                        )
                    }
                    
                    // 개별 수련명
                    VStack(alignment: .leading, spacing: 4.ratio()) {
                        Text("개별 수련명 *")
                            .pretendardFont(.regular, size: 10)
                            .foregroundColor(.DarkBlack)
                        
                        TextField("", text: $scheduleName)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                            .padding(8.ratio())
                            .background(Color.CleanWhite)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.Background, lineWidth: 1)
                            )
                    }
                    .frame(height: 49.ratio())
                    
                    Divider()
                        .background(Color.Background)
                        .padding(.vertical, 16.ratio())
                    
                    // 최소/최대 수련 가능 인원
                    capacityStepper(label: "최소 수련 가능 인원", value: $minCapacity, isMin: true)
                    capacityStepper(label: "최대 수련 가능 인원", value: $maxCapacity, isMin: false)
                }
                .padding(.horizontal, 16.ratio())
                .padding(.bottom, 32.ratio())
            }
            .frame(maxWidth: 343.ratio())
            
            // 저장 버튼
            Button(action: saveSchedule) {
                Text("저장")
                    .pretendardFont(.medium, size: 15)
                    .foregroundColor(canSave ? .CleanWhite : .Info)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48.ratio())
                    .background(canSave ? Color.DarkBlack : Color.Background)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
            .padding(.horizontal, 16.ratio())
            .padding(.bottom, 24.ratio())
        }
        .background(Color.CleanWhite)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .onAppear {
            applyInitialData()
        }
        .sheet(isPresented: $showStartTimePicker) {
            TimePickerSheet(
                initialHour: startHour,
                initialMinute: startMinute,
                onConfirm: { h, m in
                    startHour = h
                    startMinute = m
                    showStartTimePicker = false
                }
            )
        }
        .sheet(isPresented: $showEndTimePicker) {
            TimePickerSheet(
                initialHour: endHour,
                initialMinute: endMinute,
                onConfirm: { h, m in
                    endHour = h
                    endMinute = m
                    showEndTimePicker = false
                }
            )
        }
    }
    
    private func timeField(
        label: String,
        hour: Binding<Int>,
        minute: Binding<Int>,
        isPresented: Binding<Bool>
    ) -> some View {
        Button(action: { isPresented.wrappedValue = true }) {
            VStack(alignment: .leading, spacing: 4.ratio()) {
                Text("\(label) * (24시간 기준)")
                    .pretendardFont(.regular, size: 10)
                    .foregroundColor(.DarkBlack)
                
                Text(String(format: "%02d:%02d", hour.wrappedValue, minute.wrappedValue))
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 49.ratio())
            .padding(.horizontal, 16.ratio())
            .padding(.vertical, 8.ratio())
            .background(Color.CleanWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func capacityStepper(label: String, value: Binding<Int>, isMin: Bool) -> some View {
        HStack {
            Text(label)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
            
            Spacer()
            
            HStack(spacing: 12.ratio()) {
                Button(action: {
                    if value.wrappedValue > 0 {
                        value.wrappedValue -= 1
                        if !isMin && maxCapacity < minCapacity {
                            minCapacity = maxCapacity
                        }
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24.ratio()))
                        .foregroundColor(value.wrappedValue > 0 ? Color(hex: "B3B3B3") : Color.Background)
                }
                .disabled(value.wrappedValue <= 0)
                .buttonStyle(.plain)
                
                Text("\(value.wrappedValue)")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                
                Button(action: {
                    if value.wrappedValue < 999 {
                        value.wrappedValue += 1
                        if isMin && minCapacity > maxCapacity {
                            maxCapacity = minCapacity
                        }
                    }
                }) {
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
    
    private func applyInitialData() {
        switch context {
        case .add(let dates):
            editableDates = Set(dates)
            
        case .edit(let schedule), .copy(let schedule):
            editableDates = Set(schedule.dates)
            startHour = schedule.startTime.hour
            startMinute = schedule.startTime.minute
            endHour = schedule.endTime.hour
            endMinute = schedule.endTime.minute
            scheduleName = schedule.name
            minCapacity = schedule.minCapacity
            maxCapacity = schedule.maxCapacity
        }
    }
    
    private func saveSchedule() {
        let schedule = NewScheduleDTO(
            scheduleId: nil,
            localId: UUID().uuidString,
            dates: selectedDates,
            startTime: LocalTimeDTO(hour: startHour, minute: startMinute),
            endTime: LocalTimeDTO(hour: endHour, minute: endMinute),
            minCapacity: minCapacity,
            maxCapacity: maxCapacity,
            name: trimmedScheduleName,
            instructorNote: ""
        )
        onSave(schedule, replacingScheduleId)
    }
}

// MARK: - Time Picker Sheet (숫자 다이얼)
private struct TimePickerSheet: View {
    let onConfirm: (Int, Int) -> Void
    
    @State private var selectedHour: Int
    @State private var selectedMinute: Int
    
    init(initialHour: Int, initialMinute: Int, onConfirm: @escaping (Int, Int) -> Void) {
        _selectedHour = State(initialValue: initialHour)
        _selectedMinute = State(initialValue: initialMinute)
        
        self.onConfirm = onConfirm
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
            
            Button(action: {
                onConfirm(selectedHour, selectedMinute)
            }) {
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
    }
}
