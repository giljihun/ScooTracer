//
//  MainViewController.swift
//  ScooTracer
//
//  Created by mobicom on 12/10/24.
//

//
//  MainViewController.swift
//  ScooTracer
//
//  Created by mobicom on 12/10/24.
//

import UIKit

class MainViewController: UIViewController {

    private let glowingCircle = CAShapeLayer()
    private let centerButton = UIButton(type: .custom)
    private let titleLabel = UILabel()
    private let mainLabel = UILabel() // 기존 startLabel -> mainLabel

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // 배경을 흰색으로 설정

        setupTitleLabel()
        setupMainLabel()
        setupGlowingCircle()
        setupCenterButton()
        startGlowingAnimation()
    }

    // MARK: - Setup Title Label
    private func setupTitleLabel() {
        titleLabel.text = "ScooTracer"
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        titleLabel.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }

    // MARK: - Setup Main Label
    private func setupMainLabel() {
        mainLabel.text = "주행하기"
        mainLabel.font = UIFont.systemFont(ofSize: 40, weight: .medium)
        mainLabel.textColor = .darkGray
        view.addSubview(mainLabel)
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            mainLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])
    }

    // MARK: - Setup Glowing Circle
    private func setupGlowingCircle() {
        glowingCircle.lineWidth = 7
        glowingCircle.strokeColor = UIColor.systemBlue.cgColor
        glowingCircle.fillColor = UIColor.clear.cgColor
        glowingCircle.opacity = 0.0

        view.layer.addSublayer(glowingCircle)
    }

    // MARK: - Setup Center Button
    private func setupCenterButton() {
        centerButton.frame = CGRect(x: 0, y: 0, width: 160, height: 160) // 내부 원 크기
        centerButton.center = view.center
        centerButton.layer.cornerRadius = 80
        centerButton.backgroundColor = .systemBlue
        centerButton.setTitle("GO!", for: .normal)
        centerButton.setTitleColor(.white, for: .normal)
        centerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        centerButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0) // 시작 크기 0

        // 쉐도우 설정
        centerButton.layer.shadowColor = UIColor.black.cgColor // 그림자 색
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 4) // 그림자 방향과 거리
        centerButton.layer.shadowOpacity = 0.3 // 그림자 투명도
        centerButton.layer.shadowRadius = 8 // 그림자 흐림 정도

        centerButton.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        centerButton.addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside])

        view.addSubview(centerButton)
    }

    // MARK: - Glowing Circle Animation
    private func startGlowingAnimation() {
        // 반복적으로 퍼지는 물결 효과
        let rippleAnimation = CABasicAnimation(keyPath: "transform.scale")
        rippleAnimation.fromValue = 1.0
        rippleAnimation.toValue = 2.5 // 일정한 속도로 확대
        rippleAnimation.duration = 1.0
        rippleAnimation.repeatCount = .infinity

        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.5 // 더 연한 색으로 시작
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 2.0
        fadeAnimation.repeatCount = .infinity

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [rippleAnimation, fadeAnimation]
        animationGroup.duration = 2.0
        animationGroup.repeatCount = .infinity
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut) // 일정한 속도 유지

        // 물결 효과 레이어 설정
        let rippleLayer = CAShapeLayer()
        let circlePath = UIBezierPath(arcCenter: .zero, radius: 80, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        rippleLayer.path = circlePath.cgPath
        rippleLayer.lineWidth = 2
        rippleLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor // 더 연한 색 적용
        rippleLayer.fillColor = UIColor.clear.cgColor
        rippleLayer.position = view.center // 화면 중앙에 위치

        view.layer.insertSublayer(rippleLayer, below: centerButton.layer) // 버튼 아래 레이어에 추가
        rippleLayer.add(animationGroup, forKey: "rippleEffect")

        // Center button pop-in animation
        UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.centerButton.transform = .identity // 크기 복구
        })
    }

    // MARK: - Button Pressed (눌림 효과)
    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.1) {
            self.centerButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    // MARK: - Button Released
    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.centerButton.transform = .identity
        }
    }
}
