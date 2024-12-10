//
//  UIImageExtensions.swift
//  ScooTracer
//
//  Created by mobicom on 12/11/24.
//

import UIKit

extension UIImage {
    static func emojiImage(from emoji: String, size: CGSize) -> UIImage? {
        let label = UILabel()
        label.text = emoji
        label.font = UIFont.systemFont(ofSize: size.width) // 크기에 따라 폰트 크기 설정
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.frame = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
