# Simple Text Editor 초기 설정 가이드

> 이 문서는 "Simple Text Editor"의 개발 환경을 설정하는 방법을 안내합니다. 명확하고 구조화된 형식을 사용하여 Gemini와 같은 AI 도구가 이해하고 실행하기 쉽도록 작성되었습니다.

## 1. 프로젝트 개요 (Project Overview)

*   **프로젝트 설명:** SwiftUI로 만든 간단한 텍스트 에디터 애플리케이션입니다. 기본적인 텍스트 생성, 편집, 저장 기능을 제공합니다.
*   **Repository:** https://github.com/example/simple-text-editor

## 2. 사전 요구사항 (Prerequisites)

개발 환경을 설정하기 전에 다음 도구들이 설치되어 있어야 합니다.

*   **Xcode:** `v15.0` 이상
*   **Swift Package Manager:** Xcode에 내장

```bash
# 사전 요구사항 설치 확인 명령어
xcodebuild -version
```

## 3. 설치 (Installation)

프로젝트 종속성을 설치하고 초기 설정을 진행합니다.

```bash
# 1. 저장소 복제
git clone https://github.com/example/simple-text-editor.git
cd simple-text-editor

# 2. 종속성 해결 (필요한 경우)
# 이 프로젝트는 외부 종속성이 거의 없지만, 필요한 경우 아래 명령어를 실행합니다.
swift package resolve
```

## 4. 애플리케이션 실행 (Running the Application)

Xcode를 사용하여 애플리케이션을 빌드하고 실행합니다.

1.  `SimpleTextEditor.xcodeproj` 파일을 Xcode에서 엽니다.
2.  상단에서 실행할 대상(Target)으로 'My Mac' 또는 시뮬레이터를 선택합니다.
3.  '빌드 및 실행' 버튼(▶)을 클릭하거나 `Cmd+R` 단축키를 사용합니다.

## 5. 테스트 실행 (Running Tests)

프로젝트의 단위 테스트 또는 UI 테스트를 실행하는 명령어입니다.

```bash
# Xcode의 Test Navigator를 사용하거나 아래 명령어를 터미널에서 실행합니다.
xcodebuild test -scheme 'SimpleTextEditor' -destination 'platform=macOS'
```

## 6. 프로젝트 구조 (Project Structure)

*   `SimpleTextEditor/`: 메인 애플리케이션 소스 코드
*   `SimpleTextEditor/Views`: SwiftUI 뷰 파일
*   `SimpleTextEditor/ViewModels`: 뷰와 데이터를 연결하는 뷰 모델
*   `SimpleTextEditor/Models`: 데이터 모델
*   `SimpleTextEditor.xcodeproj`: Xcode 프로젝트 파일
*   `SimpleTextEditorTests/`: 단위 테스트 및 UI 테스트 코드

## 7. 주요 기술 스택 (Key Technologies)

*   **언어:** Swift 5.9
*   **UI 프레임워크:** SwiftUI
*   **상태 관리:** Combine
*   **패키지 매니저:** Swift Package Manager
