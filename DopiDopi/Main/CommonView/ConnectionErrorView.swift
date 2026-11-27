//
//  ConnectionErrorView.swift
//  DopiDopi
//
//  연결 오류 화면 (피그마 SB_MVP > Error)
//  - ER_MO_1 서비스 연결 오류: 네트워크·서버 문제로 데이터를 불러오지 못함
//  - ER_MO_2 페이지 연결 오류: 페이지(데이터)가 없음. 5초 뒤 홈으로 자동 이동
//
//  화면 전체가 아니라 호출한 화면의 콘텐츠 영역만 채운다.
//  (탭 루트에서는 탭바, 하위 화면에서는 뒤로가기 헤더가 그대로 남아 빠져나갈 수 있음)
//  배경은 칠하지 않으므로 호출부 배경을 그대로 쓴다.
//

import SwiftUI

struct ConnectionErrorView: View {
    let kind: ConnectionErrorKind

    @Environment(\.navigateToHome) private var navigateToHome
    @Environment(\.dismiss) private var dismiss

    /// ER_MO_2 홈 자동 이동까지 대기 시간
    private static let autoNavigateDelay: Duration = .seconds(5)

    var body: some View {
        VStack(spacing: 0) {
            // 피그마 LoadingIcon 컴포넌트 영역(103x47) 기준으로 간격을 맞추기 위해 높이 47 확보
            LoadingIconView()
                .frame(height: 47)
                // 오류 화면에서는 장식용 — VoiceOver가 "로딩 중"으로 읽지 않도록 숨김
                .accessibilityHidden(true)

            Text(title)
                .pretendardFont(.bold, size: 20)
                .foregroundColor(.DarkBlack)
                .padding(.top, 44)

            Text(message)
                .pretendardFont(.medium, size: 12)
                .tracking(-0.408)
                .foregroundColor(.DarkBlack)
                .padding(.top, 20)

            if kind == .page {
                Text("5초 뒤 자동으로 홈으로 이동됩니다.")
                    .pretendardFont(.bold, size: 10)
                    .tracking(-0.408)
                    .foregroundColor(.DarkBlack)
                    .padding(.top, 80)
            }

            Button {
                KakaoChannelChat.openWithWebFallback()
            } label: {
                Text("고객센터로 문의하기")
                    .pretendardFont(.bold, size: 10)
                    .tracking(-0.408)
                    .foregroundColor(.Info)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
            }
            .padding(.top, kind == .page ? 40 - 8 : 80 - 8)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: kind) {
            guard kind == .page else { return }
            // 화면을 벗어나면 task가 취소되어 이동하지 않는다
            try? await Task.sleep(for: Self.autoNavigateDelay)
            guard !Task.isCancelled else { return }
            dismiss()
            navigateToHome?()
        }
    }

    private var title: String {
        switch kind {
        case .service: return "잠시 숨을 고르는 중입니다."
        case .page:    return "잠시 길을 놓쳤습니다."
        }
    }

    private var message: String {
        switch kind {
        case .service: return "서비스 연결에 문제가 생겼어요.\n잠시 후 다시 시도해 주세요."
        case .page:    return "페이지가 이동되었거나 더 이상 존재하지 않습니다.\n호흡을 고르고, 홈에서 다시 시작해 보세요."
        }
    }
}

// MARK: - Navigate To Home Environment

private struct NavigateToHomeKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    /// 모든 탭의 네비게이션 스택을 비우고 홈 탭으로 전환한다. (MainTabView에서 주입)
    var navigateToHome: (() -> Void)? {
        get { self[NavigateToHomeKey.self] }
        set { self[NavigateToHomeKey.self] = newValue }
    }
}

#Preview("ER_MO_1 서비스 연결 오류") {
    ConnectionErrorView(kind: .service)
        .background(Color.SandBeige)
}

#Preview("ER_MO_2 페이지 연결 오류") {
    ConnectionErrorView(kind: .page)
        .background(Color.SandBeige)
}
