//
//  RidingViewModel.swift
//  ScooTracer
//
//  Created by mobicom on 12/10/24.
//

import UIKit
import AVFoundation
import Vision

class RidingViewModel: NSObject, AVCapturePhotoCaptureDelegate {

    // MARK: - Callbacks
    var onPermissionGranted: (() -> Void)?
    var onPermissionDenied: (() -> Void)?
    var onCameraSessionConfigured: ((AVCaptureSession) -> Void)?
    var onPhotoCaptured: ((Result<UIImage, Error>) -> Void)?

    private var captureSession: AVCaptureSession?
    private let photoOutput = AVCapturePhotoOutput() // 사진 출력을 위한 Output
    private var selfiePhoto: UIImage?
    private var errorCount = 0
    private let faceNetService = FaceNetService()

    override init() {
        super.init()
        selfiePhoto = loadSelfiePhotoFromKeychain()
    }

    // MARK: - Keychain에서 SelfiePhoto 로드
    private func loadSelfiePhotoFromKeychain() -> UIImage? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "selfiePhoto",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?

        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess, let data = dataTypeRef as? Data else {
            print("Keychain에서 selfiePhoto를 불러오지 못했습니다. 상태 코드: \(status)")
            return nil
        }

        return UIImage(data: data)
    }

    // MARK: - 얼굴 비교
    func compareFace(with image: UIImage, completion: @escaping (Float?, Int) -> Void) {
        guard let croppedFace = cropFaceFromImage(image) else {
            print("🚨 얼굴 크롭 실패: cropFaceFromImage 결과가 nil")
            completion(nil, errorCount)
            return
        }

        guard let selfiePhoto = selfiePhoto else {
            print("🚨 Keychain에서 selfiePhoto 불러오기 실패")
            completion(nil, errorCount)
            return
        }

        guard let resizedCurrent = croppedFace.resized(to: CGSize(width: 160, height: 160)) else { return }

        guard let resizedSelfie = selfiePhoto.resized(to: CGSize(width: 160, height: 160)) else { return }

        let similarity = faceNetService?.compare(image1: resizedSelfie, image2: resizedCurrent)
        if let similarity = similarity, similarity < 0.6 {
            errorCount += 1
        }

        print("✅ 얼굴 비교 성공: similarity = \(similarity ?? 0)")
        completion(similarity, errorCount)
    }


    // MARK: - 얼굴 크롭
    private func cropFaceFromImage(_ image: UIImage, targetAspectRatio: CGFloat = 1.0) -> UIImage? {
        guard let cgImage = image.correctedOrientation()?.cgImage else {
            print("🚨 이미지 cgImage 변환 실패")
            return nil
        }

        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            guard let firstFace = request.results?.first else {
                print("🚨 Vision 요청 실패: 얼굴 감지 결과 없음")
                return nil
            }

            // 얼굴 영역 계산
            let faceRect = calculateFaceRect(
                firstFace.boundingBox,
                imageSize: CGSize(width: cgImage.width, height: cgImage.height),
                targetAspectRatio: targetAspectRatio
            )

            // 얼굴 크롭
            guard let croppedImage = cropImage(image, to: faceRect) else {
                print("🚨 얼굴 크롭 실패")
                return nil
            }

            print("✅ 얼굴 크롭 성공")
            return croppedImage
        } catch {
            print("🚨 Vision 요청 오류: \(error.localizedDescription)")
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
        let expansionFactor: CGFloat = 0.2 // 얼굴을 조금 더 키우기
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

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("전면 카메라를 사용할 수 없습니다.")
            return
        }

        session.addInput(input)

        // Photo Output 추가
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        captureSession = session
        onCameraSessionConfigured?(session)
    }

    // MARK: - 사진 캡처
    func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("사진 처리 실패: \(error.localizedDescription)")
            onPhotoCaptured?(.failure(error)) // 실패 시 .failure 전달
            return
        }

        guard let photoData = photo.fileDataRepresentation(),
              let image = UIImage(data: photoData)?.correctedOrientation() else {
            print("사진 데이터를 변환할 수 없습니다.")
            let conversionError = NSError(domain: "CaptureError", code: -1, userInfo: [NSLocalizedDescriptionKey: "사진 데이터 변환 실패"])
            onPhotoCaptured?(.failure(conversionError)) // 변환 실패 시 .failure 전달
            return
        }

        onPhotoCaptured?(.success(image)) // 성공 시 .success 전달
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
}
