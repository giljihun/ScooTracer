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
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.color = .white
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.tag = 999 // 식별용 태그

        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loadingIndicator.startAnimating()
    }

    // 로딩 인디케이터 제거
    func hideLoading() {
        if let loadingIndicator = view.viewWithTag(999) as? UIActivityIndicatorView {
            loadingIndicator.stopAnimating()
            loadingIndicator.removeFromSuperview()
        }
    }
}
