# ScooTracer 프로젝트 MVVM 폴더 구조 가이드

**ScooTracer 프로젝트**의 **MVVM 패턴**에 맞춘 폴더 구조와 각 폴더의 역할을 설명하는 가이드.

---

## 목차
1. [폴더 구조](#폴더-구조)
2. [폴더별 역할 설명](#폴더별-역할-설명)
   - [Model](#model)
   - [View](#view)
   - [ViewModel](#viewmodel)
   - [Service](#service)
   - [Resources](#resources)
   - [Extensions](#extensions)
   - [Utils](#utils)
3. [파일 추가 시 유의사항](#파일-추가-시-유의사항)

---

## 폴더 구조

```plaintext
📁 ScooTracer
├── CONVENTION.md
├── Info.plist
├── README.md
├── STRUCTURE.md
├── 📁 ScooTracer
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── 📁 Base.lproj
│   ├── 📁 Extensions
│   │   ├── FaceNetExtensions.swift
│   │   ├── UIImageExtensions.swift
│   │   └── UIViewExtensions.swift
│   ├── 📁 Model
│   ├── 📁 Resources
│   │   ├── Assets.xcassets
│   │   └── 📁 Base.lproj
│   ├── 📁 Service
│   │   └── FaceNetService.swift
│   ├── 📁 Utils
│   ├── 📁 View
│   │   ├── CustomAlertViewController.swift
│   │   ├── 📁 Main
│   │   └── 📁 Sub
│   └── 📁 ViewModel
│       ├── CaptureLicenseViewModel.swift
│       ├── ComparisonViewModel.swift
│       ├── RidingViewModel.swift
│       └── SelfieCaptureViewModel.swift
├── 📁 ScooTracer.xcodeproj
│   ├── project.pbxproj
│   ├── 📁 project.xcworkspace
│   │   ├── contents.xcworkspacedata
│   │   ├── 📁 xcshareddata
│   │   └── 📁 xcuserdata
│   ├── 📁 xcshareddata
│   │   └── 📁 xcschemes
│   └── 📁 xcuserdata
│       └── 📁 mobicom.xcuserdatad
└── 📁 facenet512.mlpackage
    ├── 📁 Data
    │   └── 📁 com.apple.CoreML
    └── Manifest.json

```
# 폴더별 역할 

## Model
- 앱의 **데이터 구조** 정의
- **예시 파일**: 
  - `User.swift` – 사용자 정보 모델 파일
  - `AuthSession.swift` – 인증 상태 관리 모델 파일

## View
- UI와 관련된 모든 **화면 구성 요소** 포함

### 하위 폴더
  - **ViewController**: 각 화면의 뷰 컨트롤러 파일
    - 예시: `AuthViewController.swift`, `MainViewController.swift`
  - **Custom Views**: 재사용 가능한 커스텀 뷰 파일
    - 예시: `FaceRecognitionView.swift` – 얼굴 인식 뷰

## ViewModel
- View와 Model 사이에서 **데이터 가공 및 중개 역할** 수행
- View에서 데이터 요청을 받아 Model 데이터를 가공 후 View에 전달

- **예시 파일**:
  - `AuthViewModel.swift` – 인증 비즈니스 로직 처리
  - `FaceRecognitionViewModel.swift` – 얼굴 인식 결과 전달 로직

## Service
- **비즈니스 로직**과 외부 API 연동, 데이터 처리 포함

- **예시 파일**:
  - `AuthService.swift` – 인증 관련 데이터 처리
  - `FaceRecognitionService.swift` – 얼굴 인식 API 호출 로직

## Resources
- 이미지, 로컬화 파일, 폰트 등 **리소스 관리**

### 하위 폴더
  - **Assets**: 앱 아이콘 및 이미지 리소스 관리 (`Assets.xcassets`)
  - **Localization**: 다국어 지원 `.strings` 파일
    - 예시: `en.lproj`, `ko.lproj`

## Extensions
- UIKit과 Swift 표준 라이브러리 **확장 기능** 관리

- **예시 파일**:
  - `UIView+Extensions.swift` – UIView 확장 메서드
  - `String+Extensions.swift` – String 확장 메서드

## Utils
- 앱 전반에서 자주 사용하는 **유틸리티 함수**나 **헬퍼 클래스** 포함

- **예시 파일**:
  - `DateFormatterHelper.swift` – 날짜 형식 변환 헬퍼 함수
  - `ImageProcessor.swift` – 이미지 처리 및 변환 헬퍼

---

## 파일 추가 시 유의사항
- 각 폴더의 **역할에 맞는 파일을 추가**하여 기능별로 분리
- **ViewModel**은 View와 Model **중개 역할**만 수행하고, UI와 직접적인 상호작용 없음
- **View**는 UI와 관련된 작업에만 집중하고, 비즈니스 로직이나 데이터 처리 로직은 ViewModel에 위임
- **Service**에는 네트워크 호출이나 데이터베이스 액세스 같은 비즈니스 로직 포함하여 ViewModel이 직접 데이터 접근하지 않도록 함


