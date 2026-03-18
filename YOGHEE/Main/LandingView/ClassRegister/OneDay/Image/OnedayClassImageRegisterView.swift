//
//  OnedayClassImageRegisterView.swift
//  YOGHEE
//
//  클래스 생성_이미지 등록 화면 (피그마 2987-15478)
//

import SwiftUI
import AVFoundation
import Photos

struct OnedayClassImageRegisterView: View {
    @ObservedObject var container: ClassRegisterContainer
    @Environment(\.dismiss) private var dismiss
    
    @State private var showImageSourceSheet = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var permissionAlert: PermissionAlertKind?
    
    private let totalSteps = 6
    private let currentStep = 5
    private let maxImages = 20
    
    private var canProceed: Bool {
        container.state.classImages.count >= 1
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 2a: 스티키 헤더 (설명 상단 영역)
            imageSectionHeader
                .padding(.horizontal, 16.ratio())
                .padding(.top, 24.ratio())
                .padding(.bottom, 16.ratio())
                .background(Color.SandBeige)
            
            // 이미지 영역만 스크롤 (그리드 + 드래그 순서 변경)
            ScrollView {
                imageContentWithReorder
                    .padding(.horizontal, 16.ratio())
                    .padding(.bottom, 100)
            }
            .background(Color.SandBeige)
            
            bottomNavigation
        }
        .background(Color.SandBeige)
        .customNavigationBar(title: "이미지 등록")
        .sheet(isPresented: $showImageSourceSheet) {
            ClassImageSourceSheet(
                onCamera: { didSelectCamera() },
                onGallery: { didSelectGallery() },
                onDismiss: { showImageSourceSheet = false }
            )
        }
        .fullScreenCover(isPresented: $showCamera) {
            ClassRegisterCameraPicker(onImagePicked: { data in
                DispatchQueue.main.async {
                    addImageData(data)
                    showCamera = false
                }
            }, onDismiss: { showCamera = false })
        }
        .fullScreenCover(isPresented: $showPhotoLibrary) {
            ClassRegisterPhotoLibraryPicker(onImagePicked: { data in
                DispatchQueue.main.async {
                    addImageData(data)
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
    }
    
    // MARK: - 2a: 수련원 이미지 등록 헤더 (스티키)
    private var imageSectionHeader: some View {
        VStack(alignment: .leading, spacing: 8.ratio()) {
            Text("수련원 이미지 등록")
                .pretendardFont(.bold, size: 16)
                .foregroundColor(.DarkBlack)
            Text("드래그로 이미지 순서를 변경할 수 있어요.")
                .pretendardFont(.regular, size: 10)
                .foregroundColor(.Info)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// 2열 그리드 (피그마 2987-15478 / 2987-15403): 셀 크기 고정으로 찌그러짐 방지
    private var imageContentWithReorder: some View {
        let horizontalPadding = 16.ratio() * 2
        let spacing: CGFloat = 12
        let cellSide = (UIScreen.main.bounds.width - horizontalPadding - spacing) / 2
        let columns = [
            GridItem(.fixed(cellSide), spacing: spacing),
            GridItem(.fixed(cellSide), spacing: spacing)
        ]
        return LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(container.state.classImages) { item in
                RegisteredImageCell(
                    item: item,
                    onDelete: { container.handleIntent(.removeClassImage(item.id)) }
                )
                .frame(width: cellSide, height: cellSide)
            }
            if container.state.classImages.count < maxImages {
                Button(action: { showImageSourceSheet = true }) {
                    NewImageAddCell()
                }
                .buttonStyle(.plain)
                .frame(width: cellSide, height: cellSide)
            }
        }
    }
    
    private func reorderImages(from source: IndexSet, to destination: Int) {
        var ids = container.state.classImages.map(\.id)
        ids.move(fromOffsets: source, toOffset: destination)
        container.handleIntent(.reorderClassImages(ids))
    }
    
    private func addImageData(_ data: Data) {
        guard container.state.classImages.count < maxImages else { return }
        let countBefore = container.state.classImages.count
        container.handleIntent(.addClassImages([data]))
        guard let newId = container.state.classImages.suffix(container.state.classImages.count - countBefore).map(\.id).first else { return }
        Task {
            await container.uploadClassImage(itemId: newId, imageData: data)
        }
    }
    
    private func didSelectCamera() {
        showImageSourceSheet = false
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [self] granted in
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
    
    // MARK: - 3: 하단 네비게이션
    private var bottomNavigation: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.DarkBlack)
                        .frame(width: geo.size.width * CGFloat(currentStep) / CGFloat(totalSteps))
                }
            }
            .frame(height: 4.ratio())
            .padding(.horizontal, 16.ratio())
            .padding(.bottom, 16.ratio())
            
            HStack(spacing: 12.ratio()) {
                Button(action: { dismiss() }) {
                    Text("이전페이지")
                        .pretendardFont(.medium, size: 15)
                        .foregroundColor(.DarkBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48.ratio())
                        .background(Color.Background)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    OnedayClassSetPriceView(container: container)
                } label: {
                    Text("계속")
                        .pretendardFont(.medium, size: 15)
                        .foregroundColor(canProceed ? .DarkBlack : .Info)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48.ratio())
                        .background(canProceed ? Color.GheeYellow : Color.Background)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(!canProceed)
            }
            .padding(.horizontal, 16.ratio())
            .padding(.bottom, 24.ratio())
        }
        .background(Color.SandBeige)
    }
}

// MARK: - 등록된 이미지 셀 (로딩 시 placeholder, 완료 시 이미지 + 삭제)
private struct RegisteredImageCell: View {
    let item: ClassRegisterImageItem
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if item.isLoading {
                Text("추후 로딩 이미지 등록 예정")
                    .pretendardFont(.regular, size: 12)
                    .foregroundColor(.Info)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.CleanWhite)
                    .cornerRadius(8)
            } else if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .cornerRadius(8)
            }
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1)
            }
            .padding(6.ratio())
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - 신규 이미지 등록 셀 (영역 클릭 시 팝업, 사진 셀과 동일 크기)
private struct NewImageAddCell: View {
    var body: some View {
        Image(systemName: "plus.circle.fill")
            .font(.system(size: 32))
            .foregroundColor(.Info)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.CleanWhite)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.Background, lineWidth: 1)
            )
    }
}

// MARK: - 이미지 소스 선택 시트 (모달, 헤더 X 버튼)
struct ClassImageSourceSheet: View {
    let onCamera: () -> Void
    let onGallery: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Button(action: onCamera) {
                    HStack {
                        Text("카메라로 촬영하기")
                            .pretendardFont(.medium, size: 16)
                            .foregroundColor(.DarkBlack)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.Info)
                    }
                    .padding(.horizontal, 20.ratio())
                    .padding(.vertical, 16.ratio())
                }
                .buttonStyle(.plain)
                
                Divider()
                    .padding(.leading, 20.ratio())
                
                Button(action: onGallery) {
                    HStack {
                        Text("갤러리에서 불러오기")
                            .pretendardFont(.medium, size: 16)
                            .foregroundColor(.DarkBlack)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.Info)
                    }
                    .padding(.horizontal, 20.ratio())
                    .padding(.vertical, 16.ratio())
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .background(Color.CleanWhite)
            .navigationTitle("이미지 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.DarkBlack)
                    }
                }
            }
        }
    }
}

// MARK: - 권한 알림
private enum PermissionAlertKind {
    case deniedCamera
    case deniedPhotoLibrary
    case denied
    
    var title: String { "권한 필요" }
    var message: String {
        switch self {
        case .deniedCamera:
            return "카메라 접근이 거부되었습니다. 설정에서 권한을 허용해 주세요."
        case .deniedPhotoLibrary:
            return "사진 라이브러리 접근이 거부되었습니다. 설정에서 권한을 허용해 주세요."
        case .denied:
            return "접근 권한이 필요합니다."
        }
    }
}

// MARK: - 카메라 피커
private struct ClassRegisterCameraPicker: UIViewControllerRepresentable {
    let onImagePicked: (Data) -> Void
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ClassRegisterCameraPicker
        
        init(_ parent: ClassRegisterCameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.8) {
                parent.onImagePicked(data)
            }
            // 닫기는 부모 콜백에서 showCamera = false 로 처리 (풀스크린 해제)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onDismiss()
        }
    }
}

// MARK: - 갤러리 피커
private struct ClassRegisterPhotoLibraryPicker: UIViewControllerRepresentable {
    let onImagePicked: (Data) -> Void
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ClassRegisterPhotoLibraryPicker
        
        init(_ parent: ClassRegisterPhotoLibraryPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let image = info[.originalImage] as? UIImage,
                  let data = image.jpegData(compressionQuality: 0.8) else { return }
            picker.dismiss(animated: true) {
                DispatchQueue.main.async { self.parent.onImagePicked(data) }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onDismiss()
        }
    }
}

#Preview {
    NavigationStack {
        OnedayClassImageRegisterView(container: ClassRegisterContainer())
    }
}
