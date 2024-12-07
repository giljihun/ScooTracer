//
//  File.swift
//  ScooTracer
//
//  Created by mobicom on 12/7/24.
//

import AVFoundation
import UIKit

class SelfieCaptureViewModel: NSObject {

    // MARK: - Properties
    var onPermissionGranted: (() -> Void)?
    var onPermissionDenied: (() -> Void)?
    var onCameraSessionConfigured: ((AVCaptureSession) -> Void)?
    var onPhotoCaptured: ((UIImage) -> Void)?

    private var captureSession: AVCaptureSession?
    private let photoOutput = AVCapturePhotoOutput()

    // MARK: - Camera Authorization
    func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            onPermissionGranted?()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    granted ? self?.onPermissionGranted?() : self?.onPermissionDenied?()
                }
            }
        default:
            onPermissionDenied?()
        }
    }

    // MARK: - Camera Setup
    func setupCameraSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("카메라 입력 장치를 가져올 수 없습니다.")
            return
        }

        session.addInput(input)
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        captureSession = session
        onCameraSessionConfigured?(session)
    }

    // MARK: - Camera Control
    func startCameraSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    func stopCameraSession() {
        captureSession?.stopRunning()
    }

    func capturePhoto(completion: @escaping (UIImage) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        photoOutput.capturePhoto(with: settings, delegate: self)

        self.onPhotoCaptured = completion
    }
}
// MARK: - Keychain 저장
private func saveToKeychain(_ faceImage: UIImage) {
    guard let imageData = faceImage.jpegData(compressionQuality: 0.8) else {
        print("얼굴 이미지 데이터 변환 실패")
        return
    }

    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "selfiePhoto",
        kSecValueData as String: imageData
    ]

    SecItemDelete(query as CFDictionary) // 기존 항목 삭제
    let status = SecItemAdd(query as CFDictionary, nil)

    print(status == errSecSuccess ? "본인 얼굴 이미지 KeyChain에 저장 성공" : "KeyChain 저장 실패: \(status)")
}

// MARK: - AVCapturePhotoCaptureDelegate
extension SelfieCaptureViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoData = photo.fileDataRepresentation(),
              let image = UIImage(data: photoData) else {
            print("사진 처리 실패")
            return
        }

        onPhotoCaptured?(image)
    }
}
