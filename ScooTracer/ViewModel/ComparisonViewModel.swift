//
//  ComparisonViewModel.swift
//  ScooTracer
//
//  Created by mobicom on 12/9/24.
//

import UIKit
import CoreML

class ComparisonViewModel {
    private let faceNetService: FaceNetService?

    init() {
        faceNetService = FaceNetService()
    }

    /// 키체인에서 이미지 데이터를 불러온 후 리사이즈
    func loadAndResizeImage(for key: String, targetSize: CGSize) -> UIImage? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let image = UIImage(data: data) else {
            print("키체인에서 \(key) 데이터 가져오기 실패: \(status)")
            return nil
        }

        // 리사이즈 처리
        guard let resizedImage = image.resized(to: targetSize) else {
            print("\(key) 이미지 리사이즈 실패")
            return nil
        }

        return resizedImage
    }

    /// 두 이미지의 유사도를 비교
    func compareImages(licenseImage: UIImage, selfieImage: UIImage) -> Float? {
        guard let service = faceNetService else {
            print("FaceNetService 초기화 실패")
            return nil
        }
        return service.compare(image1: licenseImage, image2: selfieImage)
    }
}
