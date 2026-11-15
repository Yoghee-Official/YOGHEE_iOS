//
//  PolicyWebView.swift
//  YOGHEE
//
//  약관 상세 웹뷰 (TU_MO_1 ~ TU_MO_4)
//

import SwiftUI
import WebKit

struct PolicyWebView: View {
    let policy: PolicyType

    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var reloadToken = UUID()

    var body: some View {
        ZStack {
            PolicyWebViewRepresentable(
                url: policy.url,
                reloadToken: reloadToken,
                isLoading: $isLoading,
                loadFailed: $loadFailed
            )
            .opacity(loadFailed ? 0 : 1)

            if loadFailed {
                failureView
            } else if isLoading {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.SandBeige)
        .customNavigationBar(title: policy.title)
    }

    private var failureView: some View {
        VStack(spacing: 16) {
            Text("약관을 불러오지 못했어요.\n네트워크 상태를 확인해 주세요.")
                .pretendardFont(.medium, size: 14)
                .foregroundColor(.DarkBlack)
                .multilineTextAlignment(.center)
            Button {
                loadFailed = false
                isLoading = true
                reloadToken = UUID()
            } label: {
                Text("다시 시도")
                    .pretendardFont(.bold, size: 14)
                    .foregroundColor(.MindOrange)
            }
        }
    }
}

// MARK: - WKWebView Representable

private struct PolicyWebViewRepresentable: UIViewRepresentable {
    let url: URL
    let reloadToken: UUID
    @Binding var isLoading: Bool
    @Binding var loadFailed: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = context.coordinator
        // 앱이 라이트 톤 고정이라 약관 페이지도 라이트 모드로 표시
        webView.overrideUserInterfaceStyle = .light
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        context.coordinator.lastReloadToken = reloadToken
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.parent = self
        if context.coordinator.lastReloadToken != reloadToken {
            context.coordinator.lastReloadToken = reloadToken
            webView.load(URLRequest(url: url))
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: PolicyWebViewRepresentable
        var lastReloadToken: UUID?

        init(parent: PolicyWebViewRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handle(error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handle(error)
        }

        /// 약관 페이지 안의 외부 링크(메일, 전화, 타 도메인)는 웹뷰 밖에서 연다
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard navigationAction.navigationType == .linkActivated,
                  let target = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            let isSameHost = target.host == parent.url.host && (target.scheme == "https" || target.scheme == "http")
            if isSameHost {
                decisionHandler(.allow)
            } else {
                UIApplication.shared.open(target)
                decisionHandler(.cancel)
            }
        }

        private func handle(_ error: Error) {
            // 링크 이동 취소(-999)는 실패로 보지 않음
            if (error as NSError).code == NSURLErrorCancelled { return }
            parent.isLoading = false
            parent.loadFailed = true
        }
    }
}

#Preview {
    NavigationStack {
        PolicyWebView(policy: .service)
    }
}
