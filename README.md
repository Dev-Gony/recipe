# Recipe SNS Content

SNS에 게시할 레시피 콘텐츠를 조사하고, 세로형 이미지 시안을 만들고, 근거를 검토하는 작업 공간입니다.

## 산출물

- `research/`: 레시피 조사 결과와 출처
- `content/`: 카드뉴스 문구, 이미지 프롬프트, 게시 캡션
- `assets/`: 최종 PNG/JPG 이미지
- `review/`: 근거·표기·시각 품질 검토 결과

최종 게시 1안은 [`content/final-caption.md`](content/final-caption.md)의 홈파티 과일 부라타 리스 샐러드이며, 새 시안은 `assets/drafts/fruit-burrata-*`에서 확인할 수 있습니다. 레퍼런스와 응용 레시피 조사는 [`research/home-party-reference.md`](research/home-party-reference.md)에 기록되어 있습니다.

인스타그램 피드 캐러셀 4장은 [`content/instagram-feed.md`](content/instagram-feed.md)에서 업로드 순서와 캡션을 확인할 수 있습니다. 최종 PNG는 `assets/final/instagram-feed-home-party/`에 있습니다.

## 작업 원칙

1. 조리 시간·계량·안전 주장은 출처 또는 계산 근거를 남깁니다.
2. 이미지에 들어가는 한글 문구는 생성 모델에 전부 맡기지 않고, 필요하면 후처리로 정확하게 배치합니다.
3. 초안과 최종본을 파일명으로 구분하고 이전 작업은 게시본과 섞이지 않게 관리합니다.

## 에이전트 구성

조사 3명 → 결과가 준비되는 대로 콘텐츠 3명을 병렬 실행 → 시안이 모두 준비되면 검토 1명이 검증합니다. 기능별 브랜치는 `codex/recipe-*` 접두어를 사용합니다.
