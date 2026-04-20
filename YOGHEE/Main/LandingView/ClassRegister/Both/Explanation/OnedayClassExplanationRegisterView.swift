//
//  OnedayClassExplanationRegisterView.swift
//  YOGHEE
//
//  Created by 0ofKim on 2/21/26.
//

import SwiftUI

struct OnedayClassExplanationRegisterView: View {
    @ObservedObject var container: ClassRegisterContainer
    @Environment(\.dismiss) private var dismiss
    
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
                // 제목 입력 (원데이)
                TextField("", text: Binding(
                    get: { container.state.name },
                    set: {
                        let name = String($0.prefix(22))
                        container.handleIntent(.updateExplanation(name: name, description: container.state.description))
                    }
                ))
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .padding(12.ratio())
                .frame(minHeight: 112.ratio())
                .background(Color.CleanWhite)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.Background, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if container.state.name.isEmpty {
                        Text("대표 제목 (상세페이지 최상단에 노출돼요!)\n\n수련 테마를 한줄로 표현해주세요.")
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.Info)
                            .padding(12.ratio())
                            .allowsHitTesting(false)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    Text("\(container.state.name.count) / 22")
                        .pretendardFont(.regular, size: 12)
                        .foregroundColor(.Info)
                        .padding(12.ratio())
                        .allowsHitTesting(false)
                }
            }
            
            // 내용 입력
            TextEditor(text: Binding(
                get: { container.state.description },
                set: {
                    let description = String($0.prefix(3000))
                    container.handleIntent(.updateExplanation(name: container.state.name, description: description))
                }
            ))
            .pretendardFont(.medium, size: 12)
            .foregroundColor(.DarkBlack)
            .padding(12.ratio())
            .frame(minHeight: 112.ratio())
            .scrollContentBackground(.hidden)
            .background(Color.CleanWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                if container.state.description.isEmpty {
                    Text("내용\n\n수련 관련 내용을 작성해주세요.")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.Info)
                        .padding(12.ratio())
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: .bottomLeading) {
                Text("\(container.state.description.count) / 3000")
                    .pretendardFont(.regular, size: 12)
                    .foregroundColor(.Info)
                    .padding(12.ratio())
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
