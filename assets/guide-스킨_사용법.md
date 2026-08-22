# 가이드 스킨 사용법 (`assets/guide.css`)

한 가지 주제를 처음 보는 사람에게 **위에서 아래로 훑어 읽히는 안내 페이지**를 만드는 공용 디자인이다.
원본은 `codex/distrokid-guide`(디스트로키드 가이드)의 `app/globals.css`이고, 여기서 주제 색·주제 전용 부품을 걷어내 재사용 가능하게 만든 것이다.

- **스킨**: `assets/guide.css`
- **견본(복사해서 시작)**: `assets/_guide-template.html`
- **완성 예시**: https://kimyoungil21.github.io/r-64fe20c017/ 안의 가이드형 페이지들

핵심 규칙 한 줄: **HTML 한 장 + CSS 한 장.** 빌드 도구도, 리액트도, 외부 JS 라이브러리도 쓰지 않는다.

---

## 1. 새 페이지 만들어 배포하기

```
1) mkdir D:\work\lyrics-pages\<슬러그>
2) assets\_guide-template.html 를 <슬러그>\index.html 로 복사
3) <link rel="stylesheet" href="guide.css">  →  ../assets/guide.css 로 고친다   ← 제일 많이 까먹는 곳
4) <title> · 히어로 · 목차 · 섹션 내용을 실제 글로 교체
5) 브라우저로 열어 확인 (아래 3번 항목)
6) git add / commit / push
7) 1~2분 뒤 https://kimyoungil21.github.io/r-64fe20c017/<슬러그>/ 에서 열린다
```

`lyrics-pages` 저장소는 **푸시가 곧 배포**다(GitHub Pages, 빌드 단계 없음). 슬러그는 영문 소문자·하이픈으로 짓는다(`distrokid`, `suno-start` 처럼).

목차(`.side-nav`)의 `href="#s1"`과 각 섹션의 `id="s1"`은 **짝이 맞아야** 한다. 섹션을 지우면 목차 줄도 같이 지운다.

---

## 2. 컴포넌트 목록

### 큰 골격

| 클래스 | 언제 쓰나 |
|---|---|
| `.hero` | 페이지 맨 위 검은 표지. 안에 `.topbar`(브랜드+배지) + `.hero-grid`(제목·설명·버튼·오른쪽 카드) |
| `.hero.plain` | 히어로 오른쪽 아래 동심원 장식을 끌 때 |
| `.hero-card` | 히어로 오른쪽의 기울어진 카드. 안에 `.hero-card-row` 여러 줄. 1050px 아래에서는 자동으로 숨는다 |
| `.hero-card-disc` | **[선택 모듈]** LP판 장식. 음악 주제일 때만. 아니면 통째로 지운다 |
| `.page-shell` | 본문 2단(왼쪽 목차 230px + 오른쪽 내용). 좁아지면 1단이 되고 목차는 가로 알약 줄로 바뀐다 |
| `.side-nav` | 붙어 따라오는 목차. 현재 위치 항목에 `.is-active`가 붙는다(템플릿 맨 아래 인라인 JS가 처리) |
| `.section` + `.section-heading` | 본문 한 덩어리. 제목 위 `.chapter`(번호/라벨), 제목 아래 `p`(한두 줄 안내) |
| `.section.no-rule` | 아래 구분선을 지울 때 |

### 내용 부품

| 클래스 | 무엇 | 언제 쓰나 |
|---|---|---|
| `.summary-grid` + `.summary-card` | 2×2 요약 카드 | 페이지 맨 앞 "10분 요약". `.accent` / `.accent-2` 로 색 카드(둘 합쳐 2장까지) |
| `.quick-answer` | 검은 띠 + 큰 한 문장 | 페이지 전체를 한 문장으로 못 박을 때. 페이지당 1회 |
| `.choice-box` | 상황 → 추천 + 버튼 | "이런 사람이면 이걸 고르세요" |
| `.disclosure` | 테두리 위 작은 회색 글씨 | 제휴·면책 고지 (`.choice-box` 안에서 전체 폭 차지) |
| `.updated` | 아주 작은 회색 한 줄 | "마지막 확인일 …" |
| `.source-link` | 파란 링크 + ↗ | 공식 문서로 보내는 출처. 한 섹션에 1~2개 |
| `.flow` | 카드 → 카드 → 카드 | 과정·경로. 개수 제한 없음, 카드 사이에 `<b>→</b>` |
| `.flow.compact` | 낮은 흐름표 | 돈·시간처럼 글자가 짧은 흐름 |
| `.two-col` + `.info-card` | 나란한 두 상자 | "되는 것 / 안 되는 것". 빨간 쪽은 `.info-card.warning` |
| `.plain-note` | 파란 세로줄 회색 박스 | 오해를 바로잡는 한 문단. 섹션당 1회 |
| `.comparison` + `.compare-row` | 링크되는 비교 행 | 후보 나열(이름·`.meta`·설명·↗). 행 전체가 `<a>` |
| `.decision-strip` | 강조색 띠 | 비교 끝의 "빠르게 고르는 법" |
| `.prep-grid` + `.prep-card` | 동그란 배지 + 카드 | 준비물 목록. 배지엔 3~4글자 |
| `.callout` | 강조색 경고 상자 | "이건 하면 안 됩니다". 섹션당 1회 |
| `.steps` + `.step` | 번호 배지 + 제목 + 설명 | 실제 실행 순서. 한 단계 = 한 문단 |
| `.timeline` | 검은 라벨 + 칸 | "제출 → 며칠 안 → 발매일 → 3개월 뒤" |
| `.note-grid` | 3열 번호 카드 | 자주 하는 실수, 체크포인트. `.tinted`로 일부 강조 |
| `.stage-list` | 시점 / 할 일 / 설명 행 | "발매 전·직후·첫 주·계속" |
| `.split-2` + `.big-word` | 좌(강조색)/우(흰색) 두 패널 | 헷갈리는 두 개념 대비 |
| `.rule-columns` | 테두리 나눠진 N칸 | 경우별 규칙 한 줄씩. 칸 수 자유 |
| `.link-cards` | 카드 + 아래 붙는 출처 링크 | 수정·삭제·이동 같은 관리 항목 |
| `.check-columns` | 체크박스 목록 N열 | 제출 직전 점검표 (**저장 안 됨**, 눈으로 확인용) |
| `.faq-list` | details/summary 아코디언 | 자주 묻는 질문. `＋`가 열리면 45도 돌아 `×` |
| `.final-cta` + `.fineprint` | 강조색 마무리 상자 | 마지막 행동 유도 |
| `footer` | 회색 작은 글씨 | 면책 + 맨 위로 |
| `.button` | `.primary` `.secondary` `.dark` `.ghost` `.info` | 히어로에선 primary/secondary, 본문에선 info, 마무리에선 dark/ghost |

**호환 별칭**: `.record-card` `.record-meta` `.record-disc` `.referral-disclosure` `.referral-note` `.button.referral` `.mistake-grid` `.after-list` `.rights-split` `.rights-rules` `.manage-grid` `.money-hero`(→`.flow.compact`)는 원본 마크업을 그대로 옮겨올 때만 쓴다. **새 페이지는 위 표의 이름을 쓴다.**

---

## 3. 만든 뒤 반드시 눈으로 확인

`file://`은 브라우저 도구가 못 여니 로컬 서버로 연다.

```bash
cd /d/work/lyrics-pages && python -m http.server 8791
# → http://127.0.0.1:8791/<슬러그>/
```

확인할 것 두 가지.

1. **데스크탑 폭** — 히어로, 2단 배치, 목차가 스크롤 따라 강조되는지.
2. **모바일 폭** — 폭 390px. 창을 줄이기 어려우면 `<iframe src="/<슬러그>/" style="width:390px;height:700px">` 한 장짜리 미리보기 파일을 임시로 만들어 보면 확실하다. (확인 뒤 그 임시 파일은 지운다.)

가로 스크롤이 생기면 실패다. 콘솔에서 `document.documentElement.scrollWidth > 390` 이 `false`여야 한다.

---

## 4. 팔레트만 바꿔 다른 주제 입히기

색은 전부 `guide.css` 맨 위 `:root`에 있다. **CSS를 고치지 말고**, 페이지 `<head>` 안에 작은 `<style>`로 덮어쓴다. 그래야 스킨 한 벌로 여러 주제를 굴릴 수 있다.

```html
<link rel="stylesheet" href="../assets/guide.css">
<style>
  :root { --accent:#f1c84b; --accent-2:#b74634; --link:#174f3b; }
</style>
```

실제로 써먹을 수 있는 조합 두 개.

**(가) 숲·노트 — 차분한 실무 문서용** (형제 프로젝트 `web-guide`가 쓰는 계열)

```css
:root{
  --ink:#1d211f; --paper:#f6f4ee; --surface:#fffefa;
  --accent:#f1c84b;   /* 노랑 */
  --accent-2:#b74634; /* 벽돌빨강 */
  --link:#174f3b;     /* 진초록 */
  --muted:#666d68; --line:#dcded8; --soft:#e4efe9; --warn-soft:#f6e0dc;
  --hero-bg:#12211b; --hero-bg-2:#182c24; --hero-card-bg:#1b3128;
  --hero-line:#2b4438; --hero-line-2:#365446; --hero-line-3:#436655;
}
```

**(나) 자정·보라 — 밤/프리미엄 느낌**

```css
:root{
  --ink:#17151f; --paper:#f4f1fa; --surface:#fffdff;
  --accent:#d9c2ff; --accent-2:#ff9ec7; --link:#5b2ecb;
  --muted:#6a6577; --line:#ddd6ea; --soft:#e9e2f5; --warn-soft:#ffe1ec;
  --hero-bg:#17151f; --hero-bg-2:#1e1a2b; --hero-card-bg:#221d31;
  --hero-line:#3a3450; --hero-line-2:#4a4266; --hero-line-3:#5b527a;
}
```

바꿀 때 주의할 점.

- `--accent` / `--accent-2` 위에는 **검은 글자**가 올라간다. 어두운 색을 넣고 싶으면 `--on-accent`(큰 글자)와 `--on-accent-dim`(작은 글자)도 함께 밝은 색으로 바꾼다.
- `--link`는 링크·번호·라벨에 다 쓰인다. 아이보리 바탕에서 읽히는 **진한** 색으로.
- 히어로는 어두운 면이라 `--hero-*` 계열을 따로 둔다. 배경만 바꾸고 선 색을 안 바꾸면 테두리가 튄다.
- 폰트를 세리프로 바꾸고 싶으면 `--font-sans`만 덮어쓴다(예: `Georgia, "Noto Serif KR", serif`). 다만 한글 본문은 Pretendard가 가장 안전하다.

---

## 5. 하지 말 것

- **외부 JS 라이브러리 금지.** jQuery·Alpine·차트 라이브러리 전부 안 쓴다. 아코디언은 `<details>`, 목차 강조는 템플릿에 든 20줄짜리 인라인 스크립트로 충분하다.
- **빌드 도구 도입 금지.** Next·vite·Tailwind를 다시 끌고 오지 않는다. 원본이 Next였지만 배포물은 결국 JS 0개짜리 HTML 한 장이었다. 그 상태를 유지한다.
- **`guide.css` 안에 특정 페이지 전용 색·문구를 넣지 말 것.** 페이지 전용은 그 페이지의 `<style>`에.
- **`assets/guide.css` 파일 이름·경로를 바꾸지 말 것.** 이미 이 스킨을 링크한 페이지가 전부 깨진다.
- **호환 별칭 이름으로 새로 쓰지 말 것**(`.record-card` 등). 별칭은 옛 마크업을 옮겨올 때만.
- **CDN 폰트 링크를 지우지 말 것.** `guide.css` 첫 줄의 Pretendard `@import`가 없으면 폰트 없는 PC에서 굴림으로 떨어진다.
- **체크박스에 값 저장을 기대하지 말 것.** `.check-columns`는 새로고침하면 초기화된다. 저장이 필요하면 그건 이 스킨의 일이 아니다.
