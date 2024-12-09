//
//  ComparisonViewController.swift
//  ScooTracer
//
//  Created by mobicom on 12/9/24.
//

import UIKit
import CoreML

class ComparisonViewController: UIViewController {

    // MARK: - Properties
    private let viewModel = ComparisonViewModel()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "사진을 비교 중입니다..."
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let licenseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()

    private let selfieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        startComparison()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(licenseImageView)
        view.addSubview(selfieImageView)
        view.addSubview(activityIndicator)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            // License ImageView Constraints
            licenseImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            licenseImageView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            licenseImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            licenseImageView.heightAnchor.constraint(equalToConstant: 160),

            // Selfie ImageView Constraints
            selfieImageView.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            selfieImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selfieImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            selfieImageView.heightAnchor.constraint(equalToConstant: 160),

            // Activity Indicator Constraints
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // Status Label Constraints
            statusLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    // MARK: - Comparison Logic
    private func startComparison() {
        activityIndicator.startAnimating()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            // 1. 키체인에서 이미지 불러오기 및 리사이즈
            let targetSize = CGSize(width: 160, height: 160)
            guard let licenseImage = self.viewModel.loadAndResizeImage(for: "licensePhoto", targetSize: targetSize),
                  let selfieImage = self.viewModel.loadAndResizeImage(for: "selfiePhoto", targetSize: targetSize) else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    print("키체인에서 이미지 불러오기 또는 리사이즈 실패")
                }
                return
            }

            // 2. 메인 스레드에서 이미지 표시
            DispatchQueue.main.async {
                self.licenseImageView.image = licenseImage
                self.selfieImageView.image = selfieImage
            }

            // 3. 유사도 비교
            let similarity = self.viewModel.compareImages(licenseImage: licenseImage, selfieImage: selfieImage)

            // 4. 결과 처리
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if let similarity = similarity {
                    print("유사도 결과: \(similarity)")
                } else {
                    print("이미지 비교 실패")
                }
            }
        }
    }
}
