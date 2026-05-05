//
//  ContentTabView.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/23/25.
//

import SwiftUI

struct ContentTabView: View {
    @StateObject private var container = ContentTabContainer()
    @State private var currentIndex: Int = 0
    
    private let horizontalPadding: CGFloat = 16
    private let imageHeight: CGFloat = 440

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                contentBody
                    .padding(.top, 15)
            }
            .background(
                LinearGradient(
                    colors: [.FlowBlue, .SandBeige],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .onChange(of: container.state.items) { _ in
            currentIndex = 0
        }
    }

    // MARK: - Header
    private var headerView: some View {
        Text("눈요기 콘텐츠")
            .pretendardFont(.bold, size: 20)
            .foregroundColor(.DarkBlack)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.FlowBlue)
    }

    // MARK: - Body
    @ViewBuilder
    private var contentBody: some View {
        if container.state.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 300)
        } else if let error = container.state.errorMessage {
            VStack(spacing: 16) {
                Text("오류가 발생했습니다")
                    .pretendardFont(.semiBold, size: 17)
                Text(error)
                    .pretendardFont(.regular, size: 12)
                    .foregroundColor(.Info)
                    .multilineTextAlignment(.center)
                Button("다시 시도") {
                    container.handleIntent(.loadFeed)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 300)
        } else if container.state.isEmpty {
            Text("이번 주 등록된 피드가 없습니다.")
                .pretendardFont(.regular, size: 15)
                .foregroundColor(.Info)
                .frame(maxWidth: .infinity, minHeight: 300)
        } else if container.state.items.isEmpty {
            Text("이번 주 등록된 피드가 없습니다.")
                .pretendardFont(.regular, size: 15)
                .foregroundColor(.Info)
                .frame(maxWidth: .infinity, minHeight: 300)
        } else {
            GeometryReader { proxy in
                let imageWidth = min(proxy.size.width - (horizontalPadding * 2), 343)
                feedCard(imageWidth: imageWidth)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    // MARK: - Feed Card
    private func feedCard(imageWidth: CGFloat) -> some View {
        let items = container.state.items
        return ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                imageSlider(items: items, imageWidth: imageWidth)
                textSection(items: items)
                    .padding(.horizontal, horizontalPadding)
            }
            .padding(.bottom, 32)
        }
    }

    // MARK: - Image Slider
    private func imageSlider(items: [FeedItemDTO], imageWidth: CGFloat) -> some View {
        ZStack {
            TabView(selection: $currentIndex) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    AsyncImage(url: URL(string: item.imageUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure:
                            Color.Background
                        case .empty:
                            Color.Background.overlay(ProgressView())
                        @unknown default:
                            Color.Background
                        }
                    }
                    .frame(width: imageWidth, height: imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: imageHeight)
            .frame(maxWidth: .infinity)
            
            if items.count > 1 {
                HStack {
                    if currentIndex > 0 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                currentIndex -= 1
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.CleanWhite)
                                .frame(width: 36, height: 36)
                                .background(Color.DarkBlack.opacity(0.7))
                                .clipShape(Circle())
                        }
                    }

                    Spacer()

                    if currentIndex < items.count - 1 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                currentIndex += 1
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.CleanWhite)
                                .frame(width: 36, height: 36)
                                .background(Color.DarkBlack.opacity(0.7))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding + 12)
            }
        }
    }

    // MARK: - Text Section
    private func textSection(items: [FeedItemDTO]) -> some View {
        let safeIndex = min(currentIndex, max(items.count - 1, 0))
        let item = items[safeIndex]
        return HStack(alignment: .top, spacing: 12) {
            Text(container.state.weekLabel)
                .pretendardFont(.bold, size: 12)
                .foregroundColor(.DarkBlack)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.DarkBlack, lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 12) {
                if let title = item.title, !title.isEmpty {
                    Text(title)
                        .pretendardFont(.bold, size: 16)
                        .foregroundColor(.DarkBlack)
                        .lineLimit(2)
                }
                
                if let description = item.description, !description.isEmpty {
                    Text(description)
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                        .lineSpacing(3)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentTabView()
}
