//
//  File.swift
//  ScooTracer
//
//  Created by mobicom on 12/7/24.
//

import AVFoundation
import UIKit
import Vision

class SelfieCaptureViewModel: NSObject {

    // MARK: - Properties
    var onPermissionGranted: (() -> Void)?
    var onPermissionDenied: (() -> Void)?
    var onCameraSessionConfigured: ((AVCaptureSession) -> Void)?
    var onPhotoCaptured: ((Result<UIImage, Error>) -> Void)?

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

    // MARK: - 사진 촬영
    func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        photoOutput.capturePhoto(with: settings, delegate: self)

        self.onPhotoCaptured = completion
    }

    // MARK: - 얼굴 탐지 및 비율 조정
    private func processCapturedImage(_ image: UIImage, targetAspectRatio: CGFloat = 1.0) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            // 얼굴 탐지 실행
            try handler.perform([request])
            guard let firstFace = request.results?.first else {
                print("얼굴을 감지하지 못했습니다.")
                return nil
            }

            // 얼굴 영역 계산 (비율 조정)
            let faceRect = calculateFaceRect(firstFace.boundingBox, imageSize: CGSize(width: cgImage.width, height: cgImage.height), targetAspectRatio: targetAspectRatio)

            // 얼굴 크롭
            guard let croppedImage = cropImage(image, to: faceRect) else {
                print("크롭된 이미지를 생성하지 못했습니다.")
                return nil
            }

            return croppedImage
        } catch {
            print("얼굴 탐지 실패: \(error.localizedDescription)")
            return nil
        }
    }

    private func calculateFaceRect(_ boundingBox: CGRect, imageSize: CGSize, targetAspectRatio: CGFloat) -> CGRect {
        // Vision 좌표계를 UIKit 좌표계로 변환
        let x = boundingBox.origin.x * imageSize.width
        let y = (1.0 - boundingBox.origin.y - boundingBox.height) * imageSize.height
        let width = boundingBox.width * imageSize.width
        let height = boundingBox.height * imageSize.height

        var rect = CGRect(x: x, y: y, width: width, height: height)

        // 비율에 맞춰 영역 확장
        let currentAspectRatio = rect.width / rect.height
        if currentAspectRatio > targetAspectRatio {
            // 현재 영역이 더 넓음 → 세로를 확장
            let newHeight = rect.width / targetAspectRatio
            let heightDiff = newHeight - rect.height
            rect.origin.y -= heightDiff / 2
            rect.size.height = newHeight
        } else {
            // 현재 영역이 더 좁음 → 좌우를 확장
            let newWidth = rect.height * targetAspectRatio
            let widthDiff = newWidth - rect.width
            rect.origin.x -= widthDiff / 2
            rect.size.width = newWidth
        }

        // 추가 확장 (전체적으로 키우기)
        let expansionFactor: CGFloat = 0.2
        rect = rect.insetBy(dx: -rect.width * expansionFactor, dy: -rect.height * expansionFactor)

        // 원본 이미지 경계를 초과하지 않도록 조정
        let imageBounds = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        return rect.intersection(imageBounds)
    }

    private func cropImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        // 크롭 영역 계산
        guard let croppedCgImage = cgImage.cropping(to: rect) else {
            print("크롭 영역이 잘못되었습니다.")
            return nil
        }

        // UIImage로 반환
        return UIImage(cgImage: croppedCgImage, scale: image.scale, orientation: image.imageOrientation)
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

    print(status == errSecSuccess ? "본인 얼굴 이미지 KeyChain에 저장 성공" : "KeyChain 저장 실패: \(status), \(kSecAttrAccount)")
}

// MARK: - AVCapturePhotoCaptureDelegate
extension SelfieCaptureViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("사진 처리 실패: \(error.localizedDescription)")
            onPhotoCaptured?(.failure(error))
            return
        }

        guard let photoData = photo.fileDataRepresentation(),
              let image = UIImage(data: photoData) else {
            let error = NSError(domain: "PhotoCaptureError", code: -1, userInfo: [NSLocalizedDescriptionKey: "사진 데이터 변환 실패"])
            onPhotoCaptured?(.failure(error))
            return
        }

        if let faceImage = processCapturedImage((image.correctedOrientation()?.flippedHorizontally())!, targetAspectRatio: 1.0) { // 1:1 비율
            saveToKeychain(faceImage)
            onPhotoCaptured?(.success(faceImage))
        } else {
            let error = NSError(domain: "FaceDetectionError", code: -2, userInfo: [NSLocalizedDescriptionKey: "얼굴을 인식하지 못했어요!"])
            onPhotoCaptured?(.failure(error))
        }
    }
}
