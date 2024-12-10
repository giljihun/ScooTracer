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

    func generateEmbedding(from image: UIImage) -> MLMultiArray? {
        // 이미지 -> PixelBuffer로 변환
        guard let pixelBuffer = image.toPixelBuffer() else {
            print("이미지를 PixelBuffer로 변환 실패")
            return nil
        }

        do {
            // 모델의 예측 결과에서 임베딩 추출
            let inputArray = try pixelBuffer.toMLMultiArray()
            let output = try model.prediction(input_1: inputArray)
            return output.Identity
        } catch {
            print("임베딩 생성 실패: \(error.localizedDescription)")
            return nil
        }
    }

    func compare(image1: UIImage, image2: UIImage) -> Float? {
        // 두 이미지로부터 임베딩 생성
        guard let embedding1 = generateEmbedding(from: image1),
              let embedding2 = generateEmbedding(from: image2) else {
            print("임베딩 생성 실패로 비교 불가")
            return nil
        }

        // print("1. Embedding: \(embedding1)")
        // print("2. Embedding: \(embedding2)")

        // 코사인 유사도 계산
        return cosineSimilarity(vector1: embedding1, vector2: embedding2)
    }

    private func cosineSimilarity(vector1: MLMultiArray, vector2: MLMultiArray) -> Float {
        // 벡터 크기 확인
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

        // 벡터 내적 및 크기 계산
        for i in 0..<vector1.count {
            guard let val1 = vector1[i] as? Float,
                  let val2 = vector2[i] as? Float else {
                print("MLMultiArray 값을 Float으로 변환 실패")
                return 0.0
            }

            dotProduct += val1 * val2
            magnitude1 += val1 * val1
            magnitude2 += val2 * val2
        }

        magnitude1 = sqrt(magnitude1)
        magnitude2 = sqrt(magnitude2)

        guard magnitude1 > 0, magnitude2 > 0 else {
            print("벡터 크기가 0입니다. 유사도 계산 불가")
            return 0.0
        }

        return dotProduct / (magnitude1 * magnitude2) // 코사인 유사도 반환
    }
}
