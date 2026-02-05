# ScooTracer

<img width="200" alt="Logo" src="https://github.com/user-attachments/assets/25848407-8a1e-4ded-a305-ed967d852974" />


**On-device 얼굴 인식을 통한 PM(개인형 이동장치) 보안 솔루션**


## 프로젝트 개요

**ScooTracer**는 Facenet512 기반의 얼굴 인식 모델을 활용하여 **면허 도용 및 대리 주행을 원천 차단**하는 PM 전용 보안 솔루션입니다.   
Python으로 학습된 모델을 CoreML로 변환하여 iOS 기기 내에서 직접(On-device) 실시간으로 운전자를 검증합니다.   
이를 통해 서버 통신 없이도 빠르고 안전한 사용자 인증을 보장하며, 개인정보를 보호합니다.

<br>

## 시연 영상

<table style="width: 50%;">
  <tr>
    <td align="center" style="width: 50%;">
      <b> 앱 진입 </b><br>
      <video src="https://github.com/user-attachments/assets/9e9655d9-3fe9-4532-9ebe-f17a53e2550c" autoplay loop muted playsinline style="width: 100%; border-radius: 10px;"></video>
    </td>
    <td align="center" style="width: 50%;">
      <b> 사용자 면허 인증 (성공) </b><br>
      <video src="https://github.com/user-attachments/assets/6bca989d-0a56-4889-9130-d50549e9a0e2" autoplay loop muted playsinline style="width: 100%; border-radius: 10px;"></video>
    </td>
     <td align="center" style="width: 50%;">
      <b> 사용자 면허 인증 (실패) </b><br>
      <video src="https://github.com/user-attachments/assets/9f80c9a5-0ae8-494a-ba31-47b711a0bb8f" autoplay loop muted playsinline style="width: 100%; border-radius: 10px;"></video>
    </td>
  </tr>
  <tr>
   <td align="center" style="width: 50%;">
      <b> 메인화면 </b><br>
      <video src="https://github.com/user-attachments/assets/a84f538e-9dca-4036-8140-4ce9e6f88ac1" autoplay loop muted playsinline style="width: 100%; border-radius: 10px;"></video>
    </td>
     <td align="center" style="width: 50%;">
      <b> 성공적 주행 화면 </b><br>
      <video src="https://github.com/user-attachments/assets/25b14b58-34d0-4a3f-8d1c-5f1c19fb508d" autoplay loop muted playsinline style="width: 100%; border-radius: 10px;"></video>
    </td>
     <td align="center" style="width: 50%;">
      <b> 경고 누적으로 인한 주행 종료 </b>
        <br>
      <img src="https://github.com/user-attachments/assets/df69c013-bb4b-4e26-8986-53bf7016b202" style="width: 100%; border-radius: 10px;"></img>
    </td>
  </tr>
</table>


<br>

## 핵심 기능

#### 1. 면허증 & 본인 얼굴 대조 (Sign-up)
회원가입 시 사용자의 운전면허증 사진과 실시간으로 촬영한 셀카를 비교하여 본인임을 인증합니다.

#### 2. 주행 전 사용자 인증 (Pre-ride Check)
PM 이용 시작 직전, 간단한 얼굴 인식을 통해 예약자와 실제 탑승자가 동일인인지 확인합니다.

#### 3. 실시간 주행 중 운전자 검증 (Real-time Monitoring)
주행 중 주기적으로 운전자의 얼굴을 검증하여, 헬멧 착용 등으로 인한 운전자 변경 시도를 감지합니다.

#### 4. 보안 위협 감지 및 자동 운행 제어 (Security Action)
미인증 사용자가 감지될 경우, 단계별 경고(소리, 진동)를 보낸 후 PM의 운행을 안전하게 강제 종료합니다.

<br>

## 기술 스택 및 아키텍처

*   **Platform**: iOS
*   **UI**: UIKit
*   **Key Frameworks**:
    *   **Vision**: 이미지 및 비디오 분석, 얼굴 감지를 위한 프레임워크
    *   **AVFoundation**: 카메라 및 미디어 처리를 위한 프레임워크
    *   **CoreML**: On-device 머신러닝 추론을 위한 프레임워크 
*   **Architecture**: MVVM (Model-View-ViewModel)
*   **Machine Learning**:
    *   **CoreML**: On-device 머신러닝 추론을 위한 Apple 프레임워크
    *   **facenet512.mlpackage**: 512차원 얼굴 임베딩을 생성하는 FaceNet 기반 모델


### `View`
: `Splash`, `Main`, `Capture`, `Comparison`, `Riding` 등 각 화면의 UI와 사용자 상호작용을 담당하는 `UIViewController`들로 구성됩니다.

### `ViewModel`
: 각 View에 필요한 데이터와 비즈니스 로직을 처리합니다. 예를 들어, `ComparisonViewModel`은 면허증과 셀카 이미지의 특징점을 비교하는 로직을 수행합니다.

### `Service`
: `FaceNetService`는 CoreML 모델을 직접 호출하여 얼굴 이미지로부터 특징 벡터(Embedding)를 추출하는 핵심 역할을 담당합니다.

### `Extensions`
: `UIImage`, `UIView` 등 UIKit 객체에 대한 확장 함수를 정의하여 코드 재사용성을 높입니다.

### `Model`
: `facenet512.mlpackage`가 핵심 모델 자산으로, 별도의 서버 없이 기기 내에서 모든 얼굴 인식 연산을 수행합니다.

<br>

## 실행 흐름 (User Flow)

### 1. 회원가입 및 본인 인증
- 사용자는 운전면허증을 촬영합니다 (`CaptureLicenseViewController`).
- 이어서 본인 얼굴을 촬영합니다 (`SelfieCaptureViewController`).
- 시스템은 두 이미지의 얼굴 특징점을 비교하여 유사도를 검증합니다 (`ComparisonViewController`).

### 2. 주행 시작
- PM 이용을 시작하기 전, 다시 한번 얼굴 인식을 통해 탑승자 본인임을 확인합니다 (`StartingViewController`).

### 3. 실시간 모니터링
- 주행이 시작되면 `RidingViewController`에서 주기적으로 운전자의 얼굴을 확인합니다.

### 4. 보안 조치
- 만약 등록된 사용자와 다른 얼굴이 감지되면, `CustomAlertViewController`를 통해 경고를 표시하고 PM의 속도를 서서히 줄여 운행을 중단시킵니다.

<br>

## 프로젝트 구조

```
ScooTracer/
├── facenet512.mlpackage/      # 얼굴 인식 CoreML 모델
├── ScooTracer/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── Extensions/              # UIImage, UIView 등 확장
│   │   ├── FaceNetExtensions.swift
│   │   └── ...
│   ├── Resources/               # Assets, Storyboards
│   │   ├── Assets.xcassets
│   │   └── Base.lproj
│   ├── Service/                 # 핵심 비즈니스 로직
│   │   └── FaceNetService.swift   # CoreML 모델 래퍼
│   ├── View/                    # UIViewController
│   │   ├── CustomAlertViewController.swift
│   │   └── Main/
│   │       ├── CaptureLicenseViewController.swift
│   │       ├── ComparisonViewController.swift
│   │       ├── RidingViewController.swift
│   │       ├── SelfieCaptureViewController.swift
│   │       └── ...
│   └── ViewModel/               # View를 위한 데이터 및 로직
│       ├── CaptureLicenseViewModel.swift
│       ├── ComparisonViewModel.swift
│       └── ...
└── ScooTracer.xcodeproj/      # Xcode 프로젝트 파일
```
