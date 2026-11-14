//
//  WithdrawalView.swift
//  YOGHEE
//
//  회원 탈퇴(DA_MO_1) - 서비스 불편 사항 선택 및 탈퇴
//  - 1a 뒤로가기: 탈퇴 사유 저장되지 않으며 회원정보관리로 이동
//  - 2a 탈퇴 사유: 선택 시 체크, 재선택 시 해제, 최대 3개
//  - 2b 기타 내용: 작성 시 기타 자동 선택, 1줄 노출
//  - 3a 회원탈퇴 하기: A11 얼럿 → 확인 시 회원 정보 삭제 후 로그인 화면 노출
//

import SwiftUI

struct WithdrawalView: View {
    @StateObject private var container: WithdrawalContainer
    @FocusState private var isDetailFocused: Bool

    init(onWithdrawalCompleted: @escaping () -> Void) {
        _container = StateObject(wrappedValue: WithdrawalContainer(onWithdrawalCompleted: onWithdrawalCompleted))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    sectionTitle("탈퇴 사유")
                        .padding(.top, 20)

                    reasonCard
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    sectionTitle("기타 내용")
                        .padding(.top, 30)

                    detailCard
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)

            withdrawButton
        }
        .background(
            Color.SandBeige
                .ignoresSafeArea()
                .onTapGesture { isDetailFocused = false }
        )
        .customNavigationBar(title: "회원탈퇴")
        .overlay {
            if container.state.isSubmitting {
                LoadingView()
                    .background(Color.black.opacity(0.001))
            }
        }
        .overlay { alerts }
    }

    // MARK: - 2a 탈퇴 사유

    private var reasonCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(WithdrawalReasonType.allCases, id: \.self) { reason in
                Button {
                    container.handleIntent(.toggleReason(reason))
                } label: {
                    HStack(spacing: 12) {
                        Image(container.state.isSelected(reason) ? "CheckCircleIconFull" : "CheckCircleIconEmpty")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text(reason.title)
                            .pretendardFont(.bold, size: 12)
                            .tracking(-0.408)
                            .foregroundColor(.DarkBlack)
                            .lineLimit(1)
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    // MARK: - 2b 기타 내용

    private var detailCard: some View {
        TextField(
            "",
            text: Binding(
                get: { container.state.detail },
                set: { container.handleIntent(.updateDetail($0)) }
            ),
            prompt: Text("자유롭게 작성 부탁드립니다. 피드백도 환영이에요.")
                .foregroundColor(.Info)
        )
        .pretendardFont(.medium, size: 12)
        .tracking(-0.408)
        .foregroundColor(.DarkBlack)
        .lineLimit(1)
        .submitLabel(.done)
        .focused($isDetailFocused)
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .contentShape(Rectangle())
        .onTapGesture { isDetailFocused = true }
    }

    // MARK: - 3a 회원탈퇴 하기

    private var withdrawButton: some View {
        Button {
            isDetailFocused = false
            container.handleIntent(.tapWithdraw)
        } label: {
            Text("회원탈퇴 하기")
                .pretendardFont(.bold, size: 14)
                .tracking(-0.408)
                .underline()
                .foregroundColor(.MindOrange)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    // MARK: - Common

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .pretendardFont(.bold, size: 16)
            .tracking(-0.408)
            .foregroundColor(.DarkBlack)
            .padding(.horizontal, 24)
    }

    // MARK: - Alerts

    @ViewBuilder
    private var alerts: some View {
        if container.state.showConfirmAlert {
            // A11: 탈퇴 확인
            MessageBoxAlertView(
                message: "정말 탈퇴 하시겠습니까?",
                confirmTitle: "확인",
                cancelTitle: "닫기",
                onConfirm: { container.handleIntent(.confirmWithdraw) },
                onDismiss: { container.handleIntent(.dismissConfirmAlert) }
            )
        } else if let message = container.state.message {
            MessageBoxAlertView(
                message: message,
                onConfirm: { container.handleIntent(.dismissMessage) },
                onDismiss: { container.handleIntent(.dismissMessage) }
            )
        }
    }
}

private extension View {
    /// 흰 배경 + Background 테두리 카드 (radius 8)
    func cardStyle() -> some View {
        self
            .background(Color.CleanWhite)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        WithdrawalView(onWithdrawalCompleted: {})
    }
}
