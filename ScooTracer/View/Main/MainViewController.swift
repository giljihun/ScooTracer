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
    // private let logoImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white // 배경을 흰색으로 설정
        setupTitleLabel()
        setupMainLabel()
        // setupLogoImageView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

//    // MARK: - Setup Logo ImageView
//    private func setupLogoImageView() {
//        logoImageView.image = UIImage(named: "Logo3")
//        logoImageView.contentMode = .scaleAspectFit
//        logoImageView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(logoImageView)
//
//        NSLayoutConstraint.activate([
//            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            logoImageView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -50), // 중앙보다 살짝 위로
//            logoImageView.widthAnchor.constraint(equalToConstant: 150), // 이미지 크기
//            logoImageView.heightAnchor.constraint(equalToConstant: 150)
//        ])
//    }

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
        centerButton.center = CGPoint(x: view.center.x, y: view.center.y + 100) // 중앙보다 아래로 이동
        centerButton.layer.cornerRadius = 80
        centerButton.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
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
        centerButton.addTarget(self, action: #selector(goToRidingView), for: .touchUpInside)

        view.addSubview(centerButton)
    }

    // MARK: - Glowing Circle Animation
    private func startGlowingAnimation() {
        let rippleAnimation = CABasicAnimation(keyPath: "transform.scale")
        rippleAnimation.fromValue = 1.0
        rippleAnimation.toValue = 2.5
        rippleAnimation.duration = 1.0
        rippleAnimation.repeatCount = .infinity

        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.5
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 2.0
        fadeAnimation.repeatCount = .infinity

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [rippleAnimation, fadeAnimation]
        animationGroup.duration = 2.0
        animationGroup.repeatCount = .infinity
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let rippleLayer = CAShapeLayer()
        let circlePath = UIBezierPath(arcCenter: .zero, radius: 80, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        rippleLayer.path = circlePath.cgPath
        rippleLayer.lineWidth = 2
        rippleLayer.strokeColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1).withAlphaComponent(0.3).cgColor
        rippleLayer.fillColor = UIColor.clear.cgColor
        rippleLayer.position = centerButton.center

        view.layer.insertSublayer(rippleLayer, below: centerButton.layer)
        rippleLayer.add(animationGroup, forKey: "rippleEffect")

        UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.centerButton.transform = .identity
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

    // MARK: - Riding 페이지 이동 로직
    @objc private func goToRidingView() {
        let ridingViewController = RidingViewController()
        ridingViewController.modalPresentationStyle = .fullScreen
        present(ridingViewController, animated: true, completion: nil)
    }
}
