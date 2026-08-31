//
//  OnedayClassExplanationRegisterView.swift
//  YOGHEE
//
//  Created by 0ofKim on 2/21/26.
//

import SwiftUI
import SwiftUIIntrospect

struct OnedayClassExplanationRegisterView: View {
    @ObservedObject var container: ClassRegisterContainer
    @Environment(\.dismiss) private var dismiss

    /// "내용" TextEditor가 UITextView.sizeThatFits로 실측한 텍스트 컨텐츠 높이(줄바꿈 반영, 상하 여백 제외)
    @State private var descriptionContentHeight: CGFloat = 0

    /// 원데이 6단계 / 정규 7단계
    private var totalSteps: Int { isRegularStudioFlow ? 7 : 6 }
    private let currentStep = 1
    
    private var isRegularStudioFlow: Bool {
        container.state.selectedClassTypeId == "regular"
    }
    
    private var canProceed: Bool {
        let descOK = !container.state.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if isRegularStudioFlow {
            return descOK
        }
        return !container.state.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && descOK
    }
    
    private var navigationTitle: String {
        isRegularStudioFlow ? "요가원 설명" : "수련 설명"
    }
    
    private var explanationHeadline: String {
        isRegularStudioFlow
            ? "어떤 수업을 하는 요가원인지 알려주세요."
            : "수련에 대해 알려주세요."
    }
    
    private var featureSelectionHint: String {
        isRegularStudioFlow
            ? "최대 3개까지 자유롭게 선택 가능합니다."
            : "최대 3개까지 선택 가능합니다."
    }

    // MARK: - "제목"/"내용" 입력 박스 공통 스펙 (피그마 COC_MO_1 Frame 2085674830/2085674831 기준)
    /// 박스 좌우 여백
    private var inputBoxHorizontalPadding: CGFloat { 20.ratio() }
    /// 고정 라벨("대표 제목"/"내용") 상단 여백
    private var inputBoxLabelTopPadding: CGFloat { 20.ratio() }
    /// 본문(placeholder/입력값) 시작 top 여백 = 라벨 높이(14) + 라벨-본문 간격(12) + 상단 마진(20).
    /// 아래쪽도 글자수 카운터를 온전히 담으려면 이와 대칭으로 같은 값이 필요함(46).
    private var inputBoxContentTopPadding: CGFloat { 46.ratio() }
    /// 글자수 카운터 하단 여백
    private var inputBoxCounterBottomPadding: CGFloat { 20.ratio() }
    /// 박스 기본(최소) 높이 = 상단(46) + 본문 1줄(14) + 하단(46)
    private var inputBoxMinHeight: CGFloat { 106.ratio() }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 2a: 수련 상세 설명
                    explanationSection
                    
                    // 2b: 수련 장점 (어디에 도움되는 수업인지)
                    featureSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16.ratio())
                .padding(.top, 24.ratio())
            }
            .scrollDismissesKeyboard(.immediately)
            
            // 3: 하단 네비게이션 (프로그레스 + 이전페이지/계속)
            bottomNavigation
        }
        .background(Color.SandBeige)
        .customNavigationBar(
            title: navigationTitle,
            trailingTitle: isRegularStudioFlow ? "문의하기" : nil,
            onTrailingTap: isRegularStudioFlow ? { handleInquiryTap() } : nil
        )
        .onAppear {
            container.loadCodeList()
        }
    }
    
    // MARK: - 2a: 수련 상세 설명
    private var explanationSection: some View {
        VStack(alignment: .leading, spacing: 16.ratio()) {
            Text(explanationHeadline)
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            
            VStack(alignment: .leading, spacing: 4.ratio()) {
                Text("[마이페이지] → [개설 수련 목록] 에서 수정할 수 있습니다.")
                    .pretendardFont(.bold, size: 10)
                    .foregroundColor(.Info)
                if isRegularStudioFlow {
                    Text("제목은 [요가원명]으로 노출됩니다.")
                        .pretendardFont(.bold, size: 10)
                        .foregroundColor(.Info)
                }
            }
            
            if !isRegularStudioFlow {
                // 제목 입력 (원데이, 피그마 COC_MO_1 Frame 2085674830 기준: 좌측 20 / 라벨 top 20 / 입력 시작 top 46 / 박스 h 106)
                TextField("", text: Binding(
                    get: { container.state.name },
                    set: {
                        let name = String($0.prefix(22))
                        container.handleIntent(.updateExplanation(name: name, description: container.state.description))
                    }
                ))
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .padding(.horizontal, inputBoxHorizontalPadding)
                .padding(.top, inputBoxContentTopPadding)
                .frame(minHeight: inputBoxMinHeight, alignment: .top)
                .background(Color.CleanWhite)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.Background, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    // 고정 라벨: 입력해도 사라지지 않음
                    Text("대표 제목 (상세페이지 최상단에 노출돼요!)")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.Info)
                        .padding(.horizontal, inputBoxHorizontalPadding)
                        .padding(.top, inputBoxLabelTopPadding)
                        .allowsHitTesting(false)
                }
                .overlay(alignment: .topLeading) {
                    if container.state.name.isEmpty {
                        Text("수련 테마를 한줄로 표현해주세요.")
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.Info)
                            .padding(.horizontal, inputBoxHorizontalPadding)
                            .padding(.top, inputBoxContentTopPadding)
                            .allowsHitTesting(false)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    Text("\(container.state.name.count) / 22")
                        .pretendardFont(.regular, size: 12)
                        .foregroundColor(.Info)
                        .padding(.horizontal, inputBoxHorizontalPadding)
                        .padding(.bottom, inputBoxCounterBottomPadding)
                        .allowsHitTesting(false)
                }
            }

            // 내용 입력 (피그마 COC_MO_1 Frame 2085674831 기준: 좌측 20 / 라벨 top 20 / 입력 시작 top 46 / 박스 h 106, 개행 시 높이 자동 확장)
            // GeometryReader로 실제 사용 가능한 폭을 먼저 확정한 뒤 그 폭 기준으로 sizeThatFits를 계산한다.
            // (introspect 클로저 안에서 textView.bounds.width를 바로 쓰면, 최종 padding이 반영되기 전
            //  더 넓은 임시 폭으로 측정되어 실제보다 한 줄 부족하게 계산되는 타이밍 문제가 있었음)
            GeometryReader { geo in
                let editorContentWidth = max(0, geo.size.width - inputBoxHorizontalPadding * 2)

                TextEditor(text: Binding(
                    get: { container.state.description },
                    set: {
                        let description = String($0.prefix(3000))
                        container.handleIntent(.updateExplanation(name: container.state.name, description: description))
                    }
                ))
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                // TextEditor 내부 UITextView의 기본 textContainerInset/lineFragmentPadding을 제거해
                // 아래 가이드 텍스트(Text overlay)와 실제 입력 글자 시작 위치를 동일하게 맞춤 +
                // UITextView 자신이 TextKit으로 계산한 실제 컨텐츠 높이(sizeThatFits)를 그대로 사용해 박스 높이 갱신
                // (버전 매처는 배포 타깃이 아닌 "실행 중인 OS 버전" 기준이라, 지원 버전을 모두 나열해야 실기기/시뮬레이터 어디서든 적용됨)
                .introspect(.textEditor, on: .iOS(.v14, .v15, .v16, .v17, .v18, .v26)) { textView in
                    textView.textContainerInset = .zero
                    textView.textContainer.lineFragmentPadding = 0
                    let fittingHeight = textView.sizeThatFits(
                        CGSize(width: editorContentWidth, height: .greatestFiniteMagnitude)
                    ).height
                    if fittingHeight > 0, abs(descriptionContentHeight - fittingHeight) > 0.5 {
                        DispatchQueue.main.async {
                            descriptionContentHeight = fittingHeight
                        }
                    }
                }
                .padding(.horizontal, inputBoxHorizontalPadding)
                .padding(.top, inputBoxContentTopPadding)
                // 하단도 상단(46 = 라벨 14 + 여백 12 + 상단 마진 20)과 대칭으로 46 확보해야 함.
                // 20만 주면 "글자수 카운터 자신의 높이(14)"를 못 담아서, 내용이 길어질수록
                // 정확히 그 차이(14)만큼 마지막 줄이 카운터 자리를 침범했음 — 이게 겹침의 진짜 원인.
                .padding(.bottom, inputBoxContentTopPadding)
                .scrollContentBackground(.hidden)
            }
            // 박스 전체 높이도 위와 동일하게 상하 대칭으로 확보 (46 + 내용 높이 + 46, 피그마 106 = 46+14+46과 일치)
            .frame(height: max(inputBoxMinHeight, inputBoxContentTopPadding * 2 + descriptionContentHeight))
            .background(Color.CleanWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                // 고정 라벨: 입력해도 사라지지 않음
                Text("내용")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
                    .padding(.horizontal, inputBoxHorizontalPadding)
                    .padding(.top, inputBoxLabelTopPadding)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .topLeading) {
                if container.state.description.isEmpty {
                    Text("수련 관련 내용을 작성해주세요.")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.Info)
                        .padding(.horizontal, inputBoxHorizontalPadding)
                        .padding(.top, inputBoxContentTopPadding)
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: .bottomLeading) {
                Text("\(container.state.description.count) / 3000")
                    .pretendardFont(.regular, size: 12)
                    .foregroundColor(.Info)
                    .padding(.horizontal, inputBoxHorizontalPadding)
                    .padding(.bottom, inputBoxCounterBottomPadding)
                    .allowsHitTesting(false)
            }
        }
        .padding(.bottom, 32.ratio())
    }
    
    // MARK: - 2b: 수련 장점 (어디에 도움되는 수업인지)
    private var featureSection: some View {
        VStack(alignment: .leading, spacing: 16.ratio()) {
            Text("어디에 도움되는 수업인가요?")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            
            Text(featureSelectionHint)
                .pretendardFont(.regular, size: 12)
                .foregroundColor(.Info)
            
            if container.state.isLoadingCodeList {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 24.ratio())
            } else if let error = container.state.codeListError {
                Text("목록을 불러오지 못했습니다: \(error)")
                    .pretendardFont(.regular, size: 12)
                    .foregroundColor(.red)
                    .padding(.vertical, 16.ratio())
            } else {
                VStack(alignment: .leading, spacing: 8.ratio()) {
                    ForEach(container.state.features) { feature in
                        FeatureChipView(
                            feature: feature,
                            isSelected: container.state.featureIds.contains(feature.id),
                            onTap: {
                                container.handleIntent(.toggleFeature(feature.id))
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - 3: 하단 네비게이션
    private var bottomNavigation: some View {
        VStack(spacing: 0) {
            // 프로그레스 인디케이터
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
            
            // 이전페이지 / 계속 버튼
            HStack(spacing: 12.ratio()) {
                Button(action: {
                    dismiss()
                }) {
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
                    Group {
                        if isRegularStudioFlow {
                            OnedayClassLocationRegisterView(container: container)
                        } else {
                            OnedayClassSelectTypeRegisterView(container: container)
                        }
                    }
                } label: {
                    Text("계속")
                        .pretendardFont(.medium, size: 15)
                        .foregroundColor(canProceed ? .CleanWhite : .Info)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48.ratio())
                        .background(canProceed ? Color.DarkBlack : Color.Background)
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

// MARK: - Feature Chip View
private struct FeatureChipView: View {
    let feature: CodeInfoDTO
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8.ratio()) {
                Image(isSelected ? "StarCheckIcon" : "StarCheckIconEmpty")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20.ratio(), height: 20.ratio())
                
                Text(feature.name)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.leading, 8.ratio())
            .padding(.trailing, 12.ratio())
            .padding(.vertical, 4.ratio())
            .frame(minHeight: 28.ratio(), alignment: .leading)
            .background(Color.CleanWhite)
            .cornerRadius(23.ratio())
            .overlay(
                RoundedRectangle(cornerRadius: 23.ratio())
                    .stroke(Color.Background, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    NavigationStack {
        OnedayClassExplanationRegisterView(container: ClassRegisterContainer())
    }
}
