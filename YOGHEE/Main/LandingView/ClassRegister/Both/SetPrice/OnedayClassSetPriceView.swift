//
//  OnedayClassSetPriceView.swift
//  YOGHEE
//
//  클래스 생성_금액 설정 화면 (피그마 3578-12859 기준)
//

import SwiftUI

struct OnedayClassSetPriceView: View {
    @ObservedObject var container: ClassRegisterContainer
    @Environment(\.dismiss) private var dismiss
    @Environment(\.classRegisterPopToRoot) private var popToRoot
    
    @State private var showResultPopup = false
    @State private var isRegistering = false
    @State private var registerError: String?

    // 정규 수련 금액 플랜 시트
    @State private var planSheetContext: RegularPlanSheetContext?
    @State private var planPendingDelete: RegularPricePlan?
    @State private var showDeletePlanConfirm = false
    
    private var isRegularStudioFlow: Bool {
        container.state.selectedClassTypeId == "regular"
    }
    
    /// 원데이 6단계 / 정규 7단계
    private var totalSteps: Int { isRegularStudioFlow ? 7 : 6 }
    private var currentStep: Int { isRegularStudioFlow ? 7 : 6 }
    private let reservationNoticeLimit = 3000
    
    private var canComplete: Bool {
        if isRegularStudioFlow {
            return !container.state.regularPricePlans.isEmpty
        }
        let price = container.state.pricePerSession.trimmingCharacters(in: .whitespacesAndNewlines)
        return !price.isEmpty && (Int(price.replacingOccurrences(of: ",", with: "")) ?? 0) >= 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if isRegularStudioFlow {
                        // 정규 수련: 기간권/회차권 금액 플랜 목록
                        regularPriceInfoSection
                        divider
                    } else {
                        // 원데이: 1회 수업 금액 + 할인방식
                        priceRowSection
                        divider
                        discountSection
                        divider
                    }
                    // 환불기준 + 예약 취소 안내 (환급금액) 3행
                    refundSection
                    divider
                    // 예약 시 안내사항 (내용 + placeholder + 0/3000)
                    reservationNoticeSection
                    divider
                    // 미리보기: 그라데이션 버튼 (FlowBlue → NatureGreen)
                    previewButtonSection
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 16.ratio())
                .padding(.top, 24.ratio())
            }
            .scrollDismissesKeyboard(.immediately)
            .background(Color.SandBeige)
            bottomNavigation
        }
        .background(Color.SandBeige)
        .customNavigationBar(title: "금액 정보")
        .fullScreenCover(isPresented: $showResultPopup) {
            ClassRegisterResultPopupView(onDismiss: {
                showResultPopup = false
                popToRoot?()
            })
            .environment(\.classRegisterPopToRoot, popToRoot)
        }
        .overlay {
            if isRegistering {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.white)
            }
        }
        .alert("등록 실패", isPresented: Binding(
            get: { registerError != nil },
            set: { if !$0 { registerError = nil } }
        )) {
            Button("확인", role: .cancel) { registerError = nil }
        } message: {
            if let msg = registerError { Text(msg) }
        }
        .sheet(item: $planSheetContext) { ctx in
            RegularPlanInputSheet(context: ctx) { plan, replacingId in
                if let id = replacingId {
                    container.handleIntent(.removeRegularPricePlan(id))
                }
                container.handleIntent(.addRegularPricePlan(plan))
                planSheetContext = nil
            }
        }
        .alert("금액 플랜을 삭제할까요?", isPresented: $showDeletePlanConfirm) {
            Button("삭제", role: .destructive) {
                if let p = planPendingDelete {
                    container.handleIntent(.removeRegularPricePlan(p.id))
                }
                planPendingDelete = nil
            }
            Button("취소", role: .cancel) { planPendingDelete = nil }
        } message: {
            Text("삭제한 금액 플랜은 복구할 수 없습니다.")
        }
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.Background)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20.ratio())
    }
    
    // MARK: - 정규 수련 금액 정보 (기간권/회차권 목록 + 추가 버튼)
    private var regularPriceInfoSection: some View {
        VStack(alignment: .leading, spacing: 16.ratio()) {
            Text("추가하고 싶은 금액 정보를 입력해주세요.")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)

            Button(action: { planSheetContext = .add }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.Info)
                    Spacer()
                }
                .frame(height: 48.ratio())
                .background(Color.Background)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)

            ForEach(container.state.regularPricePlans) { plan in
                regularPlanCard(plan)
            }
        }
        .padding(.vertical, 4.ratio())
    }

    private func regularPlanCard(_ plan: RegularPricePlan) -> some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 8.ratio()) {
                Text(plan.displayLabel)
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(.DarkBlack)

                Text(plan.formattedPrice)
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(.DarkBlack)

                HStack(spacing: 8.ratio()) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundColor(.DarkBlack)
                    if plan.planType == .period {
                        Text("\(plan.validMonths)개월")
                        Rectangle().fill(Color.Info).frame(width: 1, height: 10)
                        Text("주 \(plan.weeklyCount)회")
                    } else {
                        Text("총 \(plan.totalSessions)회")
                        Rectangle().fill(Color.Info).frame(width: 1, height: 10)
                        Text("\(plan.validMonths)개월")
                    }
                }
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
            }

            Spacer(minLength: 8.ratio())

            Menu {
                Button("수정") { planSheetContext = .edit(plan) }
                Button("복사") { planSheetContext = .copy(plan) }
                Button("삭제", role: .destructive) {
                    planPendingDelete = plan
                    showDeletePlanConfirm = true
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 12, weight: .bold))
                    .rotationEffect(.degrees(90))
                    .foregroundColor(.DarkBlack)
                    .padding(8)
            }
        }
        .padding(.horizontal, 16.ratio())
        .padding(.vertical, 12.ratio())
        .background(Color.CleanWhite)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.Background, lineWidth: 1))
    }

    // MARK: - 1회 수업 / OO원 (피그마: 한 줄, 좌 1회 수업 / 우 금액)
    private var priceRowSection: some View {
        HStack {
            Text("1회 수업")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            Spacer()
            HStack(spacing: 4.ratio()) {
                TextField("0", text: Binding(
                    get: { container.state.pricePerSession },
                    set: { container.handleIntent(.setPricePerSession($0)) }
                ))
                .keyboardType(.numberPad)
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
                .multilineTextAlignment(.trailing)
                .frame(width: 120.ratio())
                Text("원")
                    .pretendardFont(.bold, size: 16)
                    .foregroundColor(.DarkBlack)
            }
        }
        .padding(.vertical, 4.ratio())
    }
    
    // MARK: - 할인방식 (피그마: 정률=Mind Orange+흰글자, 정액=Background+검정글자, h32 p12 gap8)
    private var discountSection: some View {
        VStack(alignment: .leading, spacing: 24.ratio()) {
            HStack {
                Text("할인방식")
                    .pretendardFont(.bold, size: 16)
                    .foregroundColor(.DarkBlack)
                Spacer()
                HStack(spacing: 8.ratio()) {
                    discountMethodButton(title: "정률", value: "rate")
                    discountMethodButton(title: "정액", value: "amount")
                }
            }
            if container.state.discountMethod == "rate" {
                HStack {
                    Text("할인률 기준")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                    Spacer()
                    HStack(spacing: 4.ratio()) {
                        TextField("0", text: Binding(
                            get: { container.state.discountRate },
                            set: { container.handleIntent(.setDiscountRate($0)) }
                        ))
                        .keyboardType(.numberPad)
                        .pretendardFont(.bold, size: 14)
                        .foregroundColor(.MindOrange)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 48.ratio())
                        Text("%")
                            .pretendardFont(.bold, size: 14)
                            .foregroundColor(.MindOrange)
                        Text("할인")
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                    }
                }
            }
            if container.state.discountMethod == "amount" {
                HStack {
                    Text("할인금액 기준")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                    Spacer()
                    HStack(spacing: 20.ratio()) {
                        TextField("0", text: Binding(
                            get: { container.state.discountAmount },
                            set: { container.handleIntent(.setDiscountAmount($0)) }
                        ))
                        .keyboardType(.numberPad)
                        .pretendardFont(.bold, size: 14)
                        .foregroundColor(.MindOrange)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 72.ratio())
                        Text("원 할인")
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                    }
                }
            }
        }
        .padding(.vertical, 4.ratio())
    }
    
    private func discountMethodButton(title: String, value: String) -> some View {
        let isSelected = container.state.discountMethod == value
        return Button(action: {
            container.handleIntent(.setDiscountMethod(isSelected ? nil : value))
        }) {
            Text(title)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(isSelected ? .CleanWhite : .DarkBlack)
                .padding(.horizontal, 12.ratio())
                .padding(.vertical, 12.ratio())
                .frame(height: 32.ratio())
                .background(isSelected ? Color.MindOrange : Color.Background)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 환불기준 (피그마: 예약 취소 안내 (환급금액) + 3행, 숫자 Mind Orange Bold 14)
    private var refundSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("환불기준")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
                .padding(.bottom, 20.ratio())
            Text("예약 취소 안내 (환급금액)")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
                .padding(.bottom, 20.ratio())
            VStack(alignment: .leading, spacing: 16.ratio()) {
                ForEach(container.state.refundRules) { rule in
                    refundRuleRow(rule)
                }
            }
        }
        .padding(.vertical, 4.ratio())
    }
    
    private func refundRuleRow(_ rule: RefundRuleRow) -> some View {
        HStack {
            HStack(spacing: 12.ratio()) {
                Text("수련 시작")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                TextField("0", value: Binding(
                    get: { rule.hoursBefore },
                    set: { newVal in
                        let current = container.state.refundRules.first(where: { $0.id == rule.id })
                        container.handleIntent(.updateRefundRule(id: rule.id, hoursBefore: newVal, percent: current?.percent ?? 0))
                    }
                ), format: .number)
                .keyboardType(.numberPad)
                .pretendardFont(.bold, size: 14)
                .foregroundColor(.MindOrange)
                .multilineTextAlignment(.center)
                .frame(width: 44.ratio())
                Text("시간 전")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
            }
            Spacer()
            HStack(spacing: 4.ratio()) {
                TextField("0", value: Binding(
                    get: { rule.percent },
                    set: { newVal in
                        let current = container.state.refundRules.first(where: { $0.id == rule.id })
                        container.handleIntent(.updateRefundRule(id: rule.id, hoursBefore: current?.hoursBefore ?? 0, percent: newVal))
                    }
                ), format: .number)
                .keyboardType(.numberPad)
                .pretendardFont(.bold, size: 14)
                .foregroundColor(.MindOrange)
                .multilineTextAlignment(.trailing)
                .frame(width: 40.ratio())
                Text("%")
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(.MindOrange)
                Text("환불")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
            }
        }
    }
    
    // MARK: - 예약 시 안내사항 (피그마: 제목 + 흰 박스, ZStack 기준 위=내용/아래=글자수)
    private var reservationNoticeSection: some View {
        VStack(alignment: .leading, spacing: 12.ratio()) {
            Text("예약 시 안내사항")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            ZStack(alignment: .topLeading) {
                TextEditor(text: Binding(
                    get: { container.state.reservationNotice },
                    set: { container.handleIntent(.setReservationNotice($0)) }
                ))
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .frame(minHeight: 80.ratio())
                .padding(.horizontal, 20.ratio())
                .padding(.top, 36.ratio())
                .padding(.bottom, 36.ratio())
                .scrollContentBackground(.hidden)
                .background(Color.CleanWhite)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.Background, lineWidth: 1)
                )
                if container.state.reservationNotice.isEmpty {
                    Text("입금이나 환불과 관련하여 추가로 안내할 사항을 입력하세요.")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.Info)
                        .padding(.horizontal, 24.ratio())
                        .padding(.top, 36.ratio())
                        .padding(.leading, 4.ratio())
                        .allowsHitTesting(false)
                }
                VStack {
                    Text("내용")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.Info)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20.ratio())
                        .padding(.top, 12.ratio())
                        .padding(.bottom, 4.ratio())
                    Spacer(minLength: 0)
                    Text("\(container.state.reservationNotice.count) / \(reservationNoticeLimit)")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.Info)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 20.ratio())
                        .padding(.bottom, 12.ratio())
                        .padding(.top, 4.ratio())
                }
                .allowsHitTesting(false)
            }
        }
        .padding(.vertical, 4.ratio())
    }
    
    // MARK: - 미리보기 (피그마: FlowBlue → NatureGreen 그라데이션, 48px, rounded 8)
    private var previewButtonSection: some View {
        Button(action: {
            print("[가격설정] 미리보기 버튼 탭 - 추후 상세 화면 데이터 연동 후 미리보기 팝업 구현 예정")
        }) {
            Text("미리보기")
                .pretendardFont(.semiBold, size: 15)
                .foregroundColor(.DarkBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 48.ratio())
                .background(
                    LinearGradient(
                        colors: [Color.FlowBlue, Color.NatureGreen],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .padding(.vertical, 20.ratio())
    }
    
    // MARK: - 하단 (피그마: 프로그레스 LandBrown 2px, 이전 페이지 / 계속)
    private var bottomNavigation: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.LandBrown)
                .frame(height: 2.ratio())
                .frame(maxWidth: .infinity)
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
                Button(action: completeRegistration) {
                    Text("계속")
                        .pretendardFont(.semiBold, size: 15)
                        .foregroundColor(canComplete ? .DarkBlack : .Info)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48.ratio())
                        .background(canComplete ? Color.GheeYellow : Color.Background)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(!canComplete)
            }
            .padding(.horizontal, 16.ratio())
            .padding(.bottom, 24.ratio())
        }
        .background(Color.SandBeige)
    }
    
    private func completeRegistration() {
        guard !isRegistering else { return }
        isRegistering = true
        registerError = nil
        Task {
            do {
                _ = try await container.registerClass()
                await MainActor.run {
                    isRegistering = false
                    showResultPopup = true
                }
            } catch {
                await MainActor.run {
                    isRegistering = false
                    registerError = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - 정규 수련 금액 플랜 시트 컨텍스트

private enum RegularPlanSheetContext: Identifiable {
    case add
    case edit(RegularPricePlan)
    case copy(RegularPricePlan)

    var id: String {
        switch self {
        case .add:         return "add"
        case .edit(let p): return "edit-\(p.id)"
        case .copy(let p): return "copy-\(p.id)"
        }
    }
}

// MARK: - 정규 수련 금액 플랜 입력 바텀시트

private struct RegularPlanInputSheet: View {
    let context: RegularPlanSheetContext
    let onApply: (RegularPricePlan, String?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var planType: RegularPricePlan.PlanType = .period
    @State private var validMonths = 1
    @State private var weeklyCount = 1
    @State private var totalSessions = 10
    @State private var priceText = ""

    private var replacingId: String? {
        if case .edit(let p) = context { return p.id }
        return nil
    }

    private var price: Int {
        Int(priceText.replacingOccurrences(of: ",", with: "")) ?? 0
    }

    private var canApply: Bool { price > 0 }

    // MARK: - 수강권 이름 자동 생성
    private var generatedTicketName: String {
        switch planType {
        case .period:  return "기간권 \(validMonths)개월"
        case .session: return "회차권 \(totalSessions)회"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.Info)
                .frame(width: 80.ratio(), height: 4.ratio())
                .padding(.top, 16.ratio())
                .padding(.bottom, 12.ratio())

            ScrollView {
                VStack(alignment: .leading, spacing: 20.ratio()) {
                    // 수강권 옵션
                    HStack {
                        Text("수강권 옵션")
                            .pretendardFont(.bold, size: 12)
                            .foregroundColor(.DarkBlack)
                        Spacer()
                        HStack(spacing: 8.ratio()) {
                            planTypeButton(.period)
                            planTypeButton(.session)
                        }
                    }
                    .padding(.horizontal, 16.ratio())

                    Rectangle()
                        .fill(Color.Background)
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)

                    // 입력 필드
                    VStack(spacing: 12.ratio()) {
                        if planType == .period {
                            numberFieldRow(label: "기간 입력", value: $validMonths,    unit: "개월")
                            numberFieldRow(label: "주 횟수",  value: $weeklyCount,    unit: "회")
                        } else {
                            numberFieldRow(label: "회차 입력", value: $totalSessions, unit: "회")
                        }
                        priceFieldRow(label: "기본가", text: $priceText, unit: "원")
                        if planType == .session {
                            numberFieldRow(label: "유효기간 입력", value: $validMonths, unit: "개월")
                        }
                    }
                    .padding(.horizontal, 16.ratio())

                    Spacer(minLength: 120)
                }
            }
            .scrollDismissesKeyboard(.immediately)

            // 적용 버튼
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.Background)
                    .frame(height: 1)
                Button(action: applyPlan) {
                    Text("적용")
                        .pretendardFont(.semiBold, size: 15)
                        .foregroundColor(canApply ? .DarkBlack : .Info)
                        .frame(width: 208.ratio(), height: 48.ratio())
                        .background(
                            RoundedRectangle(cornerRadius: 79)
                                .fill(canApply ? Color.GheeYellow : Color.Background)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!canApply)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(16.ratio())
            }
            .background(Color.CleanWhite)
        }
        .background(Color.CleanWhite)
        .presentationDetents([.fraction(0.65), .large])
        .presentationDragIndicator(.hidden)
        .onAppear(perform: loadContext)
    }

    private func planTypeButton(_ type: RegularPricePlan.PlanType) -> some View {
        let isSelected = planType == type
        let activeColor: Color = type == .period ? .FlowBlue : .NatureGreen
        return Button { planType = type } label: {
            Text(type == .period ? "기간권" : "회차권")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .padding(.horizontal, 12.ratio())
                .frame(height: 32.ratio())
                .background(isSelected ? activeColor : Color.Background)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func numberFieldRow(label: String, value: Binding<Int>, unit: String) -> some View {
        HStack {
            Text(label)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
            Spacer()
            HStack(spacing: 8.ratio()) {
                TextField("0", value: value, format: .number)
                    .keyboardType(.numberPad)
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(.DarkBlack)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 48.ratio())
                Text(unit)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
            }
        }
        .padding(.horizontal, 16.ratio())
        .frame(height: 49.ratio())
        .background(Color.CleanWhite)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.Background, lineWidth: 1))
    }

    @ViewBuilder
    private func priceFieldRow(label: String, text: Binding<String>, unit: String) -> some View {
        HStack {
            Text(label)
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
            Spacer()
            HStack(spacing: 8.ratio()) {
                TextField("0", text: text)
                    .keyboardType(.numberPad)
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(.DarkBlack)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 88.ratio())
                Text(unit)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
            }
        }
        .padding(.horizontal, 16.ratio())
        .frame(height: 49.ratio())
        .background(Color.CleanWhite)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.Background, lineWidth: 1))
    }

    private func loadContext() {
        let source: RegularPricePlan?
        switch context {
        case .add:         source = nil
        case .edit(let p): source = p
        case .copy(let p): source = p
        }
        guard let p = source else { return }
        planType      = p.planType
        validMonths   = p.validMonths
        weeklyCount   = p.weeklyCount
        totalSessions = p.totalSessions
        priceText     = p.price > 0 ? "\(p.price)" : ""
    }

    private func applyPlan() {
        let plan = RegularPricePlan(
            planType:      planType,
            ticketName:    generatedTicketName,
            price:         price,
            validMonths:   validMonths,
            weeklyCount:   weeklyCount,
            totalSessions: totalSessions
        )
        onApply(plan, replacingId)
    }
}

// MARK: - 클래스 등록 완료 풀페이지 팝업 (피그마 2987-15994)
private struct ClassRegisterResultPopupView: View {
    @Environment(\.classRegisterPopToRoot) private var popToRoot
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            VStack(spacing: 0) {
                Text("나마스떼 🙏")
                    .pretendardFont(.bold, size: 20)
                    .foregroundColor(.DarkBlack)
                    .frame(maxWidth: .infinity)
                
                (Text("수련 등록이 ").foregroundColor(.DarkBlack)
                 + Text("완료").foregroundColor(.MindOrange)
                 + Text("되었어요.").foregroundColor(.DarkBlack))
                    .pretendardFont(.bold, size: 20)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            Spacer(minLength: 0)
            Button(action: {
                popToRoot?()
                onDismiss()
            }) {
                Text("완료")
                    .pretendardFont(.semiBold, size: 15)
                    .foregroundColor(.DarkBlack)
                    .frame(width: 208.ratio())
                    .frame(height: 48.ratio())
                    .background(Color.GheeYellow)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.bottom, 24.ratio())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
    }
}

#Preview {
    NavigationStack {
        OnedayClassSetPriceView(container: ClassRegisterContainer())
    }
}
