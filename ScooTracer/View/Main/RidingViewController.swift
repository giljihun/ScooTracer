//
//  RidingViewController.swift
//  ScooTracer
//
//  Created by mobicom on 12/10/24.
//

import UIKit
import AVFoundation

class RidingViewController: UIViewController {

    // MARK: - Properties
    private let viewModel = RidingViewModel()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var blurView: UIVisualEffectView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupViewModel()
        viewModel.checkCameraAuthorization()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showGuideAlert()
    }

    // MARK: - ViewModel 연결
    private func setupViewModel() {
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

    // MARK: - 카메라 화면 설정
    private func setupCameraPreview(with session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.cornerRadius = 20
        previewLayer.masksToBounds = true
        previewLayer.frame = CGRect(
            x: view.bounds.width * 0.1, // 좌우 10% 여백
            y: view.bounds.height * 0.2, // 위쪽 20% 여백
            width: view.bounds.width * 0.8, // 전체 너비의 80%
            height: view.bounds.height * 0.5 // 전체 높이의 50%
        )
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer

        addBlurEffect()

        // 카메라 세션 시작
        viewModel.startCameraSession()
    }

    // MARK: - Alerts
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

    private func showGuideAlert() {
        let alert = UIAlertController(
            title: "주행 가이드 🛴",
            message: "\n1. 카메라에 본인의 모습이 잘 나오는지 확인해주세요.😎\n\n2. 총 3번의 이상 얼굴 탐지 시, 즉시 운행을 종료합니다.✋\n\n3. 음주 운전은 절대 안됩니다~~!!😵\n",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "네!", style: .default) { [weak self] _ in
            self?.removeBlurEffect()
        })
        present(alert, animated: true)
    }

    // MARK: - 흐림 효과
    private func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        self.blurView = blurView
    }

    private func removeBlurEffect() {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView?.alpha = 0
        }, completion: { _ in
            self.blurView?.removeFromSuperview()
            self.blurView = nil
        })
    }

    // MARK: - Deinitialization
    deinit {
        viewModel.stopCameraSession()
    }
}
