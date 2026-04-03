# WebStart Audit Automation v3 설계안

> 목적: 사이트 분석 파이프라인을 더 깊고 재현 가능하게 자동화하고, 다른 프로젝트와 다른 컴퓨터에서도 `git clone && bash install.sh` 수준으로 쉽게 설치할 수 있게 만든다.

## 핵심 방향

- Claude 스킬은 오케스트레이션에 집중
- 브라우저 수집과 정형 분석은 공용 runtime이 담당
- `_audit/` 산출물 구조를 고정해 프로젝트 간 이식성 확보
- 설치는 `install.sh` 하나로 끝나도록 통합

## 권장 아키텍처

```text
skills/audit*          -> 작업 흐름 제어, 보고서 작성, 게이트 판정
~/.webstart/audit-runtime
  -> Playwright/Python 기반 수집 및 분석 실행 계층

프로젝트/
└── _audit/
    ├── raw/           -> 원본 수집 데이터
    ├── derived/       -> 정규화된 분석 데이터
    ├── reports/       -> 중간 보고서 산출물
    ├── screenshots/   -> 페이지/컴포넌트 캡처
    ├── status.json    -> 기계 판정용 상태 원본
    ├── status.md      -> 사람용 상태 뷰
    └── target.md      -> 분석 대상 정의
```

## 설치 흐름

### 다른 컴퓨터

```bash
git clone <repo>
cd WebStart
bash install.sh
```

`install.sh`가 수행하는 일:

1. `skills/` 전체를 `~/.claude/skills`에 복사
2. `audit-runtime/`을 `~/.webstart/audit-runtime`에 동기화
3. Python venv 생성
4. `webstart-audit` 실행 파일 생성
5. Playwright Chromium 설치

### 다른 프로젝트

별도 재설치 없이 같은 컴퓨터에서는 어떤 프로젝트에서든 아래처럼 재사용 가능:

```bash
cd /path/to/project
webstart-audit init --project-dir .
webstart-audit crawl https://example.com --project-dir .
```

## 왜 Python runtime을 분리하는가

- 여러 프로젝트에서 공용으로 재사용 가능
- HTML, JSON, 링크 그래프, 성능 데이터를 정형 처리하기 쉬움
- LLM이 raw HTML을 직접 읽기보다, 정리된 JSON 증거를 읽도록 만들 수 있음
- 나중에 `Lighthouse`, `axe-core`, `OpenAPI inference`를 추가하기 좋음

## 현재 이번 세션에서 추가한 기반

- `audit-runtime/` Python 패키지 스캐폴드
- `scripts/setup-audit-runtime.sh`
- `install.sh`의 runtime 연동
- 실행 가능한 CLI:
  - `webstart-audit doctor`
  - `webstart-audit init`
  - `webstart-audit crawl`
  - `webstart-audit ux-scan`
  - `webstart-audit ia-scan`
  - `webstart-audit tech-scan`
  - `webstart-audit api-scan`
  - `webstart-audit report-draft`

## 현재 자동화 범위

1. `crawl`
페이지 다중 수집, 내부 링크 BFS 탐색, 스크린샷 저장, `_audit/scraped-data.json` 호환 파일 생성

2. `ux-scan`, `ia-scan`
`_audit/derived/ux-summary.json`, `_audit/derived/ia-summary.json` 생성

3. `tech-scan`
요청 로그, 프레임워크 지문, 주요 리소스, 서버 헤더 수집

4. `api-scan`
동일 origin 기준 API 호출, JSON 응답 미리보기, 폼 필드 구조 수집

5. `report-draft`
`_audit/report.md`와 `_agency/client-brief.md` 초안 생성, `status.json`/`status.md` 갱신

## 다음 단계 제안

1. `audit-tech`, `audit-db` 결과도 summary JSON에서 직접 Markdown 초안까지 생성
2. `Lighthouse`, `axe-core`, `OpenAPI inference` 추가
3. `_audit/report.md` 품질을 위해 Known Gaps 계산 로직 고도화
