//
//  Extensions.swift
//  ScooTracer
//
//  Created by mobicom on 12/7/24.
//

import Foundation
import UIKit

extension UIViewController {
    // 로딩 인디케이터 추가
    func showLoading() {
        // 배경 뷰 추가
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5) // 반투명 배경
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.tag = 998 // 배경 식별용 태그
        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        backgroundView.alpha = 0 // 페이드 인 효과

        // 로딩 인디케이터 추가
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .white
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.tag = 999 // 식별용 태그
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loadingIndicator.transform = CGAffineTransform(scaleX: 0.5, y: 0.5) // 작게 시작
        loadingIndicator.startAnimating()

        // 페이드 인 + 크기 확대 애니메이션
        UIView.animate(withDuration: 0.4, animations: {
            backgroundView.alpha = 1.0 // 배경 페이드 인
            loadingIndicator.alpha = 1.0
            loadingIndicator.transform = CGAffineTransform(scaleX: 1.4, y: 1.4) // 확대
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                loadingIndicator.transform = .identity // 원래 크기로 복구
            }
        }
    }

    func hideLoading() {
        if let backgroundView = view.viewWithTag(998),
           let loadingIndicator = view.viewWithTag(999) as? UIActivityIndicatorView {
            // 페이드 아웃 + 크기 축소 애니메이션
            UIView.animate(withDuration: 0.3, animations: {
                backgroundView.alpha = 0
                loadingIndicator.alpha = 0
                loadingIndicator.transform = CGAffineTransform(scaleX: 0.5, y: 0.5) // 작아지며 사라짐
            }) { _ in
                backgroundView.removeFromSuperview()
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()
            }
        }
    }
}
