import UIKit

class StartingViewController: UIViewController, UIScrollViewDelegate {

    private let titleLabel = UILabel()
    private let startLabel = UILabel()
    private let stepsScrollView = UIScrollView()
    private let stepsStackView = UIStackView()
    private let pageControl = UIPageControl()
    private let descriptionImg = UIImageView()
    private let descriptionLabel = UILabel()
    private let continueBtn = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateInitialLabels()
    }

    private func setupViews() {
        view.backgroundColor = .white

        // "ScooTracer" 레이블 설정
        titleLabel.text = "ScooTracer"
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        titleLabel.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])

        // "시작하기" 레이블 설정
        startLabel.text = "시작하기"
        startLabel.font = UIFont.systemFont(ofSize: 40, weight: .medium)
        startLabel.textColor = .darkGray
        view.addSubview(startLabel)
        startLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            startLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])

        // 스크롤 뷰 설정
        stepsScrollView.isPagingEnabled = true
        stepsScrollView.showsHorizontalScrollIndicator = false
        stepsScrollView.delegate = self
        stepsScrollView.alpha = 0 // 초기에는 보이지 않도록 설정
        view.addSubview(stepsScrollView)
        stepsScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepsScrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepsScrollView.topAnchor.constraint(equalTo: startLabel.bottomAnchor, constant: 40),
            stepsScrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            stepsScrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35) // 화면 높이의 35%로 설정
        ])

        // 스택 뷰 설정
        stepsStackView.axis = .horizontal
        stepsStackView.alignment = .fill
        stepsStackView.distribution = .fillEqually
        stepsStackView.spacing = 0
        stepsScrollView.addSubview(stepsStackView)
        stepsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepsStackView.topAnchor.constraint(equalTo: stepsScrollView.topAnchor),
            stepsStackView.leadingAnchor.constraint(equalTo: stepsScrollView.leadingAnchor),
            stepsStackView.trailingAnchor.constraint(equalTo: stepsScrollView.trailingAnchor),
            stepsStackView.bottomAnchor.constraint(equalTo: stepsScrollView.bottomAnchor),
            stepsStackView.heightAnchor.constraint(equalTo: stepsScrollView.heightAnchor)
        ])

        // 임시 이미지 추가
        addStepView(imageName: "CapturingLicense", description: "1. 운전면허 촬영")
        addStepView(imageName: "CapturingMyFace", description: "2. 본인 얼굴 촬영")
        addStepView(imageName: "ComparingProcess", description: "3. 비교 프로세스 진행")

        // 페이지 컨트롤 설정
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.isUserInteractionEnabled = false // 클릭 방지 설정
        pageControl.alpha = 0 // 초기에는 보이지 않도록 설정
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.topAnchor.constraint(equalTo: stepsScrollView.bottomAnchor, constant: -5) // 더 가까운 위치에 배치
        ])

        // 설명 레이블 설정
        descriptionImg.image = UIImage(systemName: "person.fill.viewfinder")
        descriptionImg.tintColor = .systemBlue
        descriptionImg.alpha = 0

        descriptionLabel.text = "ScooTracer는 사용자의 안면 정보 이외의 신분증 정보를 저장하지 않습니다. 사용자의 안면 정보의 경우 KeyChain 암호화를 통해 안전하게 저장되며, 본 어플리케이션 활용 이외에 일절 활용하거나 수집하지 않습니다."
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.alpha = 0

        view.addSubview(descriptionImg)
        view.addSubview(descriptionLabel)

        descriptionImg.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionImg.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionImg.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 80),
            descriptionImg.widthAnchor.constraint(equalToConstant: 24),
            descriptionImg.heightAnchor.constraint(equalToConstant: 24),

            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: descriptionImg.bottomAnchor, constant: 4),
            descriptionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])

        // "계속" 버튼 설정
        continueBtn.setTitle("계속", for: .normal)
        continueBtn.setTitleColor(.white, for: .normal)
        continueBtn.backgroundColor = .systemBlue
        continueBtn.layer.cornerRadius = 10
        continueBtn.alpha = 0
        continueBtn.addTarget(self, action: #selector(goToCaptureLicenseView), for: .touchUpInside)
        continueBtn.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown) // 추가된 이벤트 연결
        continueBtn.addTarget(self, action: #selector(buttonTouchUp), for: .touchUpInside)
        continueBtn.addTarget(self, action: #selector(buttonTouchUp), for: .touchUpOutside)

        view.addSubview(continueBtn)

        continueBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            continueBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            continueBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func addStepView(imageName: String, description: String) {
        let stepView = UIView()

        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        stepView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: stepView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: stepView.centerYAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 230),
            imageView.heightAnchor.constraint(equalToConstant: 230)
        ])

        let descriptionLabel = UILabel()
        descriptionLabel.text = description
        descriptionLabel.textColor = .gray
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        stepView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            descriptionLabel.centerXAnchor.constraint(equalTo: stepView.centerXAnchor)
        ])

        stepsStackView.addArrangedSubview(stepView)
        stepView.translatesAutoresizingMaskIntoConstraints = false
        stepView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }

    private func animateInitialLabels() {
        UIView.animate(withDuration: 0.8, animations: {
            self.titleLabel.alpha = 1.0
            self.startLabel.alpha = 1.0
        }, completion: { _ in
            self.showSteps()
        })
    }

    private func showSteps() {
        // 스크롤뷰와 페이지 컨트롤 등장 애니메이션 (페이드 인 및 위로 이동)
        stepsScrollView.transform = CGAffineTransform(translationX: 0, y: 50)
        pageControl.transform = CGAffineTransform(translationX: 0, y: 50)
        UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseOut, animations: {
            self.stepsScrollView.alpha = 1.0
            self.stepsScrollView.transform = .identity
            self.pageControl.alpha = 1.0
            self.pageControl.transform = .identity
            self.continueBtn.alpha = 1.0
            self.continueBtn.transform = .identity
        })

        UIView.animate(withDuration: 1.3, delay: 0.2, options: .curveEaseOut, animations: {
            self.descriptionImg.alpha = 1.0
            self.descriptionImg.transform = .identity
            self.descriptionLabel.alpha = 1.0
            self.descriptionLabel.transform = .identity
        })
    }

    // 스크롤될 때 페이지 컨트롤 업데이트
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }

    @objc private func goToCaptureLicenseView() {
        let captureLicenseVC = CaptureLicenseViewController()
        captureLicenseVC.modalTransitionStyle = .crossDissolve
        captureLicenseVC.modalPresentationStyle = .fullScreen
        self.present(captureLicenseVC, animated: true, completion: nil)
    }


    // 버튼 눌렸을 때 축소
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.continueBtn.titleLabel?.alpha = 0.6
        }
    }

    // 버튼에서 손을 뗐을 때 원래 크기로 복구
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
            self.continueBtn.titleLabel?.alpha = 1.0
        }
    }
}
