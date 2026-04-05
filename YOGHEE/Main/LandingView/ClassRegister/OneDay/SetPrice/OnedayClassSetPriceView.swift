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
    
    private var isRegularStudioFlow: Bool {
        container.state.selectedClassTypeId == "regular"
    }
    
    /// 원데이 6단계 / 정규 7단계
    private var totalSteps: Int { isRegularStudioFlow ? 7 : 6 }
    private var currentStep: Int { isRegularStudioFlow ? 7 : 6 }
    private let reservationNoticeLimit = 3000
    
    private var canComplete: Bool {
        let price = container.state.pricePerSession.trimmingCharacters(in: .whitespacesAndNewlines)
        return !price.isEmpty && (Int(price.replacingOccurrences(of: ",", with: "")) ?? 0) >= 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 피그마: 1회 수업 / 35,000원 한 줄
                    priceRowSection
                    divider
                    // 할인방식: 정률(선택 시 Mind Orange) / 정액, 할인률·할인액 행
                    discountSection
                    divider
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
        .customNavigationBar(title: "금액 설정")
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
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.Background)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20.ratio())
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
                    Text("이전 페이지")
                        .pretendardFont(.bold, size: 10)
                        .foregroundColor(.Info)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48.ratio())
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
