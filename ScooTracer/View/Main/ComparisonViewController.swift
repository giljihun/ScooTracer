//
//  ComparisonViewController.swift
//  ScooTracer
//
//  Created by mobicom on 12/10/24.
//

import UIKit

class ComparisonViewController: UIViewController {

    // MARK: - Properties
    private let viewModel = ComparisonViewModel()

    private let licenseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
//        imageView.layer.borderColor = UIColor.lightGray.cgColor
//        imageView.layer.borderWidth = 1
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowOffset = CGSize(width: 3, height: 3)
        imageView.layer.shadowRadius = 5
        imageView.alpha = 0
        return imageView
    }()

    private let selfieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
//        imageView.layer.borderColor = UIColor.lightGray.cgColor
//        imageView.layer.borderWidth = 1
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowOffset = CGSize(width: 3, height: 3)
        imageView.layer.shadowRadius = 5
        imageView.alpha = 0
        return imageView
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("재검사하기", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        return button
    }()

    private let XIconView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 0 // 애니메이션 전에 숨김 상태
        return view
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        return button
    }()

    private let checkIconView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 0 // 애니메이션 전에 숨김 상태
        return view
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupActions()
        startComparison()

        nextButton.addTarget(self, action: #selector(goToMainView), for: .touchUpInside)
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(licenseImageView)
        view.addSubview(selfieImageView)
        view.addSubview(statusLabel)
        view.addSubview(retryButton)
        view.addSubview(nextButton)
        view.addSubview(XIconView)
        view.addSubview(checkIconView)

        NSLayoutConstraint.activate([
            // License ImageView Constraints
            licenseImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            licenseImageView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            licenseImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 170), // 위치를 더 아래로 이동
            licenseImageView.heightAnchor.constraint(equalToConstant: 158),

            // Selfie ImageView Constraints
            selfieImageView.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            selfieImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selfieImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 170), // 위치를 더 아래로 이동
            selfieImageView.heightAnchor.constraint(equalToConstant: 158),

            // Status Label Constraints
            statusLabel.topAnchor.constraint(equalTo: licenseImageView.bottomAnchor, constant: 50), // 아래로 이동
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Retry Button Constraints
            retryButton.topAnchor.constraint(equalTo: XIconView.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 120),
            retryButton.heightAnchor.constraint(equalToConstant: 40),

            // Next Button Constraints
            nextButton.topAnchor.constraint(equalTo: checkIconView.bottomAnchor, constant: 20),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 120),
            nextButton.heightAnchor.constraint(equalToConstant: 40),

            // Check Icon Constraints
            checkIconView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            checkIconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkIconView.widthAnchor.constraint(equalToConstant: 50),
            checkIconView.heightAnchor.constraint(equalToConstant: 50),

            // Check Icon Constraints
            XIconView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            XIconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            XIconView.widthAnchor.constraint(equalToConstant: 50),
            XIconView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    // MARK: - Actions Setup
    private func setupActions() {
        retryButton.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
    }

    // MARK: - Comparison Logic
    private func startComparison() {
        UIView.animate(withDuration: 1.0) {
            self.licenseImageView.alpha = 1.0
            self.selfieImageView.alpha = 1.0
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let targetSize = CGSize(width: 160, height: 160)
            guard let licenseImage = self.viewModel.loadAndResizeImage(for: "licensePhoto", targetSize: targetSize),
                  let selfieImage = self.viewModel.loadAndResizeImage(for: "selfiePhoto", targetSize: targetSize) else {
                DispatchQueue.main.async {
                    self.statusLabel.text = "이미지를 불러오지 못했습니다."
                    self.statusLabel.alpha = 1.0
                }
                return
            }

            DispatchQueue.main.async {
                self.licenseImageView.image = licenseImage
                self.selfieImageView.image = selfieImage
            }

            let similarity = self.viewModel.compareImages(licenseImage: licenseImage, selfieImage: selfieImage)

            print("정확도: \(similarity!)")

            DispatchQueue.main.async {
                // TODO: - 임계점 임시 설정 ..
                if let similarity = similarity, similarity > 0.6 {
                    self.showSuccess()
                } else {
                    self.showFailure()
                }
            }
        }
    }

    private func showSuccess() {
        statusLabel.text = "검사가 완료되었습니다."
        UIView.animate(withDuration: 1.0) {
            self.statusLabel.alpha = 1.0
            self.nextButton.alpha = 1.0
        }
        animateCheckIcon()
    }


    private func showFailure() {
        statusLabel.text = "본인이 아닌 것 같아요.\n재검사를 진행할게요."
        UIView.animate(withDuration: 1.0) {
            self.statusLabel.alpha = 1.0
            self.retryButton.alpha = 1.0
        }
        animateXIcon()
    }

    private func animateCheckIcon() {
        // 체크 아이콘을 CoreAnimation으로 그리기
        let checkPath = UIBezierPath()
        checkPath.move(to: CGPoint(x: 10, y: 25))
        checkPath.addLine(to: CGPoint(x: 20, y: 35))
        checkPath.addLine(to: CGPoint(x: 40, y: 10))

        let checkLayer = CAShapeLayer()
        checkLayer.path = checkPath.cgPath
        checkLayer.strokeColor = #colorLiteral(red: 0.1822504402, green: 0.6936355745, blue: 0.2316807986, alpha: 1)
        checkLayer.fillColor = UIColor.clear.cgColor
        checkLayer.lineWidth = 4
        checkLayer.lineCap = .round

        // 기존 레이어 제거 후 새 레이어 추가
        checkIconView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        checkIconView.layer.addSublayer(checkLayer)

        // 애니메이션 설정
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.2 // 애니메이션 시간을 늘림 (1.5초)
        checkLayer.add(animation, forKey: "checkAnimation")

        // 체크 아이콘 전체 크기 애니메이션
        UIView.animate(withDuration: 1.8) { // UIView 애니메이션도 더 느리게
            self.checkIconView.alpha = 1.0
            self.checkIconView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        } completion: { _ in
            UIView.animate(withDuration: 0.5) { // 복구 애니메이션은 조금 빠르게
                self.checkIconView.transform = .identity
            }
        }
    }

    private func animateXIcon() {
        // X 아이콘을 CoreAnimation으로 그리기
        let xPath = UIBezierPath()
        xPath.move(to: CGPoint(x: 10, y: 10)) // 대각선 시작점
        xPath.addLine(to: CGPoint(x: 40, y: 40)) // 대각선 끝점
        xPath.move(to: CGPoint(x: 40, y: 10)) // 반대 대각선 시작점
        xPath.addLine(to: CGPoint(x: 10, y: 40)) // 반대 대각선 끝점

        let xLayer = CAShapeLayer()
        xLayer.path = xPath.cgPath
        xLayer.strokeColor = UIColor.red.cgColor // 빨간색 설정
        xLayer.fillColor = UIColor.clear.cgColor
        xLayer.lineWidth = 4
        xLayer.lineCap = .round

        // 기존 레이어 제거 후 새 레이어 추가
        XIconView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        XIconView.layer.addSublayer(xLayer)

        // 애니메이션 설정
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 1.2 // 애니메이션 지속 시간
        xLayer.add(animation, forKey: "xAnimation")

        // X 아이콘 전체 크기 애니메이션
        UIView.animate(withDuration: 1.8) {
            self.XIconView.alpha = 1.0
            self.XIconView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        } completion: { _ in
            UIView.animate(withDuration: 0.5) {
                self.XIconView.transform = .identity
            }
        }
    }

    // MARK: - Actions
    @objc private func handleRetry() {
        // 재검사 로직: CaptureLicenseView로 이동
        let captureLicenseVC = CaptureLicenseViewController()
        navigationController?.pushViewController(captureLicenseVC, animated: true)
    }

    @objc private func goToMainView() {
        let mainVC = MainViewController()
        mainVC.modalPresentationStyle = .fullScreen
        present(mainVC, animated: true, completion: nil)
    }
}
