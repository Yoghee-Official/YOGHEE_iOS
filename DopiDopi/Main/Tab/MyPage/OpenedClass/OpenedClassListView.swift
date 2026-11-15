//
//  OpenedClassListView.swift
//  YOGHEE
//
//  지도자 마이페이지 > 수련 미리보기 "목록 더보기" > 개설한 수련 목록 (OC_MO_1, Figma 3-13748 / 539-17893)
//  요기니는 이 화면이 아니라 내역 보기(RC_MO_1)로 이동
//

import SwiftUI

struct OpenedClassListView: View {
    @StateObject private var container = OpenedClassListContainer()

    private let columns = [
        GridItem(.flexible(), spacing: 8.ratio()),
        GridItem(.flexible(), spacing: 8.ratio())
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 2a / 2b: 카테고리 필터 + 전체/하루수련/정규수련
            filterBar
                .padding(.horizontal, 16.ratio())
                .padding(.top, 16.ratio())

            // 2c: 종료된 수련 숨기기
            hideEndedToggle
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 16.ratio())
                .padding(.top, 18.ratio())
                .padding(.bottom, 16.ratio())

            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.SandBeige)
        .customNavigationBar(title: "개설한 수련 목록")
        .onAppear {
            container.handleIntent(.load)
        }
        .sheet(isPresented: Binding(
            get: { container.state.showCategoryFilter },
            set: { container.handleIntent(.showCategoryFilter($0)) }
        )) {
            OpenedClassCategoryFilterSheet(selectedCodes: container.state.selectedCategoryCodes) {
                container.handleIntent(.applyCategoryFilter($0))
            }
        }
        .overlay {
            if container.state.pendingDelete != nil {
                // Alert_20
                MessageBoxAlertView(
                    message: "수련을 삭제하시겠습니까?",
                    cancelTitle: "닫기",
                    onConfirm: { container.handleIntent(.confirmDelete) },
                    onDismiss: { container.handleIntent(.dismissDelete) }
                )
            } else if let message = container.state.alertMessage {
                MessageBoxAlertView(
                    message: message,
                    onConfirm: { container.handleIntent(.dismissAlert) },
                    onDismiss: { container.handleIntent(.dismissAlert) }
                )
            } else if container.state.isDeleting {
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
            }
        }
    }

    // MARK: - 2a / 2b
    private var filterBar: some View {
        HStack(spacing: 0) {
            Button {
                container.handleIntent(.showCategoryFilter(true))
            } label: {
                HStack(spacing: 4) {
                    Text("카테고리")
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.DarkBlack)
                        .tracking(-0.408)
                    Image("FilterSettingIcon")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                .frame(width: 80, height: 30)
                .background(Color.CleanWhite)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.Background, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer(minLength: 8)

            HStack(spacing: 8.ratio()) {
                ForEach(OpenedClassTab.allCases, id: \.self) { tab in
                    Button {
                        container.handleIntent(.selectTab(tab))
                    } label: {
                        Text(tab.title)
                            .pretendardFont(.medium, size: 12)
                            .foregroundColor(.DarkBlack)
                            .tracking(-0.408)
                            .padding(.horizontal, 12.ratio())
                            .padding(.vertical, 8)
                            .background(container.state.selectedTab == tab ? Color.NatureGreen : Color.Background)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - 2c
    private var hideEndedToggle: some View {
        Button {
            container.handleIntent(.toggleHideEnded)
        } label: {
            HStack(spacing: 6) {
                Text("종료된 수련 숨기기")
                    .pretendardFont(.medium, size: 10)
                    .foregroundColor(.DarkBlack)
                    .tracking(-0.408)
                ZStack {
                    Circle()
                        .fill(Color.Background)
                        .frame(width: 16, height: 16)
                    if container.state.hideEndedClasses {
                        Circle()
                            .fill(Color.MindOrange)
                            .frame(width: 10, height: 10)
                    }
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - 3a ~ 3c: 수련 유닛 목록
    @ViewBuilder
    private var content: some View {
        if container.state.isLoading {
            Spacer()
            LoadingView()
            Spacer()
        } else if let errorMessage = container.state.errorMessage {
            Spacer()
            VStack(spacing: 16) {
                Text(errorMessage)
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.Info)
                    .multilineTextAlignment(.center)
                Button("다시 시도") {
                    container.handleIntent(.load)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 24)
            Spacer()
        } else if container.state.visibleClasses.isEmpty {
            Spacer()
            Text("개설한 수련이 없습니다.")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.Info)
                .tracking(-0.408)
            Spacer()
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8.ratio()) {
                    ForEach(container.state.visibleClasses) { item in
                        let isMenuOpen = container.state.moreMenuClassId == item.classId
                        OpenedClassCardView(
                            item: item,
                            isMoreMenuOpen: isMenuOpen,
                            onMoreTap: { container.handleIntent(.toggleMoreMenu(item.classId)) },
                            onNoticeTap: { container.handleIntent(.sendNotice(item)) },
                            onEdit: { container.handleIntent(.edit(item)) },
                            onCopy: { container.handleIntent(.copy(item)) },
                            onDelete: { container.handleIntent(.requestDelete(item)) }
                        )
                        // 더보기 메뉴가 옆 카드 위로 보이도록
                        .zIndex(isMenuOpen ? 1 : 0)
                    }
                }
                .padding(.horizontal, 16.ratio())
                .padding(.bottom, 40.ratio())
                // 메뉴 바깥을 누르면 닫기
                .contentShape(Rectangle())
                .onTapGesture {
                    if container.state.moreMenuClassId != nil {
                        container.handleIntent(.toggleMoreMenu(nil))
                    }
                }
            }
        }
    }
}

// MARK: - 3a: 수련 유닛
private struct OpenedClassCardView: View {
    let item: LeaderClassDTO
    let isMoreMenuOpen: Bool
    let onMoreTap: () -> Void
    let onNoticeTap: () -> Void
    let onEdit: () -> Void
    let onCopy: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 10.ratio()) {
            thumbnail

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 12) {
                    Text(item.title)
                        .pretendardFont(.bold, size: 14)
                        .foregroundColor(.DarkBlack)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 3c: 더보기
                    Button(action: onMoreTap) {
                        Image("MoreIcon")
                            .resizable()
                            .frame(width: 4, height: 16)
                            .padding(.horizontal, 8)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, -8)
                }
                .overlay(alignment: .topTrailing) {
                    if isMoreMenuOpen {
                        OpenedClassMoreMenu(onEdit: onEdit, onCopy: onCopy, onDelete: onDelete)
                            .offset(x: -12)
                    }
                }
                .zIndex(1)

                if let subtitle = item.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .pretendardFont(.medium, size: 12)
                        .foregroundColor(.Info)
                        .lineLimit(1)
                }

                Text(item.isRegular ? "정규수련" : "하루수련")
                    .pretendardFont(.regular, size: 10)
                    .foregroundColor(.DarkBlack)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.isRegular ? Color.FlowBlue : Color.NatureGreen)
                    .cornerRadius(4)
            }
            .tracking(-0.408)
            .padding(.horizontal, 7.ratio())
            .zIndex(1)

            // 3b: 공지사항 보내기
            Button(action: onNoticeTap) {
                Text("공지사항 보내기")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.white)
                    .tracking(-0.408)
                    .frame(maxWidth: .infinity)
                    .frame(height: 30.ratio())
                    .background(Color.MindOrange)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 4.ratio())
        }
        .padding(8.ratio())
        .background(Color.CleanWhite)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Background, lineWidth: 1)
        )
    }

    private var thumbnail: some View {
        Color.Background
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let urlString = item.thumbnail, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.Background
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .shadow(color: .black.opacity(0.07), radius: 5)
    }
}

// MARK: - 3c: 더보기 메뉴 (수정 / 복사 / 삭제)
private struct OpenedClassMoreMenu: View {
    let onEdit: () -> Void
    let onCopy: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            menuButton("수정", action: onEdit)
            divider
            menuButton("복사", action: onCopy)
            divider
            menuButton("삭제", action: onDelete)
        }
        .padding(12)
        .frame(width: 64)
        .background(Color.CleanWhite)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Background, lineWidth: 1)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.Background)
            .frame(height: 1)
    }

    private func menuButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .pretendardFont(.regular, size: 14)
                .foregroundColor(.DarkBlack)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        OpenedClassListView()
    }
}
