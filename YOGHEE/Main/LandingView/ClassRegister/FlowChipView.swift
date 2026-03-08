//
//  FlowChipView.swift
//  YOGHEE
//
//  클래스 등록 플로우 공통: 한 줄 흐름 칩 뷰 + FlowLayout
//

import SwiftUI

// MARK: - Selection Chip View (피그마: rounded pill, 선택 시 NatureGreen #D6F695)

/// 복수 선택 가능한 칩. 선택 시 NatureGreen 배경.
struct SelectionChipView: View {
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

// MARK: - Flow Layout (칩 한 줄 흐름 래핑)

/// 자식 뷰들을 한 줄로 흐르다가 넘치면 다음 줄로 배치하는 레이아웃
struct FlowLayout: Layout {
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
