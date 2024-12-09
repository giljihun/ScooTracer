//
//  FaceNetExtensions.swift
//  ScooTracer
//
//  Created by mobicom on 12/9/24.
//

import UIKit
import CoreVideo
import CoreML


/// UIImage를 CoreML 모델 입력으로 사용할 수 있도록 CVPixelBuffer로 변환.
/// CVPixelBuffer 입력을 요구하는 모델에 이미지를 전달하기 위해 필수적인 작업.
extension UIImage {
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
}


/// CVPixelBuffer를 CoreML 모델 입력으로 사용할 수 있도록 MLMultiArray로 변환.
/// RGB 채널 추출과 정규화를 처리하여 모델의 입력 형식과 호환되도록 함.
extension CVPixelBuffer {
    func toMLMultiArray() throws -> MLMultiArray {
        // PixelBuffer의 크기 가져오기
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)

        // RGB 채널 크기 설정
        let arrayShape = [1, height, width, 3] as [NSNumber]
        let array = try MLMultiArray(shape: arrayShape, dataType: .float32)

        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(self) else {
            throw NSError(domain: "PixelBufferError", code: -1, userInfo: [NSLocalizedDescriptionKey: "PixelBuffer base address를 가져올 수 없습니다."])
        }

        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let buffer = UnsafeMutableRawPointer(baseAddress)

        let heightRange = 0..<height
        let widthRange = 0..<width

        for y in heightRange {
            for x in widthRange {
                let offset = y * bytesPerRow + x * 4
                let pixel = buffer.advanced(by: offset).assumingMemoryBound(to: UInt8.self)

                // RGB 값 추출
                let red = Float(pixel[0]) / 255.0
                let green = Float(pixel[1]) / 255.0
                let blue = Float(pixel[2]) / 255.0

                // MLMultiArray에 값 저장 (채널 순서: RGB)
                array[[0, y as NSNumber, x as NSNumber, 0]] = NSNumber(value: red)
                array[[0, y as NSNumber, x as NSNumber, 1]] = NSNumber(value: green)
                array[[0, y as NSNumber, x as NSNumber, 2]] = NSNumber(value: blue)
            }
        }

        return array
    }
}

/// MLMultiArray를 Swift의 Float 배열로 변환하여 보다 쉽게 조작하고 계산할 수 있도록 함.
/// 주로 유사도 계산 등 모델 출력값을 처리하는 데 사용됨.
extension MLMultiArray {
    func toFloatArray() -> [Float]? {
        let count = self.count
        var floatArray = [Float](repeating: 0, count: count)

        for i in 0..<count {
            floatArray[i] = self[i].floatValue
        }
        return floatArray
    }
}

extension UIImage {
    /// 이미지를 지정된 크기로 리사이즈
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
