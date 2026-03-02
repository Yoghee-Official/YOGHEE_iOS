//
//  OnedayClassSelectTypeRegisterView.swift
//  YOGHEE
//
//  Created by 0ofKim on 3/2/26.
//

import SwiftUI

struct OnedayClassSelectTypeRegisterView: View {
    @ObservedObject var container: ClassRegisterContainer
    @Environment(\.dismiss) private var dismiss
    
    private let totalSteps = 6
    private let currentStep = 2
    
    /// 2a, 2b, 2c 중 단 1개라도 선택되면 활성화
    private var canProceed: Bool {
        !container.state.typeIds.isEmpty &&
        !container.state.categoryIds.isEmpty &&
        !container.state.targetIds.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 2a: 전문 수련 유형
                    typeSection
                    
                    // 2b: 수련 카테고리
                    categorySection
                    
                    // 2c: 이용 대상
                    targetSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16.ratio())
                .padding(.top, 24.ratio())
            }
            
            // 3: 하단 네비게이션 (프로그레스 + 이전페이지/계속)
            bottomNavigation
        }
        .background(Color.SandBeige)
        .customNavigationBar(title: "유형 선택")
        .onAppear {
            if container.state.types.isEmpty && container.state.categories.isEmpty && container.state.targets.isEmpty {
                container.loadCodeList()
            }
        }
    }
    
    // MARK: - 2a: 전문 수련 유형
    private var typeSection: some View {
        selectionSection(
            title: "전문 수련 유형",
            description: "상세페이지에 노출되는 수련 유형이에요.",
            items: container.state.types,
            selectedIds: container.state.typeIds,
            onToggle: { container.handleIntent(.toggleType($0)) }
        )
        .padding(.bottom, 32.ratio())
    }
    
    // MARK: - 2b: 수련 카테고리
    private var categorySection: some View {
        selectionSection(
            title: "수련 카테고리",
            description: "수련 카테고리에 목록별로 노출돼요!",
            items: container.state.categories,
            selectedIds: container.state.categoryIds,
            onToggle: { container.handleIntent(.toggleCategory($0)) }
        )
        .padding(.bottom, 32.ratio())
    }
    
    // MARK: - 2c: 이용 대상
    private var targetSection: some View {
        selectionSection(
            title: "이용 대상",
            description: "참여 가능한 대상과 운영 조건을 선택해주세요.",
            items: container.state.targets,
            selectedIds: container.state.targetIds,
            onToggle: { container.handleIntent(.toggleTarget($0)) }
        )
        .padding(.bottom, 32.ratio())
    }
    
    // MARK: - 공통 선택 섹션
    private func selectionSection(
        title: String,
        description: String,
        items: [CodeInfoDTO],
        selectedIds: Set<String>,
        onToggle: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 16.ratio()) {
            Text(title)
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            
            Text(description)
                .pretendardFont(.bold, size: 10)
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
                FlowLayout(spacing: 8.ratio()) {
                    ForEach(items) { item in
                        TypeChipView(
                            title: item.name,
                            isSelected: selectedIds.contains(item.id),
                            onTap: { onToggle(item.id) }
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

// MARK: - Type Chip View (피그마: rounded pill, 선택 시 NatureGreen)
private struct TypeChipView: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text("+ \(title)")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.DarkBlack)
                .padding(.horizontal, 12.ratio())
                .padding(.vertical, 8.ratio())
                .background(isSelected ? Color.NatureGreen : Color.Background)
                .cornerRadius(32)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout (칩 래핑)
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        let totalHeight = currentY + lineHeight
        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

#Preview {
    NavigationStack {
        OnedayClassSelectTypeRegisterView(container: ClassRegisterContainer())
    }
}
