//
//  RecommendClassModuleView.swift
//  YOGHEE
//
//  Created by 0ofKim on 10/19/25.
//

import SwiftUI
import UIKit

struct RecommendClassModuleView: View {
    let items: [any HomeSectionItem]
    let onItemTap: (String) -> Void
    
    private var displayItems: [any HomeSectionItem] {
        Array(items.prefix(5))
    }
    
    private let cardWidth: CGFloat = 343.ratio()
    private let cardHeight: CGFloat = 250.ratio()
    
    var body: some View {
        if displayItems.isEmpty {
            EmptyView()
        } else {
            PagingCarouselView(
                items: displayItems,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                onItemTap: onItemTap
            )
            .frame(height: cardHeight)
        }
    }
}

// MARK: - Paging Carousel View
struct PagingCarouselView: UIViewRepresentable {
    let items: [any HomeSectionItem]
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let onItemTap: (String) -> Void
    
    private let spacing: CGFloat = 12
    private let sideCardPeek: CGFloat = 4
    
    /// 무한 스크롤용 아이템 복사 횟수 (중간 세트에서 시작하기 위해 5)
    private static let infiniteCopyCount = 5
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.clipsToBounds = false
        
        let infiniteItems = (0..<Self.infiniteCopyCount).flatMap { _ in items }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for item in infiniteItems {
            let hosting = UIHostingController(
                rootView: RecommendRankingCardView(item: item, onTap: { onItemTap(item.id) })
                    .frame(width: cardWidth, height: cardHeight)
            )
            guard let cardView = hosting.view else { continue }
            cardView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cardView.widthAnchor.constraint(equalToConstant: cardWidth),
                cardView.heightAnchor.constraint(equalToConstant: cardHeight)
            ])
            stackView.addArrangedSubview(cardView)
        }
        
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        context.coordinator.scrollView = scrollView
        context.coordinator.itemCount = items.count
        context.coordinator.cardWidth = cardWidth
        context.coordinator.spacing = spacing
        context.coordinator.sideCardPeek = sideCardPeek
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        if context.coordinator.needsInitialScroll {
            DispatchQueue.main.async {
                let leadingPadding = (uiView.frame.width - cardWidth) / 2 - sideCardPeek
                let cardTotalWidth = cardWidth + spacing
                let middleSetOffset = CGFloat(items.count * Self.middleSetIndex) * cardTotalWidth - leadingPadding
                uiView.contentInset = UIEdgeInsets(top: 0, left: leadingPadding, bottom: 0, right: leadingPadding + sideCardPeek * 2)
                uiView.setContentOffset(CGPoint(x: middleSetOffset, y: 0), animated: false)
                context.coordinator.needsInitialScroll = false
            }
        }
    }
    
    /// 5배 복사 시 중간 세트 인덱스 (0-based: 2 = 3번째 세트)
    private static var middleSetIndex: Int { infiniteCopyCount / 2 }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: PagingCarouselView
        var scrollView: UIScrollView?
        var itemCount: Int = 0
        var cardWidth: CGFloat = 0
        var spacing: CGFloat = 0
        var sideCardPeek: CGFloat = 0
        var needsInitialScroll = true
        
        /// 카드 너비 + 간격 (스냅/무한스크롤 계산에 공통 사용)
        private var cardTotalWidth: CGFloat { cardWidth + spacing }
        
        /// 무한 스크롤 세트 인덱스 경계 (2세트 미만 / 4세트 이상 시 리셋)
        private var lowerSetBound: Int { itemCount * 2 }
        private var upperSetBound: Int { itemCount * 3 }
        
        init(_ parent: PagingCarouselView) {
            self.parent = parent
        }
        
        private func currentX(from scrollView: UIScrollView) -> CGFloat {
            scrollView.contentOffset.x + scrollView.contentInset.left
        }
        
        private func currentIndex(from scrollView: UIScrollView) -> Int {
            Int(round(currentX(from: scrollView) / cardTotalWidth))
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            let currentIdx = CGFloat(currentIndex(from: scrollView))
            let targetX = targetContentOffset.pointee.x + scrollView.contentInset.left
            let proposedIdx = round(targetX / cardTotalWidth)
            
            var targetIndex = currentIdx
            if proposedIdx > currentIdx {
                targetIndex = currentIdx + 1
            } else if proposedIdx < currentIdx {
                targetIndex = currentIdx - 1
            }
            
            let snappedX = targetIndex * cardTotalWidth - scrollView.contentInset.left
            targetContentOffset.pointee.x = snappedX
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            checkInfiniteScroll(scrollView)
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                checkInfiniteScroll(scrollView)
            }
        }
        
        private func checkInfiniteScroll(_ scrollView: UIScrollView) {
            let currentIdx = currentIndex(from: scrollView)
            let currentX = currentX(from: scrollView)
            let insetLeft = scrollView.contentInset.left
            
            if currentIdx < lowerSetBound {
                let newOffset = currentX + CGFloat(itemCount) * cardTotalWidth - insetLeft
                scrollView.setContentOffset(CGPoint(x: newOffset, y: 0), animated: false)
            } else if currentIdx >= upperSetBound {
                let newOffset = currentX - CGFloat(itemCount) * cardTotalWidth - insetLeft
                scrollView.setContentOffset(CGPoint(x: newOffset, y: 0), animated: false)
            }
        }
    }
}

// MARK: - Recommend Class Card View
struct RecommendRankingCardView: View {
    let item: any HomeSectionItem
    let onTap: () -> Void
    
    /// 배너 배경 컬러 팔레트
    private static let backgroundColors: [Color] = [
        Color(red: 0.85, green: 0.96, blue: 0.58), // NatureGreen
        Color(red: 1, green: 0.93, blue: 0.45),    // GheeYellow
        Color(red: 1, green: 0.33, blue: 0.13),    // MindOrange
        Color(red: 0.79, green: 0.88, blue: 0.99), // FlowBlue
        Color(red: 0.37, green: 0.28, blue: 0.21), // LandBrown
        Color(red: 0.94, green: 0.93, blue: 0.92), // Notice
        Color(red: 0.9, green: 0.7, blue: 0.8),    // 추가 컬러 1
        Color(red: 0.7, green: 0.9, blue: 0.8),    // 추가 컬러 2
        Color(red: 0.8, green: 0.8, blue: 0.9)     // 추가 컬러 3
    ]
    
    /// 타이틀 (최대 10자)
    private var displayTitle: String {
        item.title.count > 10 ? String(item.title.prefix(9)) + "…" : item.title
    }
    
    /// 서브타이틀 (최대 20자)
    private var displaySubtitle: String {
        let subtitle = (item as? YogaClass)?.description ?? "YOGHEE 추천 수업"
        return subtitle.count > 20 ? String(subtitle.prefix(19)) + "…" : subtitle
    }
    
    /// ID 기반 배경 컬러
    private var backgroundColor: Color {
        Self.backgroundColors[abs(item.id.hashValue) % Self.backgroundColors.count]
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .top) {
                backgroundColor
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                VStack(spacing: 8) {
                    Text(displayTitle)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.988, green: 0.980, blue: 0.957))
                    
                    Text(displaySubtitle)
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0.988, green: 0.980, blue: 0.957))
                }
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .padding(.horizontal, 16)
            }
        }
        .buttonStyle(.plain)
    }
}
