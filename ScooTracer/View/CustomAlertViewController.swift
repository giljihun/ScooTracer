//
//  CustomAlertViewController.swift
//  ScooTracer
//
//  Created by mobicom on 12/7/24.
//

import UIKit

class CustomAlertViewController: UIViewController {

    private let image: UIImage
    private let onRetake: (() -> Void)?

    init(image: UIImage, onRetake: (() -> Void)? = nil) {
        self.image = image
        self.onRetake = onRetake
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        // 컨테이너 뷰
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        // 레이블
        let titleLabel = UILabel()
        titleLabel.text = "당신의 사진이 맞나요?"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // 이미지 뷰
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowOffset = CGSize(width: 2, height: 2)
        imageView.layer.shadowRadius = 4
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)

        // 버튼 스택 뷰
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 8
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(buttonStackView)

        // 확인 버튼
        let confirmButton = createStyledButton(title: "확인", backgroundColor: .systemBlue)
        confirmButton.addTarget(self, action: #selector(confirmAlert), for: .touchUpInside)
        buttonStackView.addArrangedSubview(confirmButton)

        // 재촬영 버튼
        let retakeButton = createStyledButton(title: "재촬영", backgroundColor: .systemGray)
        retakeButton.addTarget(self, action: #selector(retakePhoto), for: .touchUpInside)
        buttonStackView.addArrangedSubview(retakeButton)

        // 이미지 비율 계산
        let imageAspectRatio = image.size.width / image.size.height
        let imageHeight: CGFloat = 200
        let imageWidth: CGFloat = imageHeight * imageAspectRatio

        // 레이아웃 설정
        NSLayoutConstraint.activate([
            // 컨테이너
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 330),

            // 레이블
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            // 이미지 뷰
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: min(260, imageWidth)),
            imageView.heightAnchor.constraint(equalToConstant: min(180, imageHeight)),

            // 버튼 스택
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }


    private func createStyledButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 8
        return button
    }

    @objc private func confirmAlert() {
        dismiss(animated: true) {
            // 현재 활성화된 UIWindowScene을 가져옴
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let navigationController = window.rootViewController as? UINavigationController {

                // SelfieCaptureViewController로 이동
                let selfieVC = SelfieCaptureViewController()
                navigationController.pushViewController(selfieVC, animated: true)
            } else {
                print("네비게이션 컨트롤러를 찾을 수 없습니다.")
            }
        }
    }

    @objc private func retakePhoto() {
        dismiss(animated: true) {
            self.onRetake?()
        }
    }

    // MARK: - 뷰 이동
    @objc private func goToSelfieView() {
        let selfieVC = SelfieCaptureViewController()
        selfieVC.modalTransitionStyle = .crossDissolve
        selfieVC.modalPresentationStyle = .fullScreen
        self.present(selfieVC, animated: true, completion: nil)
    }
}
