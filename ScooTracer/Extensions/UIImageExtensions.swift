//
//  UIImageExtensions.swift
//  ScooTracer
//
//  Created by mobicom on 12/11/24.
//

import UIKit

extension UIImage {
    /// 이미지를 지정된 크기로 리사이즈
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

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

    func toPixelBuffer() -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("PixelBuffer 생성 실패")
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            print("CGContext 생성 실패")
            return nil
        }

        guard let cgImage = self.cgImage else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)

        return buffer
    }

    func flippedHorizontally() -> UIImage {
        guard let cgImage = self.cgImage else {
            return self
        }

        return UIImage(cgImage: cgImage, scale: self.scale, orientation: .upMirrored)
    }

    /// Orientation을 교정하여 이미지 정렬
    func correctedOrientation() -> UIImage? {
        guard self.imageOrientation != .up else { return self }

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
}
