//
//  Extension+DebugViewName.swift
//  YOGHEE
//
//  Created by 0ofKim on 9/20/26.
//

import SwiftUI

/// 뷰 이름 라벨의 종류. 종류에 따라 표시 위치와 색이 달라진다.
enum DebugViewKind {
    /// 모듈 뷰 - 좌측 상단, 빨간 글씨
    case module
    /// 아이템 뷰 - 우측 하단, 파란 글씨
    case item
}

extension View {
    /// 디버그 빌드에서 뷰 위에 뷰 이름을 반투명하게 표시한다.
    /// 릴리즈 빌드에서는 아무것도 하지 않는다.
    /// - Parameters:
    ///   - name: 표시할 이름. 생략하면 파일명을 사용한다.
    ///   - kind: 라벨 종류. 모듈은 좌측 상단, 아이템은 우측 하단에 표시된다.
    ///   - fileID: 자동으로 주입되는 파일 식별자
    @ViewBuilder
    func debugViewName(_ name: String? = nil, kind: DebugViewKind = .module, fileID: String = #fileID) -> some View {
        #if DEBUG
        modifier(
            DebugViewNameModifier(
                name: name ?? DebugViewOverlay.name(fromFileID: fileID),
                kind: kind
            )
        )
        #else
        self
        #endif
    }
}

#if DEBUG

// MARK: - 오버레이 표시 여부
/// 뷰 이름 오버레이의 on/off 상태를 관리한다.
/// 기기를 흔들면(시뮬레이터: Device > Shake, ⌃⌘Z) 켜고 끌 수 있고, 마지막 상태는 저장된다.
final class DebugViewOverlay: ObservableObject {
    static let shared = DebugViewOverlay()

    private static let storageKey = "debugViewOverlayEnabled"

    @Published var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: Self.storageKey) }
    }

    private init() {
        let defaults = UserDefaults.standard
        // 저장된 값이 없으면 기본 ON
        isEnabled = defaults.object(forKey: Self.storageKey) == nil
            ? true
            : defaults.bool(forKey: Self.storageKey)

        NotificationCenter.default.addObserver(
            forName: .debugDeviceDidShake,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.toggle()
        }
    }

    func toggle() {
        isEnabled.toggle()
        print("[DebugViewName] 뷰 이름 오버레이 \(isEnabled ? "ON" : "OFF")")
    }

    /// "DopiDopi/HomeTabView.swift" → "HomeTabView"
    static func name(fromFileID fileID: String) -> String {
        (fileID as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
    }
}

// MARK: - 라벨 모디파이어
private struct DebugViewNameModifier: ViewModifier {
    @ObservedObject private var overlay = DebugViewOverlay.shared
    let name: String
    let kind: DebugViewKind

    /// 모듈과 아이템 라벨이 서로 겹치지 않도록 반대쪽 모서리에 배치한다.
    private var alignment: Alignment {
        switch kind {
        case .module: return .topLeading
        case .item: return .bottomTrailing
        }
    }

    private var textColor: Color {
        switch kind {
        case .module: return .red
        case .item: return .blue
        }
    }

    private var backgroundColor: Color {
        switch kind {
        case .module: return .yellow.opacity(0.35)
        case .item: return .white.opacity(0.75)
        }
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if overlay.isEnabled {
                    Text(name)
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundColor(textColor.opacity(0.9))
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.horizontal, 3)
                        .padding(.vertical, 1)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(backgroundColor)
                        )
                        .allowsHitTesting(false)
                }
            }
    }
}

// MARK: - 흔들기 감지
extension Notification.Name {
    static let debugDeviceDidShake = Notification.Name("debugDeviceDidShake")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        guard motion == .motionShake else { return }
        NotificationCenter.default.post(name: .debugDeviceDidShake, object: nil)
    }
}

#endif
