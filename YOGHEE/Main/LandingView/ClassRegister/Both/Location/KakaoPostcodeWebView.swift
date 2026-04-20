//
//  KakaoPostcodeWebView.swift
//  YOGHEE
//
//  카카오 우편번호 서비스 웹뷰 (https://postcode.map.daum.net/guide)
//

import SwiftUI
import WebKit

/// 카카오 우편번호 서비스를 WKWebView로 띄우고, 선택 결과를 콜백으로 전달
struct KakaoPostcodeWebView: View {
    let onAddressSelected: (KakaoPostcodeResult) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            KakaoPostcodeWebViewRepresentable(onAddressSelected: onAddressSelected)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("주소 검색")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("닫기") {
                            onDismiss()
                        }
                    }
                }
        }
    }
}

// MARK: - WKWebView Representable

private struct KakaoPostcodeWebViewRepresentable: UIViewRepresentable {
    let onAddressSelected: (KakaoPostcodeResult) -> Void
    
    private static let messageHandlerName = "postcodeResult"
    
    /// 카카오 가이드 기준 embed용 HTML (oncomplete 시 postcodeResult로 JSON 전달)
    private static var postcodeHTML: String {
        """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
        <style>
        * { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow-x: hidden; }
        #wrap { width: 100%; height: 100%; min-height: 100vh; overflow: hidden; max-width: 100vw; }
        </style>
        </head>
        <body>
        <div id="wrap"></div>
        <script src="https://t1.kakaocdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
        <script>
        (function() {
            var wrap = document.getElementById('wrap');
            if (typeof kakao === 'undefined') {
                wrap.innerHTML = '<p style="padding:20px">스크립트를 불러오는 중입니다...</p>';
                return;
            }
            new kakao.Postcode({
                width: '100%',
                height: '100%',
                oncomplete: function(data) {
                    var payload = {
                        zonecode: data.zonecode || '',
                        address: data.address || '',
                        roadAddress: data.roadAddress || '',
                        jibunAddress: data.jibunAddress || '',
                        userSelectedType: data.userSelectedType || '',
                        buildingName: data.buildingName || '',
                        sido: data.sido || '',
                        sigungu: data.sigungu || ''
                    };
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.\(messageHandlerName)) {
                        window.webkit.messageHandlers.\(messageHandlerName).postMessage(JSON.stringify(payload));
                    }
                }
            }).embed(wrap);
        })();
        </script>
        </body>
        </html>
        """
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onAddressSelected: onAddressSelected)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: Self.messageHandlerName)
        config.userContentController = contentController
        config.processPool = WKProcessPool()
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.bounces = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.isDirectionalLockEnabled = true
        webView.isOpaque = false
        webView.backgroundColor = .white
        
        let baseURL = URL(string: "https://postcode.map.daum.net/")
        webView.loadHTMLString(Self.postcodeHTML, baseURL: baseURL)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        let onAddressSelected: (KakaoPostcodeResult) -> Void
        
        init(onAddressSelected: @escaping (KakaoPostcodeResult) -> Void) {
            self.onAddressSelected = onAddressSelected
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == KakaoPostcodeWebViewRepresentable.messageHandlerName,
                  let body = message.body as? String,
                  let data = body.data(using: .utf8) else { return }
            
            do {
                let result = try JSONDecoder().decode(KakaoPostcodeResult.self, from: data)
                DispatchQueue.main.async {
                    self.onAddressSelected(result)
                }
            } catch {
                #if DEBUG
                print("KakaoPostcodeWebView: decode failed \(error)")
                #endif
            }
        }
    }
}

#Preview {
    KakaoPostcodeWebView(
        onAddressSelected: { _ in },
        onDismiss: { }
    )
}
