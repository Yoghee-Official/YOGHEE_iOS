//
//  OnedayClassInformationRegisterView.swift
//  YOGHEE
//
//  Created by 0ofKim on 3/2/26.
//

import SwiftUI

struct OnedayClassInformationRegisterView: View {
    @ObservedObject var container: ClassRegisterContainer
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDates: Set<String> = []
    @State private var sheetContext: ScheduleSheetContext?
    
    private let totalSteps = 6
    private let currentStep = 3
    
    /// 2a 영역 포함하여 스케줄이 1개 이상 등록되면 활성화
    private var canProceed: Bool {
        !container.state.schedules.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 2a: 날짜 선택
                    dateSelectionSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16.ratio())
                .padding(.top, 24.ratio())
            }
            
            // 3: 하단 네비게이션 (프로그레스 + 이전페이지/계속)
            bottomNavigation
        }
        .background(Color.SandBeige)
        .customNavigationBar(title: "수련 정보")
        .sheet(item: $sheetContext) { context in
            ScheduleInputBottomSheet(
                context: context,
                onSave: { schedule, replacingScheduleId in
                    if let id = replacingScheduleId {
                        container.handleIntent(.removeSchedule(id))
                    }
                    container.handleIntent(.addSchedule(schedule))
                    if case .add = context {
                        selectedDates.removeAll()
                    }
                    sheetContext = nil
                }
            )
        }
    }
    
    // MARK: - 2a: 날짜 선택
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16.ratio()) {
            Text("추가하고 싶은 날짜를 선택해주세요.")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            
            Text("수련 오픈하는 날짜만 선택 해주세요.\n요기는 휴강을 설정하지 않아도 괜찮아요.")
                .pretendardFont(.bold, size: 10)
                .foregroundColor(.Info)
            
            ScheduleDateSelectionCalendarView(selectedDates: $selectedDates)
                .padding(.top, 8.ratio())
            
            // 2aa: 수련 추가 버튼
            Button(action: {
                sheetContext = .add(selectedDates: Array(selectedDates).sorted())
            }) {
                Text("+ 선택한 날짜에 수련 추가")
                    .pretendardFont(.medium, size: 14)
                    .foregroundColor(.DarkBlack)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48.ratio())
                    .background(Color.Background)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.Background, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .disabled(selectedDates.isEmpty)
            .padding(.top, 16.ratio())
            
            // 2b: 수련 카드 목록
            if !container.state.schedules.isEmpty {
                VStack(spacing: 12.ratio()) {
                    ForEach(container.state.schedules) { schedule in
                        ScheduleCardView(
                            schedule: schedule,
                            onEdit: {
                                sheetContext = .edit(schedule: schedule)
                            },
                            onCopy: {
                                sheetContext = .copy(schedule: schedule)
                            },
                            onDelete: {
                                container.handleIntent(.removeSchedule(schedule.id))
                            }
                        )
                    }
                }
                .padding(.top, 24.ratio())
            }
        }
    }
    
    // MARK: - 3: 하단 네비게이션
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
                
                Button(action: {
                    // TODO: 다음 단계로 이동
                }) {
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
}

#Preview {
    NavigationStack {
        OnedayClassInformationRegisterView(container: ClassRegisterContainer())
    }
}
