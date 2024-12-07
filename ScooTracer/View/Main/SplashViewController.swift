import UIKit

class SplashViewController: UIViewController {

    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let startLabel = UILabel()

    private var logoCenterYConstraint: NSLayoutConstraint!
    private var logoCenterXConstraint: NSLayoutConstraint!
    private var titleTopConstraint: NSLayoutConstraint!
    private var startTopConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateSplashScreen()
    }

    private func setupViews() {
        view.backgroundColor = .white

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
        titleTopConstraint = titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: logoImageView.leadingAnchor),
            titleTopConstraint
        ])

        // 시작하기 레이블 설정
        startLabel.text = "시작하기"
        startLabel.textColor = .clear
        startLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        startLabel.textAlignment = .center
        startLabel.alpha = 0
        view.addSubview(startLabel)
        startLabel.translatesAutoresizingMaskIntoConstraints = false
        startTopConstraint = startLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        NSLayoutConstraint.activate([
            startLabel.leadingAnchor.constraint(equalTo: logoImageView.leadingAnchor),
            startTopConstraint
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
        // 로고와 레이블을 위로 이동하도록 제약 조정
        logoCenterYConstraint.constant = -150

        UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.logoImageView.transform = .identity
            self.titleLabel.alpha = 1.0
            self.startLabel.alpha = 1.0
        }, completion: { _ in
            self.moveLabelsToTopLeft()
        })
    }

    private func moveLabelsToTopLeft() {
        // 기존 titleLabel과 startLabel의 제약 해제
        titleTopConstraint.isActive = false
        startTopConstraint.isActive = false

        // titleLabel과 startLabel을 왼쪽 상단에 맞춰 새로운 제약 설정
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            startLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])

        // 애니메이션을 통해 레이블을 왼쪽 상단으로 이동, 로고는 페이드 아웃
        UIView.animate(withDuration: 0.7, animations: {
            self.logoImageView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.goToStartingView()
        })
    }

    private func goToStartingView() {
        let startingViewController = StartingViewController()
        let navigationController = UINavigationController(rootViewController: startingViewController)

        guard let window = self.view.window else { return }

        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = navigationController
        }, completion: nil)
    }
}
