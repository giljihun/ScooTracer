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

    // MARK: - 생명 주기 메서드

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // ViewModel과 ViewController 간 데이터 연동
        observeViewModel()

        // 카메라 권한 확인 요청
        viewModel.checkCameraAuthorization()
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

    // MARK: - 면허증 테두리

    /// 면허증을 맞추기 위한 가이드 테두리를 설정
    private func setupLicenseBorder() {
        licenseBorderView.layer.borderColor = UIColor.red.cgColor
        licenseBorderView.layer.borderWidth = 2.0
        licenseBorderView.backgroundColor = .clear
        view.addSubview(licenseBorderView)
        licenseBorderView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            licenseBorderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            licenseBorderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            licenseBorderView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            licenseBorderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3)
        ])
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


