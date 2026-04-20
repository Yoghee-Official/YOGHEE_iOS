//
//  RegularClassHolidayRegisterView.swift
//  YOGHEE
//
//  정규 수련 등록 — 휴무 정보 (CRC_MO_5)
//

import SwiftUI

struct RegularClassHolidayRegisterView: View {
    @ObservedObject var container: ClassRegisterContainer
    @Environment(\.dismiss) private var dismiss
    
    private let totalSteps = 7
    private let currentStep = 5
    
    /// 1=월 … 7=일
    private static let weekdayLabels: [(Int, String)] = [
        (1, "월"), (2, "화"), (3, "수"), (4, "목"),
        (5, "금"), (6, "토"), (7, "일")
    ]
    
    private var canProceed: Bool {
        if !container.state.regularHasFixedHolidays { return true }
        let weekly = container.state.regularWeeklyOffWeekdays
        let pub = container.state.regularPublicHolidayOffIds
        return !weekly.isEmpty || !pub.isEmpty
    }
    
    private var isAllPublicOffPreset: Bool {
        container.state.regularPublicHolidayOffIds == RegularPublicHoliday.allHolidayIds
    }
    
    private var isSeolChuseokOnlyPreset: Bool {
        container.state.regularPublicHolidayOffIds == RegularPublicHoliday.seolChuseokOnlyIds
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    presenceSection
                        .padding(.bottom, 24.ratio())
                    
                    if container.state.regularHasFixedHolidays {
                        dividerLine
                        weeklySection
                            .padding(.top, 20.ratio())
                            .padding(.bottom, 24.ratio())
                        dividerLine
                        publicHolidaySection
                            .padding(.top, 20.ratio())
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16.ratio())
                .padding(.top, 24.ratio())
            }
            .scrollDismissesKeyboard(.immediately)
            
            bottomNavigation
        }
        .background(Color.SandBeige)
        .customNavigationBar(
            title: "휴무 정보",
            trailingTitle: "문의하기",
            onTrailingTap: { handleInquiryTap() }
        )
    }
    
    // MARK: - 2a 휴무 유무
    private var presenceSection: some View {
        VStack(alignment: .leading, spacing: 16.ratio()) {
            Text("휴무일이 있나요?")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            
            HStack(spacing: 15.ratio()) {
                presenceOption(
                    title: "휴무일이 있어요",
                    isSelected: container.state.regularHasFixedHolidays
                ) {
                    container.handleIntent(.setRegularHasFixedHolidays(true))
                }
                presenceOption(
                    title: "휴무일이 없어요",
                    isSelected: !container.state.regularHasFixedHolidays
                ) {
                    container.handleIntent(.setRegularHasFixedHolidays(false))
                }
            }
        }
    }
    
    private func presenceOption(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 40.ratio())
                .background(isSelected ? Color.NatureGreen : Color.Background)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 2b 휴무요일
    private var weeklySection: some View {
        VStack(alignment: .leading, spacing: 16.ratio()) {
            HStack {
                Text("휴무요일 선택")
                    .pretendardFont(.bold, size: 16)
                    .foregroundColor(.DarkBlack)
                Spacer()
                Text("매주")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.CleanWhite)
                    .padding(.horizontal, 12.ratio())
                    .padding(.vertical, 8.ratio())
                    .background(Color.MindOrange)
                    .cornerRadius(8)
            }
            
            // 피그마 47×7 + 간격 6×4는 375 기준으로 좌우 패딩(32)을 합치면 화면보다 넓어져
            // ScrollView 콘텐츠 최소 너비가 커지며 전체 너비가 달라 보이는 현상이 납니다. 가용 너비를 7등분합니다.
            HStack(spacing: 4.ratio()) {
                ForEach(Self.weekdayLabels, id: \.0) { day, label in
                    let isOff = container.state.regularWeeklyOffWeekdays.contains(day)
                    Button {
                        container.handleIntent(.toggleRegularWeeklyOffWeekday(day))
                    } label: {
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
                        .frame(maxWidth: .infinity)
                        .frame(height: 40.ratio())
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - 2c 공휴일
    private var publicHolidaySection: some View {
        VStack(alignment: .leading, spacing: 16.ratio()) {
            Text("다음 공휴일 중 휴무일이 있나요?")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            
            quickFilterRow(
                title: "전체 휴무",
                isChecked: isAllPublicOffPreset
            ) {
                container.handleIntent(.applyRegularPublicHolidayPresetAll)
            }
            
            FlowLayout(spacing: 8.ratio()) {
                ForEach(RegularPublicHoliday.allCases) { holiday in
                    let isOff = container.state.regularPublicHolidayOffIds.contains(holiday.rawValue)
                    Button {
                        container.handleIntent(.toggleRegularPublicHolidayOff(holiday.rawValue))
                    } label: {
                        Text(holiday.title)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                            .padding(.horizontal, 12.ratio())
                            .padding(.vertical, 8.ratio())
                            .background(isOff ? Color.NatureGreen : Color.Background)
                            .cornerRadius(32)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func quickFilterRow(title: String, isChecked: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8.ratio()) {
                ZStack {
                    Circle()
                        .fill(Color.CleanWhite)
                    Circle()
                        .stroke(Color.Background, lineWidth: 1)
                    if isChecked {
                        Image("CheckCircleIconFull")
                    } else {
                        Image("CheckCircleIconEmpty")
                    }
                }
                .frame(width: 20.ratio(), height: 20.ratio())
                Text(title)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var dividerLine: some View {
        Rectangle()
            .fill(Color.Background)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
    
    // MARK: - 하단
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
                    RegularClassManagementRegisterView(container: container)
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
        // TODO: 문의하기 채널(웹/카카오 등) 연결
    }
}

#Preview {
    NavigationStack {
        RegularClassHolidayRegisterView(container: ClassRegisterContainer())
    }
}
