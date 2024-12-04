//
//  CaptureLicenseViewModel.swift
//  ScooTracer
//
//  Created by mobicom on 11/18/24.
//

import Vision
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

        captureSession = session
        onCameraSessionConfigured?(session)
    }

    // MARK: - 카메라 세션 제어
    func startCameraSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    func stopCameraSession() {
        captureSession?.stopRunning()
    }

    // MARK: - 사진 촬영
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - 얼굴 탐지 및 이미지 처리
    private func processCapturedImage(_ image: UIImage, expansionFactor: CGFloat = 0.5) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            guard let firstFace = request.results?.first else {
                print("얼굴을 감지하지 못했습니다.")
                return nil
            }

            let faceRect = calculateFaceRect(firstFace.boundingBox, imageSize: CGSize(width: cgImage.width, height: cgImage.height), expansionFactor: expansionFactor)
            return cropAndExpandImage(image, to: faceRect)
        } catch {
            print("얼굴 인식 실패: \(error.localizedDescription)")
            return nil
        }
    }

    private func calculateFaceRect(_ boundingBox: CGRect, imageSize: CGSize, expansionFactor: CGFloat) -> CGRect {
        let x = boundingBox.origin.x * imageSize.width
        let y = (1 - boundingBox.origin.y - boundingBox.size.height) * imageSize.height
        let width = boundingBox.size.width * imageSize.width
        let height = boundingBox.size.height * imageSize.height
        let rect = CGRect(x: x, y: y, width: width, height: height)

        // 확장된 영역 계산
        let expandedRect = rect.insetBy(dx: -rect.width * expansionFactor, dy: -rect.height * expansionFactor)

        // 원본 이미지 경계를 초과하지 않도록 조정
        return expandedRect.intersection(CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
    }

    private func cropAndExpandImage(_ image: UIImage, to rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        // 크롭 영역이 유효하지 않을 경우 nil 반환
        guard let croppedCgImage = cgImage.cropping(to: rect) else {
            print("크롭 영역이 잘못되었습니다.")
            return nil
        }

        // UIImage 생성 시 원본 스케일 및 방향 유지
        return UIImage(cgImage: croppedCgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    // MARK: - Keychain 저장
    private func saveToKeychain(_ faceImage: UIImage) {
        guard let imageData = faceImage.jpegData(compressionQuality: 0.8) else {
            print("얼굴 이미지 데이터 변환 실패")
            return
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "capturedFace",
            kSecValueData as String: imageData
        ]

        SecItemDelete(query as CFDictionary) // 기존 항목 삭제
        let status = SecItemAdd(query as CFDictionary, nil)

        print(status == errSecSuccess ? "얼굴 이미지 KeyChain에 저장 성공" : "KeyChain 저장 실패: \(status)")
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CaptureLicenseViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoData = photo.fileDataRepresentation(), let image = UIImage(data: photoData) else {
            print("사진 처리 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
            return
        }

        let rotatedImage = rotateImage(image, by: 90)
        if let faceImage = processCapturedImage(rotatedImage) {
            saveToKeychain(faceImage)
            onPhotoCaptured?(faceImage)
        } else {
            print("얼굴 인식 실패")
        }
    }

    private func rotateImage(_ image: UIImage, by degrees: CGFloat) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let radians = degrees * .pi / 180
        let newSize = CGSize(width: image.size.height, height: image.size.width)

        UIGraphicsBeginImageContext(newSize)
        guard let context = UIGraphicsGetCurrentContext() else { return image }

        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: radians)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))

        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage ?? image
    }
}
