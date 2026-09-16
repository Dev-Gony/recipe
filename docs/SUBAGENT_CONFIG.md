# Subagent configuration

이 프로젝트는 Codex의 프로젝트 범위 커스텀 에이전트를 사용합니다.

## 파일 구조

- `.codex/config.toml`: 멀티 에이전트 활성화, 동시 실행 수, 기본 모델·추론 강도
- `.codex/agents/*.toml`: 에이전트 한 명당 하나의 정의 파일

각 에이전트 파일의 필수 필드는 `name`, `description`, `developer_instructions`이고, `model`, `model_reasoning_effort`, `sandbox_mode`는 역할별로 선택·고정했습니다.

## 실행 순서

1. `recipe_fact_researcher`, `sns_reference_researcher`, `image_reference_researcher`를 동시에 실행합니다.
2. 조사 결과가 준비되면 `recipe_copy_editor`, `image_prompt_designer`, `instagram_feed_builder`를 동시에 실행합니다.
3. 산출물이 모두 준비되면 `recipe_reviewer`를 실행합니다.

다음처럼 요청하면 됩니다.

```text
이 프로젝트에서 3명의 조사 에이전트를 동시에 실행해 레시피 근거, SNS 카드 구조, 이미지 레퍼런스를 조사해줘.
조사 결과가 준비되는 대로 카피 편집자, 이미지 프롬프트 디자이너, 피드 빌더를 병렬 실행해줘.
세 결과를 모두 모은 뒤 recipe_reviewer가 근거와 이미지·문구를 검토하게 해줘.
```

프로젝트 설정은 개인 전역 설정과 분리되어 있으므로 이 저장소에서만 적용됩니다. 전역 에이전트가 필요하면 같은 TOML을 사용자 Codex 디렉터리의 `agents` 아래에 둡니다.
