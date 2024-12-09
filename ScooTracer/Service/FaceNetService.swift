//
//  FaceNetService.swift
//  ScooTracer
//
//  Created by mobicom on 12/9/24.
//

import CoreML
import UIKit

class FaceNetService {
    private let model: facenet512

    init?() {
        do {
            self.model = try facenet512(configuration: .init())
        } catch {
            print("모델 초기화 실패: \(error.localizedDescription)")
            return nil
        }
    }

    func generateEmbedding(from image: UIImage) -> [Float]? {
        guard let pixelBuffer = image.toPixelBuffer() else {
            print("이미지를 PixelBuffer로 변환 실패")
            return nil
        }

        do {
            let inputArray = try pixelBuffer.toMLMultiArray()
            let output = try model.prediction(input_1: inputArray)

            return output.Identity.toFloatArray()
        } catch {
            print("임베딩 생성 실패: \(error.localizedDescription)")
            return nil
        }
    }

    func compare(image1: UIImage, image2: UIImage) -> Float? {
        guard let embedding1 = generateEmbedding(from: image1),
              let embedding2 = generateEmbedding(from: image2) else {
            print("임베딩 생성 실패로 비교 불가")
            return nil
        }
        print("License Embedding: \(embedding1)")
        print("Selfie Embedding: \(embedding2)")
        return cosineSimilarity(vector1: embedding1, vector2: embedding2)
    }

    private func cosineSimilarity(vector1: [Float], vector2: [Float]) -> Float {
        guard vector1.count > 0, vector2.count > 0 else {
            print("벡터가 비어 있습니다")
            return 0.0
        }

        guard vector1.count == vector2.count else {
            print("벡터 길이가 일치하지 않습니다")
            return 0.0
        }

        var dotProduct: Float = 0.0
        var magnitude1: Float = 0.0
        var magnitude2: Float = 0.0

        for i in 0..<vector1.count {
            dotProduct += vector1[i] * vector2[i]
            magnitude1 += vector1[i] * vector1[i]
            magnitude2 += vector2[i] * vector2[i]
        }

        magnitude1 = sqrt(magnitude1)
        magnitude2 = sqrt(magnitude2)

        guard magnitude1 > 0, magnitude2 > 0 else {
            print("벡터 크기가 0입니다. 유사도 계산 불가")
            return 0.0
        }

        let normalizedDotProduct = dotProduct / (magnitude1 * magnitude2)
        return normalizedDotProduct
    }

}
