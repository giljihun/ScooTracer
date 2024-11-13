//
//  SplashViewController.swift
//  ScooTracer
//
//  Created by mobicom on 11/13/24.
//

import UIKit

class SplashViewController: UIViewController {

    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let startLabel = UILabel()

    private var logoCenterYConstraint: NSLayoutConstraint!
    private var logoCenterXConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateSplashScreen()
    }

    private func setupViews() {
        view.backgroundColor = .black

        // 로고 설정
        logoImageView.image = UIImage(named: "Logo")
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoCenterYConstraint = logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30)
        logoCenterXConstraint = logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -70)
        NSLayoutConstraint.activate([
            logoCenterXConstraint,
            logoCenterYConstraint,
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalToConstant: 150)
        ])

        // ScooTracer 레이블 설정
        titleLabel.text = "ScooTracer"
        titleLabel.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10)
        ])

        // 시작하기 레이블 설정
        startLabel.text = "시작하기"
        startLabel.textColor = .white
        startLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        startLabel.textAlignment = .center
        startLabel.alpha = 0
        view.addSubview(startLabel)
        startLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startLabel.leadingAnchor.constraint(equalTo: logoImageView.leadingAnchor),
            startLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])
    }

    private func animateSplashScreen() {
        // 로고 및 텍스트의 초기 상태 설정
        logoImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).translatedBy(x: 0, y: 50)

        // 로고 페이드 인 애니메이션
        UIView.animate(withDuration: 1.2, delay: 0.2, options: .curveEaseOut, animations: {
            self.logoImageView.alpha = 1.0
        }, completion: { _ in
            self.moveLogoUp()
        })
    }

    private func moveLogoUp() {
        /* 로고와 레이블이 위로 이동하고, 시작하기 레이블이 나타나는 애니메이션
        로고를 더 위로 이동하도록 centerY 제약 조정 */
        logoCenterYConstraint.constant = -150

        UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            // 제약 조건 변경 사항을 애니메이션으로 적용
            self.view.layoutIfNeeded()
            // 크기와 위치를 원래대로 복귀
            self.logoImageView.transform = .identity
            self.titleLabel.alpha = 1.0
            self.startLabel.alpha = 1.0
        })
    }
}
