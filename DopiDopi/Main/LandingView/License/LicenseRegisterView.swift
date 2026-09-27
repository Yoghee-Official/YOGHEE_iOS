//
//  LicenseRegisterView.swift
//  YOGHEE
//
//  자격증 등록(임시) 화면 (피그마 3-8616 / 3-8639 / 3-8675 / 3-8664)
//  마이페이지 > 지도자 > 세부항목 > "자격증 등록(임시)" 진입점에서 랜딩.
//

import SwiftUI
import AVFoundation
import Photos

struct LicenseRegisterView: View {
    @StateObject private var container = LicenseRegisterContainer()
    @Environment(\.dismiss) private var dismiss

    @State private var showImageSourceSheet = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var permissionAlert: MediaPermissionAlertKind?

    private let imageAreaWidth: CGFloat = 343
    private let imageAreaHeight: CGFloat = 250
    /// 이미지 선택 후 표시되는 실제 이미지 폭 (피그마 기준 - 플레이스홀더보다 좁게 중앙 정렬)
    private let selectedImageWidth: CGFloat = 178

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, 24.ratio())

                imagePickerArea
                    .padding(.top, 16.ratio())

                certificateInfo
                    .padding(.top, 24.ratio())
            }
            .padding(.horizontal, 16.ratio())
            .padding(.bottom, 120.ratio())
        }
        .background(Color.SandBeige)
        .customNavigationBar(
            title: "인증서 등록",
            trailingTitle: "문의하기",
            onTrailingTap: { handleInquiryTap() }
        )
        .safeAreaInset(edge: .bottom) { registerButton }
        .sheet(isPresented: $showImageSourceSheet) {
            LicenseImageSourceSheet(
                onCamera: { didSelectCamera() },
                onGallery: { didSelectGallery() }
            )
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImageCameraPicker(onImagePicked: { data in
                DispatchQueue.main.async {
                    container.handleIntent(.pickImage(data))
                    showCamera = false
                }
            }, onDismiss: { showCamera = false })
        }
        .fullScreenCover(isPresented: $showPhotoLibrary) {
            ImagePhotoLibraryPicker(onImagePicked: { data in
                DispatchQueue.main.async {
                    container.handleIntent(.pickImage(data))
                    showPhotoLibrary = false
                }
            }, onDismiss: { showPhotoLibrary = false })
        }
        .alert(permissionAlert?.title ?? "권한", isPresented: Binding(
            get: { permissionAlert != nil },
            set: { if !$0 { permissionAlert = nil } }
        )) {
            if permissionAlert == .deniedCamera || permissionAlert == .deniedPhotoLibrary {
                Button("설정으로 이동") {
                    openAppSettings()
                    permissionAlert = nil
                }
                Button("취소", role: .cancel) { permissionAlert = nil }
            } else {
                Button("확인") { permissionAlert = nil }
            }
        } message: {
            Text(permissionAlert?.message ?? "")
        }
        .alert("오류", isPresented: Binding(
            get: { container.state.errorMessage != nil },
            set: { if !$0 { container.handleIntent(.dismissError) } }
        )) {
            Button("확인") { container.handleIntent(.dismissError) }
        } message: {
            Text(container.state.errorMessage ?? "")
        }
        .alert("자격증 인증 등록 요청 완료", isPresented: $container.showCompletionAlert) {
            Button("확인") { dismiss() }
        } message: {
            Text("인증서 심사는 2~3일 소요됩니다.\n심사 결과는 이메일로 안내드릴게요.")
        }
        .debugViewName()
    }

    // MARK: - 1: 헤더 (자격증 인증 타이틀 + 안내문구)
    private var header: some View {
        VStack(alignment: .leading, spacing: 8.ratio()) {
            Text("자격증 인증")
                .pretendardFont(.bold, size: 20)
                .foregroundColor(.DarkBlack)
            Text("인증서 심사는 2~3일 소요됩니다.")
                .pretendardFont(.regular, size: 12)
                .foregroundColor(.MindOrange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 2a: 이미지 등록 영역 (탭하면 커스텀 팝업 → 카메라/갤러리)
    private var imagePickerArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.Background)
                .frame(width: imageAreaWidth.ratio(), height: imageAreaHeight.ratio())

            if let imageData = container.state.imageData, let uiImage = UIImage(data: imageData) {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: selectedImageWidth.ratio(), height: imageAreaHeight.ratio())
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    if container.state.isUploadingImage {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.15))
                            .frame(width: selectedImageWidth.ratio(), height: imageAreaHeight.ratio())
                        Image("LoadingIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28.ratio(), height: 28.ratio())
                    }
                }
            } else {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.Info)
            }
        }
        .frame(width: imageAreaWidth.ratio(), height: imageAreaHeight.ratio())
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !container.state.isUploadingImage else { return }
            showImageSourceSheet = true
        }
    }

    // MARK: - 2b: 취급 인증서 안내 텍스트 영역
    private var certificateInfo: some View {
        VStack(alignment: .leading, spacing: 12.ratio()) {
            VStack(alignment: .leading, spacing: 6.ratio()) {
                Text("취급하는 인증서는 아래와 같습니다.")
                    .pretendardFont(.bold, size: 12)
                    .foregroundColor(.DarkBlack)

                VStack(alignment: .leading, spacing: 4.ratio()) {
                    ForEach(LicenseCertificateHardcoded.supportedCertificates, id: \.self) { item in
                        HStack(alignment: .top, spacing: 4) {
                            Text("•")
                            Text(item)
                        }
                        .pretendardFont(.regular, size: 12)
                        .foregroundColor(.DarkBlack)
                    }
                }
            }

            Text("민간 자격 정보는 자격증 이미지 확인 후 관리자가 직접 등록 예정입니다.")
                .pretendardFont(.medium, size: 12)
                .foregroundColor(.Info)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 3a: 등록 버튼
    private var registerButton: some View {
        VStack(spacing: 0) {
            Button(action: { container.handleIntent(.register) }) {
                if container.state.isRegistering {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 48.ratio())
                        .background(Color.Background)
                        .cornerRadius(8)
                } else {
                    Text("등록")
                        .pretendardFont(.semiBold, size: 15)
                        .foregroundColor(container.state.canRegister ? .DarkBlack : .Info)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48.ratio())
                        .background(container.state.canRegister ? Color.GheeYellow : Color.Background)
                        .cornerRadius(8)
                }
            }
            .buttonStyle(.plain)
            .disabled(!container.state.canRegister)
            .padding(.horizontal, 16.ratio())
            .padding(.top, 12.ratio())
            .padding(.bottom, 24.ratio())
        }
        .background(Color.SandBeige)
    }

    private func handleInquiryTap() {
        // TODO: 문의하기 채널(웹/카카오 등) 연결 - OnedayClassImageRegisterView와 동일하게 추후 연동 필요
    }

    // MARK: - 권한 체크 (OnedayClassImageRegisterView와 동일한 흐름)
    private func didSelectCamera() {
        showImageSourceSheet = false
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showCamera = true
                    } else {
                        permissionAlert = .deniedCamera
                    }
                }
            }
        default:
            permissionAlert = .deniedCamera
        }
    }

    private func didSelectGallery() {
        showImageSourceSheet = false
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            showPhotoLibrary = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        showPhotoLibrary = true
                    } else {
                        permissionAlert = .deniedPhotoLibrary
                    }
                }
            }
        default:
            permissionAlert = .deniedPhotoLibrary
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - 커스텀 팝업: 이미지 소스 선택 (피그마 3-8639, 간단한 바텀시트 - 타이틀/닫기 버튼 없음)
struct LicenseImageSourceSheet: View {
    let onCamera: () -> Void
    let onGallery: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.Info)
                .frame(width: 48.ratio(), height: 2.ratio())
                .padding(.top, 12.ratio())
                .padding(.bottom, 20.ratio())

            Button(action: onCamera) {
                Text("카메라로 촬영하기")
                    .pretendardFont(.medium, size: 16)
                    .foregroundColor(.DarkBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 28.ratio())
            .padding(.vertical, 12.ratio())

            Button(action: onGallery) {
                Text("갤러리에서 불러오기")
                    .pretendardFont(.medium, size: 16)
                    .foregroundColor(.DarkBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 28.ratio())
            .padding(.vertical, 12.ratio())

            Spacer(minLength: 0)
        }
        .background(Color.CleanWhite)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.hidden)
    }
}

#Preview {
    NavigationStack {
        LicenseRegisterView()
    }
}
