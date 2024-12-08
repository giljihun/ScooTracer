//
//  CaptureLicenseViewController.swift
//  ScooTracer
//
//  Created by mobicom on 11/18/24.
//

import UIKit
import AVFoundation

class CaptureLicenseViewController: UIViewController {

    // MARK: - 카메라 구현 절차!
    /*
     AVFoundation을 사용한 카메라 구현의 기본 절차

     1. 세션 설정
     - AVCaptureSession 초기화
     : 입력(카메라 장치)과 출력(사진/비디오 데이터)을 연결할 세션을 생성.

     - 입력 설정
     : AVCaptureDevice로 카메라 장치를 선택 (전면/후면, 타입 등).
     AVCaptureDeviceInput으로 선택한 장치를 세션에 추가.

     - 출력 설정 (옵션)
     원하는 경우, 데이터를 캡처하기 위한 출력(예: AVCapturePhotoOutput 등)을 추가.

     - 프리뷰 설정
     : AVCaptureVideoPreviewLayer를 사용해 실시간 카메라 데이터를 화면에 표시.

     2. 세션 실행
     - 세션 시작: captureSession.startRunning()
     - 세션 중지: captureSession.stopRunning()
     */

    // MARK: - Properties

    /// 카메라 관련 로직과 세션 관리를 처리하는 ViewModel
    private let viewModel = CaptureLicenseViewModel()

    /// 실시간 카메라 데이터를 화면에 표시하는 레이어
    private var previewLayer: AVCaptureVideoPreviewLayer?

    /// 면허증 인식을 돕는 테두리를 표시하는 뷰
    private let licenseBorderView = UIView()

    /// 카메라 화면에 흐림 효과를 추가하기 위한 뷰
    private var blurView: UIVisualEffectView?

    /// 촬영 버튼
    private let whiteCircle: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 35 // 동그라미
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let captureButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear // 내부는 투명
        button.layer.borderColor = UIColor.white.cgColor // 검은 테두리
        button.layer.borderWidth = 2.5
        button.layer.cornerRadius = 40
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - 생명 주기 메서드

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // ViewModel과 ViewController 간 데이터 연동
        observeViewModel()
        viewModel.checkCameraAuthorization()
        setupCaptureButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 면허증 촬영 가이드 Alert
        showGuideAlert()
    }

    // MARK: - ViewModel 관찰

    /// ViewModel의 이벤트와 ViewController의 동작을 연결
    private func observeViewModel() {
        viewModel.onPermissionGranted = { [weak self] in
            self?.viewModel.setupCameraSession()
        }

        viewModel.onPermissionDenied = { [weak self] in
            self?.showPermissionDeniedAlert()
        }

        viewModel.onCameraSessionConfigured = { [weak self] session in
            self?.setupCameraPreview(with: session)
        }

        viewModel.onPhotoCaptured = { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self?.showCapturedImageAlert(image: image)
                case .failure:
                    self?.showToast(message: "얼굴을 인식하지 못했습니다.", duration: 2.0)
                }
            }
        }
    }

    // MARK: - 카메라 설정

    /// 카메라 세션 설정
    private func setupCameraPreview(with session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer

        // 카메라 세션 시작
        viewModel.startCameraSession()

        // Alert 창에서 카메라 흐림 효과
        addBlurEffect()
    }

    /// 촬영 버튼 설정
    private func setupCaptureButton() {
        // 하얀 동그라미 추가
        view.addSubview(whiteCircle)
        NSLayoutConstraint.activate([
            whiteCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            whiteCircle.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            whiteCircle.widthAnchor.constraint(equalToConstant: 70),
            whiteCircle.heightAnchor.constraint(equalToConstant: 70)
        ])

        // 검은 테두리 버튼 추가
        view.addSubview(captureButton)
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: whiteCircle.centerXAnchor),
            captureButton.centerYAnchor.constraint(equalTo: whiteCircle.centerYAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 80),
            captureButton.heightAnchor.constraint(equalToConstant: 80)
        ])

        // 버튼 액션 추가
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(captureButtonTouchDown), for: .touchDown)
        captureButton.addTarget(self, action: #selector(captureButtonTouchUp), for: [.touchUpInside, .touchUpOutside])
    }


    @objc private func captureButtonTapped() {
        animateCaptureButton()
        showLoading() // 로딩 시작

        viewModel.capturePhoto { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoading() // 로딩 숨김
                switch result {
                case .success(let image):
                    // 성공 시 CustomAlertViewController를 표시
                    let alertVC = CustomAlertViewController(image: image) {
                        // 재촬영 로직
                        self?.viewModel.startCameraSession()
                    }
                    self?.present(alertVC, animated: true)
                case .failure(let error):
                    // 실패 시 토스트 메시지 표시
                    self?.showToast(message: "\(error.localizedDescription)", duration: 2.0)
                    self?.viewModel.startCameraSession() // 세션 재시작
                }
            }
        }
    }

    @objc private func captureButtonTouchDown() {
        UIView.animate(withDuration: 0.1, animations: {
            self.whiteCircle.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        })
    }

    @objc private func captureButtonTouchUp() {
        UIView.animate(withDuration: 0.1, animations: {
            self.whiteCircle.transform = .identity
        })
    }

    private func animateCaptureButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.whiteCircle.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.whiteCircle.transform = .identity
            }
        }
    }

    // MARK: - 알림 창

    /// 카메라 권한이 없을 경우 사용자에게 알림 -> 설정창 이동
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "카메라 권한 필요",
            message: "설정에서 카메라 권한을 허용해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }

    /// 면허증 촬영 가이드 알림 창 표시
    private func showGuideAlert() {
        let alert = UIAlertController(
            title: "면허증 촬영 가이드 🚀",
            message: "\n면허증을 테두리 안에 맞추어 촬영해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.setupLicenseBorder()
            self?.removeBlurEffect()
        })
        present(alert, animated: true)
    }

    private func showCapturedImageAlert(image: UIImage) {
        let alertVC = CustomAlertViewController(image: image) { [weak self] in
            self?.viewModel.startCameraSession() // 재촬영 로직
        }
        present(alertVC, animated: true)
    }

    /// 토스트 메시지 표시
    private func showToast(message: String, duration: TimeInterval) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toastLabel.layer.cornerRadius = 8
        toastLabel.clipsToBounds = true
        toastLabel.alpha = 0
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastLabel)

        NSLayoutConstraint.activate([
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.widthAnchor.constraint(equalToConstant: 190),
            toastLabel.heightAnchor.constraint(equalToConstant: 35)
        ])

        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: [], animations: {
                toastLabel.alpha = 0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }


    // MARK: - 면허증 테두리

    /// 면허증을 맞추기 위한 가이드 테두리를 설정
    private func setupLicenseBorder() {
        // 1. 전체 화면 크기와 테두리 영역 크기 정의
        let overlayPath = UIBezierPath(rect: view.bounds)
        // 중앙에 배치된 상자 프레임 계산
        let rectWidth = view.bounds.width - 60
        let rectHeight = view.bounds.height / 4
        let rectX = (view.bounds.width - rectWidth) / 2 // 가로 중앙
        let rectY = (view.bounds.height - rectHeight) / 2 // 세로 중앙
        let rectFrame = CGRect(x: rectX, y: rectY, width: rectWidth, height: rectHeight)
        let rectPath = UIBezierPath(roundedRect: rectFrame, cornerRadius: 20)

        // 2. 내부를 투명하게 하기 위해 경로를 반전
        overlayPath.append(rectPath)
        overlayPath.usesEvenOddFillRule = true

        // 3. 어두운 배경 레이어 설정
        let fillLayer = CAShapeLayer()
        fillLayer.path = overlayPath.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        view.layer.addSublayer(fillLayer)

        // 4. 테두리 레이어 설정
        let borderLayer = CAShapeLayer()
        borderLayer.path = rectPath.cgPath
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineWidth = 4
        borderLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(borderLayer)

        // 5. 중앙 메시지 추가
        let guideLabel = UILabel()
        guideLabel.text = "가이드 라인에 신분증을 맞춰주세요."
        guideLabel.textColor = .white
        guideLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        guideLabel.textAlignment = .center
        guideLabel.numberOfLines = 0
        view.addSubview(guideLabel)

        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: rectFrame.origin.y + rectFrame.height + 20)
        ])

        /// 촬영 버튼이 상단으로 오도록 계층 조정
        view.bringSubviewToFront(whiteCircle)
        view.bringSubviewToFront(captureButton)

    }

    // MARK: - 흐림 효과

    /// 흐림 효과를 추가 (Alert 창 present 상태)
    private func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        self.blurView = blurView
    }

    /// 흐림 효과를 서서히 제거
    private func removeBlurEffect() {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView?.alpha = 0
        }, completion: { _ in
            self.blurView?.removeFromSuperview()
            self.blurView = nil
        })
    }
}


