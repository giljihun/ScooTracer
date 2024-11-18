//
//  CaptureLicenseViewModel.swift
//  ScooTracer
//
//  Created by mobicom on 11/18/24.
//

import AVFoundation

class CaptureLicenseViewModel {

    // MARK: - Properties
    var onPermissionGranted: (() -> Void)?
    var onPermissionDenied: (() -> Void)?
    var onCameraSessionConfigured: ((AVCaptureSession) -> Void)?

    private var captureSession: AVCaptureSession?

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
        self.captureSession = session
        onCameraSessionConfigured?(session)
    }

    /// 카메라 세션 시작
    func startCameraSession() {
        captureSession?.startRunning()
    }

    /// 카메라 세션 종료
    func stopCameraSession() {
        captureSession?.stopRunning()
    }
}

