//
//  SelfieCaptureViewController.swift
//  ScooTracer
//
//  Created by mobicom on 12/7/24.
//

import UIKit
import AVFoundation

class SelfieCaptureViewController: UIViewController {

    // MARK: - Properties
    private let viewModel = SelfieCaptureViewModel()
    private var previewLayer: AVCaptureVideoPreviewLayer?

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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        observeViewModel()
        viewModel.checkCameraAuthorization()
        setupCaptureButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // 면허증 촬영 가이드 Alert
        showGuideAlert()
    }

    // MARK: - ViewModel Binding
    private func observeViewModel() {
        viewModel.onPermissionGranted = { [weak self] in
            self?.viewModel.setupCameraSession()
        }

        viewModel.onPermissionDenied = { [weak self] in
            self?.showPermissionDeniedAlert()
        }

        viewModel.onCameraSessionConfigured = { [weak self] session in
            self?.setupPreviewLayer(with: session)
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

    // MARK: - Camera Setup
    private func setupPreviewLayer(with session: AVCaptureSession) {
        previewLayer?.removeFromSuperlayer() // 기존 레이어 제거
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0) // 맨 뒤에 삽입
        self.previewLayer = previewLayer

        viewModel.startCameraSession()

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

    /// 면허증 촬영 가이드 알림 창 표시
    private func showGuideAlert() {
        let alert = UIAlertController(
            title: "본인 얼굴 촬영 가이드 😎",
            message: "\n얼굴이 화면의 80% 이상 나오도록 촬영해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.removeBlurEffect()
        })
        present(alert, animated: true)
    }

    private func showCapturedImageAlert(image: UIImage) {
        let alertVC = CustomAlertViewController(image: image) {
            self.viewModel.startCameraSession() // 재촬영 로직
        }
        present(alertVC, animated: true)
    }

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
