//
//  LicenseRegisterContainer.swift
//  YOGHEE
//
//  자격증 등록(임시) 화면 - 자격증 인증 등록 API (POST /api/my/license) 연동
//  피그마 참고: node-id 3-8616(기본) / 3-8639(팝업) / 3-8675(로딩) / 3-8664(이미지 등록 완료)
//

import SwiftUI
import Foundation
import UIKit

// MARK: - Intent
enum LicenseRegisterIntent {
    /// 이미지 선택 (카메라/갤러리) - presign 업로드까지 이어서 진행
    case pickImage(Data)
    /// 선택된 이미지 제거
    case removeImage
    /// 등록 버튼 클릭 - 자격증 인증 등록 API 호출
    case register
    /// 에러 알림 닫기
    case dismissError
}

// MARK: - State
struct LicenseRegisterState: Equatable {
    /// 선택된 이미지 (미리보기 표시용)
    var imageData: Data? = nil
    /// Presigned 업로드 완료 후 서버가 준 이미지 전체 URL (자격증 등록 API에 그대로 전달)
    var imageUrl: String? = nil
    /// 이미지 presign 발급 + 업로드 진행 중 (피그마 로딩 화면)
    var isUploadingImage: Bool = false
    /// 자격증 등록 API 호출 중
    var isRegistering: Bool = false
    var errorMessage: String? = nil

    /// 등록 버튼 활성화 조건 - 이미지 등록이 완료되어야 함
    var canRegister: Bool {
        imageUrl != nil && !isRegistering
    }
}

@MainActor
final class LicenseRegisterContainer: ObservableObject {
    @Published private(set) var state = LicenseRegisterState()
    /// 등록 완료 알림 표시용 (State 밖에 둬서 Sheet/Alert 바인딩을 단순하게 유지 - MyPageTabContainer의 showLoginSheet 패턴과 동일)
    @Published var showCompletionAlert: Bool = false

    func handleIntent(_ intent: LicenseRegisterIntent) {
        switch intent {
        case .pickImage(let data):
            state.imageData = data
            state.imageUrl = nil
            state.isUploadingImage = true
            Task { await uploadLicenseImage(data: data) }

        case .removeImage:
            state.imageData = nil
            state.imageUrl = nil
            state.isUploadingImage = false

        case .register:
            registerLicense()

        case .dismissError:
            state.errorMessage = nil
        }
    }

    /// 자격증 이미지 1장 Presigned 발급 → PUT 업로드 → imageUrl 저장
    /// (ClassRegisterContainer.uploadClassImage와 동일한 흐름, type만 "license"로 지정 — 자격증 이미지는 비공개로 유지됨)
    private func uploadLicenseImage(data: Data) async {
        guard let image = UIImage(data: data) else {
            state.isUploadingImage = false
            return
        }
        let width = Int(image.size.width * image.scale)
        let height = Int(image.size.height * image.scale)
        let fileSize = data.count
        let fileName = "\(UUID().uuidString).jpg"
        let contentType = "image/jpeg"
        let dto = ImageUploadDto(
            type: "license",
            files: [ImageUploadInfoDto(fileName: fileName, contentType: contentType, width: width, height: height, fileSize: fileSize)]
        )
        do {
            let response = try await APIService.shared.postImagePresign(body: dto)
            guard let first = response.files.first, let imageUrl = first.imageUrl else {
                await MainActor.run {
                    state.isUploadingImage = false
                    state.errorMessage = "이미지 업로드에 실패했습니다. 다시 시도해 주세요."
                }
                return
            }
            try await APIService.shared.uploadImageToPresignedUrl(data: data, presignedUrl: first.presignedUrl, contentType: first.contentType)
            await MainActor.run {
                state.imageUrl = imageUrl
                state.isUploadingImage = false
            }
        } catch {
            await MainActor.run {
                state.isUploadingImage = false
                state.errorMessage = "이미지 업로드에 실패했습니다. 다시 시도해 주세요."
            }
        }
    }

    /// 자격증 인증 등록 (POST /api/my/license)
    private func registerLicense() {
        guard let imageUrl = state.imageUrl, !state.isRegistering else { return }
        state.isRegistering = true
        state.errorMessage = nil

        Task {
            do {
                _ = try await APIService.shared.postLicenseVerification(imageUrl: imageUrl)
                await MainActor.run {
                    state.isRegistering = false
                    showCompletionAlert = true
                }
            } catch {
                await MainActor.run {
                    state.isRegistering = false
                    if let apiError = error as? APIError {
                        state.errorMessage = apiError.localizedDescription
                    } else {
                        state.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}
