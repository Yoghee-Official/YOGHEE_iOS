//
//  MemberInfoContainer.swift
//  YOGHEE
//
//  회원정보관리(MI_MO_1) - 마이 탭 > 설정 > 회원 정보 관리
//

import SwiftUI

// MARK: - Intent
enum MemberInfoIntent {
    case load
    /// 2a 이름 입력
    case updateName(String)
    /// 2a 생년월일 입력 (숫자 키보드)
    case updateBirth(String)
    /// 2a 휴대폰 번호 입력 (숫자 키보드)
    case updatePhone(String)
    /// 1c 저장하기
    case save
    /// 3a 회원탈퇴 → 탈퇴 가능 여부 확인 후 탈퇴 확인 페이지(DA_MO_1) 이동
    case tapWithdrawal
    /// 3b 로그아웃 → A10 얼럿
    case tapLogout
    case dismissLogoutAlert
    case confirmLogout
    case dismissMessage
}

// MARK: - State
struct MemberInfoState: Equatable {
    var isLoading: Bool = false
    var isSaving: Bool = false
    /// 탈퇴 가능 여부 확인 · 로그아웃 처리 중
    var isProcessing: Bool = false

    /// 서버에서 받은 원본 (변경 여부 비교용)
    var original: MyInfoDto?

    var name: String = ""
    /// 숫자만 저장 (최대 8자리, yyyyMMdd)
    var birthDigits: String = ""
    var email: String = ""
    /// 숫자만 저장 (최대 11자리)
    var phoneDigits: String = ""

    var showLogoutAlert: Bool = false
    /// 저장 결과·에러 안내 (확인 버튼 하나짜리 팝업)
    var message: String?

    var birthDisplay: String { MemberInfoFormatter.birth(birthDigits) }
    var phoneDisplay: String { MemberInfoFormatter.phone(phoneDigits) }

    var originalName: String { original?.name ?? "" }
    var originalBirthDigits: String { MemberInfoFormatter.digits(original?.birthDate ?? "", limit: 8) }
    var originalPhoneDigits: String { MemberInfoFormatter.digits(original?.phoneNo ?? "", limit: 11) }

    var hasChanges: Bool {
        guard original != nil else { return false }
        return name != originalName
            || birthDigits != originalBirthDigits
            || phoneDigits != originalPhoneDigits
    }
}

@MainActor
class MemberInfoContainer: ObservableObject {
    @Published private(set) var state = MemberInfoState()

    /// 로그아웃 완료 후 처리 (마이 탭 스택 초기화 + 홈 이동)
    private let onLogoutCompleted: () -> Void
    /// 탈퇴 가능 확인 후 탈퇴 확인 페이지(DA_MO_1)로 이동
    private let onNavigateToWithdrawal: () -> Void

    init(
        onLogoutCompleted: @escaping () -> Void,
        onNavigateToWithdrawal: @escaping () -> Void
    ) {
        self.onLogoutCompleted = onLogoutCompleted
        self.onNavigateToWithdrawal = onNavigateToWithdrawal
    }

    func handleIntent(_ intent: MemberInfoIntent) {
        switch intent {
        case .load:
            load()
        case .updateName(let name):
            state.name = name
        case .updateBirth(let text):
            state.birthDigits = MemberInfoFormatter.digits(text, limit: 8)
        case .updatePhone(let text):
            state.phoneDigits = MemberInfoFormatter.digits(text, limit: 11)
        case .save:
            save()
        case .tapWithdrawal:
            checkWithdrawal()
        case .tapLogout:
            state.showLogoutAlert = true
        case .dismissLogoutAlert:
            state.showLogoutAlert = false
        case .confirmLogout:
            logout()
        case .dismissMessage:
            state.message = nil
        }
    }

    // MARK: - Private

    private func load() {
        guard state.original == nil, !state.isLoading else { return }
        state.isLoading = true
        Task {
            defer { state.isLoading = false }
            do {
                let info = try await APIService.shared.getMyInfo()
                apply(info)
                print("✅ [MemberInfo] 개인정보 조회 완료")
            } catch {
                print("❌ [MemberInfo] 개인정보 조회 실패: \(error)")
                state.message = "회원 정보를 불러오지 못했습니다."
            }
        }
    }

    private func apply(_ info: MyInfoDto) {
        state.original = info
        state.name = info.name ?? ""
        state.birthDigits = MemberInfoFormatter.digits(info.birthDate ?? "", limit: 8)
        state.email = info.email ?? ""
        state.phoneDigits = MemberInfoFormatter.digits(info.phoneNo ?? "", limit: 11)
    }

    /// PUT /api/my/info - null인 필드는 변경되지 않으므로 바뀐 필드만 담아 보낸다.
    private func save() {
        guard state.hasChanges, !state.isSaving else { return }

        var body = UpdateUserInfoDto()

        // 이름
        let name = state.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name != state.originalName {
            guard !name.isEmpty else {
                state.message = "이름을 입력해 주세요."
                return
            }
            guard name.count <= 50 else {
                state.message = "이름은 50자 이내로 입력해 주세요."
                return
            }
            body.name = name
        }

        // 생년월일 (yyyy-MM-dd). null은 '변경 안 함'이라 기존 값을 비우는 건 불가
        if state.birthDigits != state.originalBirthDigits {
            guard let birthDate = MemberInfoFormatter.isoBirth(state.birthDigits) else {
                state.message = "생년월일을 정확히 입력해 주세요."
                return
            }
            body.birthDate = birthDate
        }

        // 휴대폰 번호 (숫자만, 10~11자리). 기존 값을 비우는 건 불가
        if state.phoneDigits != state.originalPhoneDigits {
            guard (10...11).contains(state.phoneDigits.count) else {
                state.message = "휴대폰 번호를 정확히 입력해 주세요."
                return
            }
            body.phoneNo = state.phoneDigits
        }

        guard !body.isEmpty else { return }

        state.isSaving = true
        Task {
            defer { state.isSaving = false }
            do {
                try await APIService.shared.updateMyInfo(body: body)
                let original = state.original
                apply(MyInfoDto(
                    name: body.name ?? original?.name,
                    email: original?.email,
                    phoneNo: body.phoneNo ?? original?.phoneNo,
                    birthDate: body.birthDate ?? original?.birthDate
                ))
                state.message = "회원 정보가 저장되었습니다."
                print("✅ [MemberInfo] 개인정보 변경 완료")
            } catch APIError.serverError(let statusCode, _, let message) where statusCode == 409 {
                // 이미 사용 중인 이메일/휴대폰번호
                print("⚠️ [MemberInfo] 개인정보 변경 중복: \(message)")
                state.message = message
            } catch {
                print("❌ [MemberInfo] 개인정보 변경 실패: \(error)")
                state.message = "회원 정보 저장에 실패했습니다.\n잠시 후 다시 시도해 주세요."
            }
        }
    }

    /// A10 확인: 로그아웃 및 팝업 종료 → 홈 화면 노출
    private func logout() {
        guard !state.isProcessing else { return }
        state.showLogoutAlert = false
        state.isProcessing = true
        Task {
            // 서버 리프레시 토큰 무효화는 best-effort: 실패(네트워크 오류·토큰 만료 등)해도 기기에서는 로그아웃시킨다
            do {
                try await APIService.shared.logout()
                print("✅ [MemberInfo] 서버 로그아웃 완료")
            } catch {
                print("⚠️ [MemberInfo] 서버 로그아웃 실패 - 로컬 로그아웃만 진행: \(error)")
            }
            AuthManager.shared.logout()
            state.isProcessing = false
            onLogoutCompleted()
        }
    }

    /// 3a: 예정 예약·처리 중 결제·소유 센터가 있으면 탈퇴 불가 안내, 없으면 DA_MO_1 이동.
    /// (GET 조회만 하므로 실제 탈퇴는 일어나지 않음. 서버가 POST 탈퇴 시에도 다시 확인함)
    private func checkWithdrawal() {
        guard !state.isProcessing else { return }
        state.isProcessing = true
        Task {
            defer { state.isProcessing = false }
            do {
                let result = try await APIService.shared.checkWithdrawal()
                print("✅ [MemberInfo] 탈퇴 가능 여부: \(result.canWithdraw), blockers: \(result.blockers ?? [])")
                if result.canWithdraw {
                    onNavigateToWithdrawal()
                } else {
                    state.message = result.blockedMessage
                }
            } catch {
                print("❌ [MemberInfo] 탈퇴 가능 여부 확인 실패: \(error)")
                state.message = "잠시 후 다시 시도해 주세요."
            }
        }
    }
}

// MARK: - Formatter
enum MemberInfoFormatter {
    static func digits(_ text: String, limit: Int) -> String {
        String(text.filter(\.isNumber).prefix(limit))
    }

    /// 19960914 → 1996.09.14 (입력 중에도 자리수에 맞춰 점 삽입)
    static func birth(_ digits: String) -> String {
        var result = ""
        for (index, char) in digits.enumerated() {
            if index == 4 || index == 6 { result.append(".") }
            result.append(char)
        }
        return result
    }

    /// 01021210000 → 010-2121-0000, 0212345678 → 021-234-5678
    static func phone(_ digits: String) -> String {
        let chars = Array(digits)
        let middleLength = chars.count >= 11 ? 4 : 3
        var result = ""
        for (index, char) in chars.enumerated() {
            if index == 3 || index == 3 + middleLength { result.append("-") }
            result.append(char)
        }
        return result
    }

    /// 19960914 → 1996-09-14 (유효하지 않은 날짜면 nil)
    static func isoBirth(_ digits: String) -> String? {
        guard digits.count == 8 else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyyMMdd"
        formatter.isLenient = false
        guard let date = formatter.date(from: digits), date <= Date() else { return nil }
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
