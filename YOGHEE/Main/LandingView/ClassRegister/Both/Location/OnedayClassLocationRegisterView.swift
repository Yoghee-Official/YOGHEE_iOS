//
//  OnedayClassLocationRegisterView.swift
//  YOGHEE
//
//  클래스 생성_수련 장소 등록 화면 (COC_MO_4)
//

import SwiftUI

struct OnedayClassLocationRegisterView: View {
    @ObservedObject var container: ClassRegisterContainer
    @Environment(\.dismiss) private var dismiss
    
    @State private var showNewPlaceSheet = false
    
    private var isRegularStudioFlow: Bool {
        container.state.selectedClassTypeId == "regular"
    }
    
    /// 원데이 6단계 / 정규 7단계
    private var totalSteps: Int { isRegularStudioFlow ? 7 : 6 }
    /// 원데이: 장소=4 / 정규: 장소=2
    private var currentStep: Int { isRegularStudioFlow ? 2 : 4 }
    
    /// 2b에서 요가원 1개 선택 시 활성화
    private var canProceed: Bool {
        container.state.selectedCenterId != nil
    }
    
    private func openNewPlaceRegister() {
        showNewPlaceSheet = true
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 2a: 장소 등록하기
                    locationRegisterSection
                    
                    // 2b: 요가원 불러오기
                    loadYogaStudioSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16.ratio())
                .padding(.top, 24.ratio())
            }
            
            // 3: 하단 네비게이션 (프로그레스 + 이전페이지/계속)
            bottomNavigation
        }
        .background(Color.SandBeige)
        .customNavigationBar(
            title: "수련 장소 등록",
            trailingTitle: "문의하기",
            onTrailingTap: { handleInquiryTap() }
        )
        .onAppear {
            container.loadCenterList()
        }
        .fullScreenCover(isPresented: $showNewPlaceSheet) {
            NewPlaceRegisterView(container: container, onDismiss: { showNewPlaceSheet = false })
        }
    }
    
    private func handleInquiryTap() {
        // TODO: 문의하기 채널(웹/카카오 등) 연결
    }
    
    // MARK: - 2a: 장소 등록하기
    private var locationRegisterSection: some View {
        VStack(alignment: .leading, spacing: 16.ratio()) {
            ClassRegisterSectionHeader(title: "장소 등록하기")
            Button(action: openNewPlaceRegister) {
                ClassRegisterOutlinedCard {
                    VStack(alignment: .leading, spacing: 8.ratio()) {
                        Text("수련 장소 추가")
                            .pretendardFont(.bold, size: 14)
                            .foregroundColor(.DarkBlack)
                        Text("등록하신 수련 장소가 없나요?\n새 요가원을 등록 해주세요.")
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.Info)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 32.ratio())
    }
    
    // MARK: - 2b: 요가원 불러오기
    private var loadYogaStudioSection: some View {
        VStack(alignment: .leading, spacing: 16.ratio()) {
            ClassRegisterSectionHeader(title: "요가원 불러오기")
            if container.state.isLoadingCenters {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 24.ratio())
            } else if let error = container.state.centersError {
                Text(error)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
                    .padding(.vertical, 16.ratio())
            } else if container.state.centers.isEmpty {
                Button(action: openNewPlaceRegister) {
                    ClassRegisterOutlinedCard {
                        VStack(alignment: .leading, spacing: 8.ratio()) {
                            Text("등록된 수련장소 없음")
                                .pretendardFont(.medium, size: 14)
                                .foregroundColor(.Info)
                            Text("수련 장소 등록 바로가기")
                                .pretendardFont(.medium, size: 12)
                                .foregroundColor(.MindOrange)
                        }
                    }
                }
                .buttonStyle(.plain)
            } else {
                VStack(spacing: 12.ratio()) {
                    ForEach(container.state.centers) { center in
                        CenterCardView(
                            center: center,
                            isSelected: container.state.selectedCenterId == center.centerId,
                            onTap: {
                                let nextId = container.state.selectedCenterId == center.centerId ? nil : center.centerId
                                container.handleIntent(.selectCenter(nextId))
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
                    OnedayClassImageRegisterView(container: container)
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
}

// MARK: - 요가원 카드 (선택 시 MindOrange 테두리)
private struct CenterCardView: View {
    let center: CenterBaseDTO
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8.ratio()) {
                Text(center.name)
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(isSelected ? .MindOrange : .DarkBlack)
                Rectangle()
                    .fill(Color.Background)
                    .frame(height: 1)
                Text(center.address)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16.ratio())
            .background(Color.CleanWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.MindOrange : Color.Background, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        OnedayClassLocationRegisterView(container: ClassRegisterContainer())
    }
}
