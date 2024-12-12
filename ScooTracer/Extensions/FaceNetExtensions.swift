//
//  FaceNetExtensions.swift
//  ScooTracer
//
//  Created by mobicom on 12/9/24.
//

import UIKit
import CoreVideo
import CoreML

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
