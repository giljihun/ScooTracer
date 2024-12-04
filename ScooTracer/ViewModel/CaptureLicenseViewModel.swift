//
//  CaptureLicenseViewModel.swift
//  ScooTracer
//
//  Created by mobicom on 11/18/24.
//

import AVFoundation
import UIKit

class CaptureLicenseViewModel: NSObject {

    // MARK: - Properties
    var onPermissionGranted: (() -> Void)?
    var onPermissionDenied: (() -> Void)?
    var onCameraSessionConfigured: ((AVCaptureSession) -> Void)?
    var onPhotoCaptured: ((UIImage) -> Void)?

    private var captureSession: AVCaptureSession?
    private let photoOutput = AVCapturePhotoOutput()

    // MARK: - 카메라 권한 확인
    func checkCameraAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
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
    // MARK: - 카메라 세션 설정
    func setupCameraSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("카메라 입력 장치를 가져올 수 없습니다.")
            return
        }

        session.addInput(input)
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        self.captureSession = session
        onCameraSessionConfigured?(session)
    }

    /// 카메라 세션 시작
    func startCameraSession() {
        /// 메인 스레드 차단 방지 -> AVCaptureSession.startRunning() : 카메라 하드웨어를 초기화하는 작업.
        /// 성능 향상을 위해 비동기 처리.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
    }

    /// 카메라 세션 종료
    func stopCameraSession() {
        captureSession?.stopRunning()
    }

    /// 사진 촬영
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CaptureLicenseViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let photoData = photo.fileDataRepresentation(), let image = UIImage(data: photoData) else {
            print("사진 처리 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
            return
        }
        onPhotoCaptured?(image)
    }
}

