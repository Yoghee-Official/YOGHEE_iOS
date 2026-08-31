//
//  ProfileEditView.swift
//  YOGHEE
//
//  Created by 0ofKim on 12/21/25.
//

import SwiftUI
import PhotosUI
import Photos
import UIKit

struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    
    let currentProfileImage: String?
    let onApply: (UIImage?) -> Void
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showCamera = false
    @State private var recentPhotos: [PHAsset] = []
    @State private var photoImages: [String: UIImage] = [:] // asset identifier -> UIImage
    @State private var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    // 줌 관련 상태
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단바
            topBar
                .zIndex(1)
            
            // 미리보기 영역
            previewSection
                .frame(height: 375)
                .contentShape(Rectangle())
            
            // 최근항목
            recentPhotosSection
        }
        .background(Color.SandBeige)
        .fullScreenCover(isPresented: $showCamera, onDismiss: {
//            showCamera = false
        }) {
            CameraView { image in
                selectedImage = image
            }
        }
        .onAppear {
            requestPhotoLibraryAccess()
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // 취소 버튼
            Button(action: {
                dismiss()
            }) {
                Text("취소")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.DarkBlack)
                    .tracking(-0.408)
            }
            
            Spacer()
            
            // 제목
            Text("프로필 사진 선택")
                .pretendardFont(.bold, size: 20)
                .foregroundColor(.DarkBlack)
            
            Spacer()
            
            // 적용 버튼
            Button(action: {
                onApply(selectedImage)
                dismiss()
            }) {
                Text("적용")
                    .pretendardFont(.medium, size: 12)
                    .foregroundColor(.MindOrange)
                    .tracking(-0.408)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 80)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Preview Section
    private var previewSection: some View {
        ZStack {
            // 선택된 이미지 또는 현재 프로필 이미지
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 375, height: 375)
//                    .scaleEffect(scale)
                    .offset(offset)
//                    .clipShape(Circle())
            } else if let currentProfileImage = currentProfileImage,
                      let url = URL(string: currentProfileImage) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
//                        .scaleEffect(scale)
                        .offset(offset)
                } placeholder: {
                    Image("HeaderLogo")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 375, height: 375)
//                .scaleEffect(scale)
                .offset(offset)
//                .clipShape(Circle())
            } else {
                Image("HeaderLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 375, height: 375)
                    
                    .offset(offset)
//                    .clipShape(Circle())
            }
        }
        .scaleEffect(scale)
        .frame(width: 375, height: 375)
        .clipped() // 프레임 밖을 잘라내기
//        .clipShape(Circle()) // Circle 형태로 클리핑
        .gesture(
            SimultaneousGesture(
                // 핀치 줌 제스처
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / lastScale
                        lastScale = value
                        scale = scale * delta
                        // 최소/최대 줌 제한
                        scale = min(max(scale, 1.0), 4.0)
                        
                        // 줌 아웃 중일 때 offset을 점진적으로 중앙으로 이동
                        if scale <= 1.0 && lastOffset != .zero {
                            // scale이 1.0에 가까워질수록 offset을 0에 가깝게
                            let progress = 1.0 - scale // scale이 1.0이면 progress는 0
                            offset = CGSize(
                                width: lastOffset.width * progress,
                                height: lastOffset.height * progress
                            )
                        }
                    }
                    .onEnded { _ in
                        lastScale = 1.0
                        
                        // 줌 아웃 완료 시 원래 위치로 복귀
                        if scale <= 1.0 {
                            withAnimation {
                                scale = 1.0
                                offset = .zero
                                lastOffset = .zero
                            }
                        } else {
                            // 줌 인 상태 유지 시, offset 범위 제한 및 저장
                            let frameSize: CGFloat = 375
                            let maxOffset = (frameSize * scale - frameSize) / 2
                            offset = CGSize(
                                width: min(max(offset.width, -maxOffset), maxOffset),
                                height: min(max(offset.height, -maxOffset), maxOffset)
                            )
                            lastOffset = offset
                        }
                    },
                // 드래그 제스처 (줌된 상태에서만)
                DragGesture()
                    .onChanged { value in
                        if scale > 1.0 {
                            let frameSize: CGFloat = 375
                            // 이미지가 scale만큼 확대되었을 때, 프레임 밖으로 나갈 수 있는 최대 거리
                            let maxOffset = (frameSize * scale - frameSize) / 2
                            
                            let newOffset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                            
                            // offset 범위 제한 (이미지가 프레임 밖으로 나가지 않도록)
                            offset = CGSize(
                                width: min(max(newOffset.width, -maxOffset), maxOffset),
                                height: min(max(newOffset.height, -maxOffset), maxOffset)
                            )
                        }
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
        )
        .onTapGesture(count: 2) {
            // 더블 탭으로 줌 인/아웃 토글
            withAnimation {
                if scale > 1.0 {
                    scale = 1.0
                    offset = .zero
                    lastOffset = .zero
                } else {
                    scale = 2.0
                }
                lastScale = 1.0
            }
        }
    }
    
    // MARK: - Recent Photos Section
    private var recentPhotosSection: some View {
        VStack(spacing: 0) {
            // "최근항목" 레이블
            HStack {
                Text("최근항목")
                    .pretendardFont(.bold, size: 12)
                    .foregroundColor(.DarkBlack)
                    .tracking(-0.408)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 40)
            
            // 구분선
            Rectangle()
                .fill(Color(hex: "EFEDEB"))
                .frame(height: 1)
            
            // 사진 그리드
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.fixed(125), spacing: 0),
                        GridItem(.fixed(125), spacing: 0),
                        GridItem(.fixed(125), spacing: 0)
                    ],
                    spacing: 0
                ) {
                    // 카메라 버튼
                    Button(action: {
                        showCamera = true
                    }) {
                        cameraButton
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 최근 사진들
                    ForEach(recentPhotos, id: \.localIdentifier) { asset in
                        Button(action: {
                            loadImage(from: asset) { image in
                                selectedImage = image
                            }
                        }) {
                            photoGridItem(for: asset)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // MARK: - Camera Button
    private var cameraButton: some View {
        ZStack {
            Color(hex: "D9D9D9")
            
            VStack(spacing: 0) {
                Text("카메라")
                    .pretendardFont(.bold, size: 16)
                    .foregroundColor(.white)
                Text("촬영 아이콘")
                    .pretendardFont(.bold, size: 16)
                    .foregroundColor(.white)
            }
        }
        .frame(width: 125, height: 125)
        .border(Color.CleanWhite, width: 1)
    }
    
    // MARK: - Photo Grid Item
    private func photoGridItem(for asset: PHAsset) -> some View {
        ZStack(alignment: .topTrailing) {
            // 실제 사진 또는 placeholder
            if let image = photoImages[asset.localIdentifier] {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 125, height: 125)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 125, height: 125)
                    .onAppear {
                        loadThumbnail(for: asset)
                    }
            }
        }
        .frame(width: 125, height: 125)
        .contentShape(Rectangle())
        .border(Color.SandBeige, width: 1)
    }
    
    // MARK: - Photo Library Methods
    
    /// 사진첩 권한 요청
    private func requestPhotoLibraryAccess() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch authorizationStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    authorizationStatus = status
                    if status == .authorized || status == .limited {
                        loadRecentPhotos()
                    }
                }
            }
        case .authorized, .limited:
            loadRecentPhotos()
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }
    
    /// 최근 사진들 로드
    private func loadRecentPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 20 // 최대 20개
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var photos: [PHAsset] = []
        assets.enumerateObjects { asset, _, _ in
            photos.append(asset)
        }
        
        recentPhotos = photos
    }
    
    /// 썸네일 이미지 로드
    private func loadThumbnail(for asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 125, height: 125),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            if let image = image {
                DispatchQueue.main.async {
                    photoImages[asset.localIdentifier] = image
                }
            }
        }
    }
    
    /// 전체 해상도 이미지 로드
    private func loadImage(from asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}

// MARK: - Camera View
struct CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.cameraDevice = .rear
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, dismiss: dismiss)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage) -> Void
        let dismiss: DismissAction
        
        init(onCapture: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onCapture = onCapture
            self.dismiss = dismiss
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onCapture(image)
            }
            dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}

#Preview {
    ProfileEditView(
        currentProfileImage: nil,
        onApply: { image in
            print("이미지 선택: \(image != nil)")
        }
    )
}

