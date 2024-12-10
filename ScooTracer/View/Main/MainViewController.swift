//
//  MainViewController.swift
//  ScooTracer
//
//  Created by mobicom on 12/10/24.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate {

    private let glowingCircle = CAShapeLayer()
    private let centerButton = UIButton(type: .custom)
    private let titleLabel = UILabel()
    private let mainLabel = UILabel()
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private var markersAdded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        view.backgroundColor = .white
        setupTitleLabel()
        setupMainLabel()

        // 위치 관리자 설정
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupGlowingCircle()
        setupCenterButton()
        startGlowingAnimation()
    }

    // MARK: - Setup MapView
    private func setupMapView() {
        mapView.frame = view.bounds
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.alpha = 0.6
        mapView.delegate = self
        view.addSubview(mapView)
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        centerMapOnLocation(location)

        if !markersAdded {
            addMarkers(to: mapView, around: location.coordinate)
            markersAdded = true
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }

    private func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
        )
        mapView.setRegion(coordinateRegion, animated: true)
    }

    // MARK: - 마커찍기 (랜덤)
    private func addMarkers(to mapView: MKMapView, around center: CLLocationCoordinate2D) {
        let radius: Double = 500
        let markerCount = 7

        let randomCoordinates = generateRandomCoordinates(center: center, count: markerCount, radius: radius)

        for coordinate in randomCoordinates {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "🛴 배터리 잔량 - 🪫"
            mapView.addAnnotation(annotation)
        }
    }

    private func generateRandomCoordinates(center: CLLocationCoordinate2D, count: Int, radius: Double) -> [CLLocationCoordinate2D] {
        var randomCoordinates: [CLLocationCoordinate2D] = []

        for _ in 0..<count {
            let randomLatitude = center.latitude + (Double.random(in: -radius...radius) / 111_000)
            let randomLongitude = center.longitude + (Double.random(in: -radius...radius) / (111_000 * cos(center.latitude * .pi / 180)))
            randomCoordinates.append(CLLocationCoordinate2D(latitude: randomLatitude, longitude: randomLongitude))
        }

        return randomCoordinates
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
        centerButton.frame = CGRect(x: 0, y: 0, width: 160, height: 160)
        centerButton.center = CGPoint(x: view.center.x, y: view.center.y + 200)
        centerButton.layer.cornerRadius = 80
        centerButton.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        centerButton.setTitle("GO!", for: .normal)
        centerButton.setTitleColor(.white, for: .normal)
        centerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        centerButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)

        centerButton.layer.shadowColor = UIColor.black.cgColor
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        centerButton.layer.shadowOpacity = 0.3
        centerButton.layer.shadowRadius = 8

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

    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.1) {
            self.centerButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.centerButton.transform = .identity
        }
    }

    @objc private func goToRidingView() {
        let ridingViewController = RidingViewController()
        ridingViewController.modalPresentationStyle = .fullScreen
        present(ridingViewController, animated: true, completion: nil)
    }
}

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let identifier = "EmojiMarker"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage.emojiImage(from: "🛴", size: CGSize(width: 20, height: 20))
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }
}
