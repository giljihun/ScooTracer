//
//  RidingViewController.swift
//  ScooTracer
//
//  Created by mobicom on 12/10/24.
//

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
    private let logoImageView = UIImageView()
    private var timer: Timer? // 얼굴 비교를 위한 타이머
    private let capturedImageView = UIImageView() // 캡처된 이미지를 표시할 이미지뷰
    private var detectionWrongLogos: [UIImageView] = [] // 로고를 저장할 배열

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "모든 것이 정상입니다. 😊"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupViewModel()
        viewModel.checkCameraAuthorization()
        setupLogoImageView()
        setupStatusLabel()
        setupCapturedImageView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showGuideAlert()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate() // 타이머 정리
        viewModel.stopCameraSession()
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

        viewModel.onPhotoCaptured = { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    // 캡처된 이미지를 이미지뷰에 표시
                    self?.capturedImageView.image = image.flippedHorizontally()
                    print("사진 캡처 성공")

                    // 프리뷰 애니메이션
                    self?.animatePreviewLayer()

                    // 얼굴 비교 수행
                    self?.viewModel.compareFace(with: image) { similarity, errorCount in
                        DispatchQueue.main.async {

                            if let similarity = similarity, similarity < 0.6 {
                                print("유사도가 낮음: \(similarity)")
                                self?.addDetectionWrongLogo()
                            } else if similarity == nil {
                                print("얼굴 비교 실패")
                                self?.addDetectionWrongLogo()
                            }

                            print("현재 에러 카운트: \(errorCount)")

                            if errorCount >= 3 {
                                self?.presentErrorAlert()
                            }
                        }
                    }

                case .failure(let error):
                    print("사진 캡처 실패: \(error.localizedDescription)")
                }
            }
        }
    }


    // MARK: - 카메라 화면 설정
    private func setupCameraPreview(with session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.cornerRadius = 20
        previewLayer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        previewLayer.borderWidth = 4
        previewLayer.shadowColor = UIColor.black.cgColor
        previewLayer.shadowOffset = CGSize(width: 0, height: 4)
        previewLayer.shadowOpacity = 0.3
        previewLayer.shadowRadius = 8
        previewLayer.masksToBounds = true
        previewLayer.frame = CGRect(
            x: view.bounds.width * 0.1,
            y: view.bounds.height * 0.2,
            width: view.bounds.width * 0.8,
            height: view.bounds.height * 0.5
        )
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer

        viewModel.startCameraSession()
        startFaceDetectionTimer()
    }

    // MARK: - 로고 이미지
    private func setupLogoImageView() {
        logoImageView.image = UIImage(named: "Logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    // MARK: - 캡처된 이미지뷰 설정
    private func setupCapturedImageView() {
        capturedImageView.contentMode = .scaleAspectFit
        capturedImageView.layer.borderWidth = 2
        capturedImageView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        capturedImageView.layer.cornerRadius = 16
        capturedImageView.clipsToBounds = true
        capturedImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(capturedImageView)

        NSLayoutConstraint.activate([
            capturedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            capturedImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -320),
            capturedImageView.widthAnchor.constraint(equalToConstant: 81),
            capturedImageView.heightAnchor.constraint(equalToConstant: 100)
        ])

        addBlurEffect()
    }

    // MARK: - 얼굴 탐지 타이머
    private func startFaceDetectionTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.captureAndCompareFace()
        }
    }

    // MARK: - 얼굴 캡처 및 비교
    private func captureAndCompareFace() {
        // 단순히 사진 캡처를 트리거하는 역할
        viewModel.capturePhoto { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let capturedImage):
                    print("사진 캡처 성공: \(capturedImage.size)")
                    // 캡처된 이미지를 ViewModel의 onPhotoCaptured로 전달
                    self?.viewModel.onPhotoCaptured?(.success(capturedImage))

                case .failure(let error):
                    print("사진 캡처 실패: \(error.localizedDescription)")
                    self?.viewModel.onPhotoCaptured?(.failure(error))
                }
            }
        }
    }


    // MARK: - 프리뷰 애니메이션
    private func animatePreviewLayer() {
        guard let previewLayer = self.previewLayer else { return }

        // 프리뷰 레이어 확대 -> 축소 애니메이션
        let originalTransform = previewLayer.affineTransform()
        let scaledTransform = originalTransform.scaledBy(x: 1.1, y: 1.1)

        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        previewLayer.setAffineTransform(scaledTransform)
        CATransaction.commit()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)
            previewLayer.setAffineTransform(originalTransform)
            CATransaction.commit()
        }
    }

    // MARK: - 알림 및 종료
    private func presentErrorAlert() {
        let alert = UIAlertController(
            title: "운행 종료",
            message: "얼굴 검증 실패 3회로 운행이 종료됩니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
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
            message: """
            1. 카메라에 본인의 모습이 잘 나오는지 확인해주세요.😎
            2. 총 3번의 이상 얼굴 탐지 시, 즉시 운행을 종료합니다.✋
            3. 음주 운전은 절대 안됩니다~~!!😵
            """,
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

    // MARK: - 에러 로고 등장
    private func addDetectionWrongLogo() {
        guard detectionWrongLogos.count < 3 else { return } // 최대 3개만 추가

        let logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "detectionWrong") // 로고 이미지 설정
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.alpha = 0 // 초기 상태는 투명
        view.addSubview(logoImageView)

        detectionWrongLogos.append(logoImageView) // 배열에 추가

        removeStatusLabelIfNeeded()

        // 로고 크기와 간격 설정
        let logoSize: CGFloat = 80
        let logoSpacing: CGFloat = 20
        let logoCount = detectionWrongLogos.count

        // 전체 너비와 시작 X 좌표 계산
        let totalWidth = (CGFloat(logoCount) * logoSize) + (CGFloat(logoCount - 1) * logoSpacing)
        let startingX = (view.bounds.width - totalWidth) / 2

        for (index, logo) in detectionWrongLogos.enumerated() {
            NSLayoutConstraint.activate([
                logo.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -66), // 하단 고정
                logo.widthAnchor.constraint(equalToConstant: logoSize), // 고정 너비
                logo.heightAnchor.constraint(equalToConstant: logoSize), // 고정 높이
                logo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: startingX + CGFloat(index) * (logoSize + logoSpacing)) // 위치 계산
            ])
        }

        // 등장 애니메이션
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            logoImageView.alpha = 1
            logoImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                logoImageView.transform = .identity
            }
        }
    }

    // MARK: - 검출 상태 체크
    private func setupStatusLabel() {
        view.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }

    private func removeStatusLabelIfNeeded() {
        guard !detectionWrongLogos.isEmpty else { return } // 로고가 없으면 아무 작업도 하지 않음
        statusLabel.removeFromSuperview()
    }


    // MARK: - Deinitialization
    deinit {
        viewModel.stopCameraSession()
    }
}
