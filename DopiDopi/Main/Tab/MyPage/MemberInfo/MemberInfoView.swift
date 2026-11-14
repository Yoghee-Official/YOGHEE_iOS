//
//  MemberInfoView.swift
//  YOGHEE
//
//  회원정보관리(MI_MO_1) - 마이 탭 > 설정 > 회원 정보 관리
//  - 1a 뒤로가기: 작성 중인 내용 저장 안 됨
//  - 1c 저장하기: 수정한 회원 정보 저장
//  - 2a 개인정보 수정: 이름(텍스트) / 생년월일(숫자) / 이메일(수정 불가) / 휴대폰 번호(숫자)
//  - 3a 회원탈퇴, 3b 로그아웃(A10 얼럿)
//

import SwiftUI

struct MemberInfoView: View {
    @StateObject private var container: MemberInfoContainer
    @FocusState private var focusedField: Field?

    private enum Field {
        case name, birth, phone
    }

    init(
        onLogoutCompleted: @escaping () -> Void,
        onNavigateToWithdrawal: @escaping () -> Void
    ) {
        _container = StateObject(wrappedValue: MemberInfoContainer(
            onLogoutCompleted: onLogoutCompleted,
            onNavigateToWithdrawal: onNavigateToWithdrawal
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("개인정보 수정")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
                .tracking(-0.408)
                .padding(.horizontal, 24)
                .padding(.top, 20)

            infoCard
                .padding(.horizontal, 16)
                .padding(.top, 20)

            Spacer(minLength: 0)

            bottomActions
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            Color.SandBeige
                .ignoresSafeArea()
                .onTapGesture { focusedField = nil }
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .customNavigationBar(
            title: "회원정보관리",
            trailingTitle: "저장하기",
            onTrailingTap: {
                focusedField = nil
                container.handleIntent(.save)
            }
        )
        .overlay {
            if container.state.isLoading || container.state.isSaving || container.state.isProcessing {
                LoadingView()
                    .background(Color.black.opacity(0.001))
            }
        }
        .overlay { alerts }
        .onAppear { container.handleIntent(.load) }
    }

    // MARK: - 2a 개인정보 수정

    private var infoCard: some View {
        VStack(spacing: 20) {
            // 이름 (텍스트 키보드) - 소셜 로그인일 경우 소셜 ID가 name으로 내려옴
            infoRow(icon: "ProfileCircleIcon") {
                labelText("이름")
            } value: {
                TextField("", text: Binding(
                    get: { container.state.name },
                    set: { container.handleIntent(.updateName($0)) }
                ))
                .valueFieldStyle()
                .focused($focusedField, equals: .name)
                .submitLabel(.done)
            }

            rowDivider

            // 생년월일 (숫자 키보드)
            infoRow(icon: "CalendarIcon") {
                labelText("생년월일")
            } value: {
                TextField("", text: Binding(
                    get: { container.state.birthDisplay },
                    set: { container.handleIntent(.updateBirth($0)) }
                ))
                .valueFieldStyle()
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .birth)
            }

            rowDivider

            // 이메일 (수정 불가)
            infoRow(icon: "EmailIcon") {
                labelText("이메일")
            } value: {
                valueText(container.state.email)
            }

            rowDivider

            // 휴대폰 번호 (숫자 키보드)
            infoRow(icon: "CallIcon") {
                labelText("휴대폰 번호")
            } value: {
                TextField("", text: Binding(
                    get: { container.state.phoneDisplay },
                    set: { container.handleIntent(.updatePhone($0)) }
                ))
                .valueFieldStyle()
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .phone)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(Color.CleanWhite)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.Background, lineWidth: 1)
        )
    }

    private func infoRow<Label: View, Value: View>(
        icon: String,
        @ViewBuilder label: () -> Label,
        @ViewBuilder value: () -> Value
    ) -> some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 17, height: 17)
            label()
            value()
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(height: 17)
    }

    private func labelText(_ text: String) -> some View {
        Text(text)
            .pretendardFont(.bold, size: 14)
            .tracking(-0.408)
            .foregroundColor(.DarkBlack)
            .lineLimit(1)
            .fixedSize()
    }

    private func valueText(_ text: String) -> some View {
        Text(text)
            .pretendardFont(.regular, size: 14)
            .tracking(-0.408)
            .foregroundColor(.DarkBlack)
            .lineLimit(1)
            .truncationMode(.tail)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.Background)
            .frame(height: 1)
    }

    // MARK: - 3a 회원탈퇴 / 3b 로그아웃

    private var bottomActions: some View {
        HStack {
            Button {
                focusedField = nil
                container.handleIntent(.tapWithdrawal)
            } label: {
                Text("회원탈퇴")
                    .pretendardFont(.bold, size: 14)
                    .tracking(-0.408)
                    .foregroundColor(.DarkBlack)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                focusedField = nil
                container.handleIntent(.tapLogout)
            } label: {
                Text("로그아웃")
                    .pretendardFont(.bold, size: 14)
                    .tracking(-0.408)
                    .underline()
                    .foregroundColor(.MindOrange)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    // MARK: - Alerts

    @ViewBuilder
    private var alerts: some View {
        if container.state.showLogoutAlert {
            // A10: 로그아웃 확인
            MessageBoxAlertView(
                message: "로그아웃 하시겠습니까?",
                confirmTitle: "확인",
                cancelTitle: "닫기",
                onConfirm: { container.handleIntent(.confirmLogout) },
                onDismiss: { container.handleIntent(.dismissLogoutAlert) }
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
    /// 우측 값 입력 필드 (Regular 14, 우측 정렬)
    func valueFieldStyle() -> some View {
        self
            .pretendardFont(.regular, size: 14)
            .tracking(-0.408)
            .foregroundColor(.DarkBlack)
            .multilineTextAlignment(.trailing)
    }
}

#Preview {
    NavigationStack {
        MemberInfoView(onLogoutCompleted: {}, onNavigateToWithdrawal: {})
    }
}
