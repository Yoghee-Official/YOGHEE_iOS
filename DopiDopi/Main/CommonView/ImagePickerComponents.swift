//
//  ImagePickerComponents.swift
//  YOGHEE
//
//  카메라/갤러리에서 이미지 한 장을 선택하는 공용 컴포넌트.
//  원래 OnedayClassImageRegisterView 안에 있던 카메라/갤러리 피커·권한 알림을
//  자격증 등록 화면 등 다른 이미지 등록 화면에서도 재사용할 수 있도록 분리했다.
//

import SwiftUI
import UIKit

// MARK: - 권한 거부 알림
enum MediaPermissionAlertKind: Equatable {
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
struct ImageCameraPicker: UIViewControllerRepresentable {
    let onImagePicked: (Data) -> Void
    let onDismiss: () -> Void

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
        let parent: ImageCameraPicker

        init(_ parent: ImageCameraPicker) {
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
struct ImagePhotoLibraryPicker: UIViewControllerRepresentable {
    let onImagePicked: (Data) -> Void
    let onDismiss: () -> Void

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
        let parent: ImagePhotoLibraryPicker

        init(_ parent: ImagePhotoLibraryPicker) {
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
