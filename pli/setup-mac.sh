#!/bin/bash
# =====================================================
#  유튜브 플리 자동화 챌린지 — 설치 도우미 (맥)
#
#  쓰는 법 (설명서의 복사 버튼이 알아서 넣어 줍니다):
#    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/KIMYOUNGIL21/r-64fe20c017/main/pli/setup-mac.sh)"
#
#  하는 일: 필요한 것을 "처음에 전부" 설치한다.
#    Homebrew · Git · Python · ffmpeg · Node.js · Chrome · Codex(또는 클로드코드) · Orca
#    + 유튜브 업로드용 파이썬 패키지 2개
#    + ~/플리공장 폴더와 재료/완성/기록 만들기
#    + 셋팅코드 zip 이 있으면 풀어 넣기 (없어도 정상 — 챌린지 시작할 때 씀)
#    + 수노용 Playwright 미리 받아 두기
#
#  여러 번 실행해도 안전합니다 (이미 된 것은 건너뜁니다).
#
#  ⚠ 주의: bash 는 한글 변수명을 못 쓴다. 변수·함수 이름은 반드시 영문.
#          (화면에 보이는 글자만 한글)
# =====================================================

# 일부러 set -e 를 쓰지 않는다 — 하나 실패해도 나머지는 계속 설치해야 한다.

AI="${PLI_AI:-codex}"
if [ "$AI" = "codex" ]; then AI_NAME="Codex"; else AI_NAME="클로드코드"; fi

FACTORY="$HOME/플리공장"
RESULT=""

say()  { printf '\033[36m%s\033[0m\n' "$1"; }
ok()   { printf '  \033[32m[OK]\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m[!]\033[0m %s\n' "$1"; }
step() { printf '\n\033[1m▶ %s\033[0m\n' "$1"; }
has()  { command -v "$1" >/dev/null 2>&1; }
record() { RESULT="${RESULT}${1}|${2}"$'\n'; }

say '====================================================='
say '  유튜브 플리 자동화 챌린지 - 설치 도우미 (맥)'
say "  고른 AI: $AI_NAME"
say '  이 창이 알아서 전부 설치합니다. 닫지 말고 기다려 주세요.'
say '  (15~30분 걸릴 수 있습니다. 조용해 보여도 진행 중입니다.)'
say '====================================================='

# ── 0) 내 맥이 어떤 종류인지 ───────────────────────────
step '0/8  내 맥 확인'
CHIP="$(uname -m)"
if [ "$CHIP" = "arm64" ]; then
  KIND="애플 실리콘 (M칩)"; BREW_BIN="/opt/homebrew/bin"; ORCA_DMG="orca-macos-arm64.dmg"
else
  KIND="인텔"; BREW_BIN="/usr/local/bin"; ORCA_DMG="orca-macos-x64.dmg"
fi
ok "$KIND 맥입니다"
# 맥 종류는 합격·불합격 항목이 아니므로 결과 표에는 넣지 않는다 (인텔이 오류로 잡히던 문제)

# ── 1) Homebrew (맥의 앱 설치 관리자) ──────────────────
step '1/8  Homebrew 설치 (맥의 앱 설치 관리자)'
[ -x "$BREW_BIN/brew" ] && eval "$("$BREW_BIN/brew" shellenv)"
if has brew; then
  ok 'Homebrew - 이미 있음'
  record "Homebrew" "있음"
else
  warn '설치 중에 맥 로그인 비밀번호를 물어봅니다.'
  warn '입력해도 화면에 아무것도 안 보이는 게 정상입니다. 그대로 치고 Enter 를 누르세요.'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [ -x "$BREW_BIN/brew" ] && eval "$("$BREW_BIN/brew" shellenv)"
  if has brew; then
    ok 'Homebrew 설치 완료'; record "Homebrew" "방금 설치"
    # 다음에 터미널을 열어도 brew 가 잡히도록
    for PROFILE in "$HOME/.zprofile" "$HOME/.bash_profile"; do
      grep -q 'brew shellenv' "$PROFILE" 2>/dev/null || \
        echo "eval \"\$($BREW_BIN/brew shellenv)\"" >> "$PROFILE"
    done
  else
    warn 'Homebrew 설치를 확인하지 못했습니다.'
    warn '터미널을 닫고 설치 한 줄을 한 번 더 실행해 주세요.'
    exit 1
  fi
fi

# ── 2) 기본 도구 ───────────────────────────────────────
step '2/8  기본 도구 설치 (Git · Python · ffmpeg · Node.js)'
brew_need() {  # brew_need <brew이름> <표시이름> <확인명령>
  if has "$3"; then ok "$2 - 이미 있음"; record "$2" "있음"; return; fi
  say "  $2 설치 중... 창을 닫지 마세요."
  brew install "$1" >/dev/null 2>&1
  hash -r 2>/dev/null
  if has "$3"; then ok "$2 설치 완료"; record "$2" "방금 설치"
  else warn "$2 이 아직 인식되지 않습니다 (터미널을 닫고 한 번 더 실행하면 대개 잡힙니다)"; record "$2" "확인 필요"; fi
}
brew_need git         'Git'     git
brew_need python@3.12 'Python'  python3
brew_need ffmpeg      'ffmpeg'  ffmpeg
brew_need node        'Node.js' npm

step '3/8  Chrome 설치'
if [ -d "/Applications/Google Chrome.app" ]; then
  ok 'Chrome - 이미 있음'; record "Chrome" "있음"
else
  say '  Chrome 설치 중...'
  brew install --cask google-chrome >/dev/null 2>&1
  if [ -d "/Applications/Google Chrome.app" ]; then ok 'Chrome 설치 완료'; record "Chrome" "방금 설치"
  else warn 'Chrome 설치를 확인하지 못했습니다'; record "Chrome" "확인 필요"; fi
fi

# ── 4) 고른 AI 도구 ────────────────────────────────────
step "4/8  $AI_NAME 설치"
if [ "$AI" = "codex" ]; then
  if has codex; then
    ok 'Codex - 이미 있음'; record "Codex" "있음"
  elif ! has npm; then
    warn 'Node.js 가 아직 인식되지 않아 Codex 를 설치할 수 없습니다.'
    warn '터미널을 닫고 설치 한 줄을 한 번 더 실행해 주세요.'
    record "Codex" "재실행 필요"
  else
    say '  Codex 설치 중... 창을 닫지 마세요.'
    npm install -g @openai/codex >/dev/null 2>&1
    hash -r 2>/dev/null
    if has codex; then ok 'Codex 설치 완료'; record "Codex" "방금 설치"
    else warn 'Codex 가 아직 인식되지 않습니다 (터미널 닫고 한 번 더 실행)'; record "Codex" "확인 필요"; fi
  fi
else
  if has claude; then
    ok '클로드코드 - 이미 있음'; record "클로드코드" "있음"
  else
    say '  클로드코드 설치 중...'
    curl -fsSL https://claude.ai/install.sh | bash >/dev/null 2>&1
    export PATH="$HOME/.local/bin:$PATH"; hash -r 2>/dev/null
    if has claude; then ok '클로드코드 설치 완료'; record "클로드코드" "방금 설치"
    else warn '클로드코드가 아직 인식되지 않습니다 (터미널 닫고 한 번 더 실행)'; record "클로드코드" "확인 필요"; fi
  fi
fi

# ── 5) Orca ────────────────────────────────────────────
step '5/8  Orca 설치'
if [ -d "/Applications/Orca.app" ]; then
  ok 'Orca - 이미 있음'; record "Orca" "있음"
else
  say '  Orca 내려받는 중...'
  TMPDIR_PLI="$(mktemp -d)"
  if curl -fsSL "https://github.com/stablyai/orca/releases/latest/download/$ORCA_DMG" -o "$TMPDIR_PLI/orca.dmg"; then
    MOUNT="$(hdiutil attach "$TMPDIR_PLI/orca.dmg" -nobrowse -quiet | grep -o '/Volumes/.*' | head -n 1)"
    APP="$(find "$MOUNT" -maxdepth 1 -name '*.app' 2>/dev/null | head -n 1)"
    if [ -n "$APP" ]; then
      cp -R "$APP" /Applications/ 2>/dev/null
      # 인터넷에서 받은 앱은 맥이 막아 둔다 — 그 표시를 떼어내야 "손상되었습니다" 가 안 뜬다
      xattr -dr com.apple.quarantine "/Applications/$(basename "$APP")" 2>/dev/null
      ok 'Orca 설치 완료'; record "Orca" "방금 설치"
    else
      warn 'Orca 앱을 dmg 안에서 찾지 못했습니다'; record "Orca" "확인 필요"
    fi
    [ -n "$MOUNT" ] && hdiutil detach "$MOUNT" -quiet 2>/dev/null
  else
    warn '자동 다운로드 실패. 브라우저에서 직접 받아 주세요: https://onorca.dev/download'
    record "Orca" "직접 설치"
  fi
  rm -rf "$TMPDIR_PLI"
fi

# ── 6) 유튜브 업로드용 파이썬 패키지 ───────────────────
step '6/8  유튜브 업로드용 파이썬 패키지'
if ! has python3; then
  warn 'Python 이 아직 인식되지 않습니다. 터미널을 닫고 한 번 더 실행해 주세요.'
  record "파이썬 패키지" "재실행 필요"
else
  python3 -m pip install --user --quiet google-api-python-client google-auth-oauthlib >/dev/null 2>&1 \
    || python3 -m pip install --user --quiet --break-system-packages google-api-python-client google-auth-oauthlib >/dev/null 2>&1
  if python3 -c 'import googleapiclient, google_auth_oauthlib' >/dev/null 2>&1; then
    ok '유튜브 업로드용 패키지 준비 완료'; record "파이썬 패키지" "준비됨"
  else
    warn '패키지 설치를 확인하지 못했습니다 (챌린지 시작할 때 AI가 다시 시도합니다)'
    record "파이썬 패키지" "나중에"
  fi
fi

# ── 7) 공장 폴더 + 셋팅코드 ────────────────────────────
step '7/8  공장 폴더 만들기'
mkdir -p "$FACTORY/재료" "$FACTORY/완성" "$FACTORY/기록"
ok "$FACTORY 준비 완료 (재료 · 완성 · 기록)"
record "공장 폴더" "준비됨"

if [ -f "$FACTORY/공장.py" ]; then
  ok '셋팅코드 - 이미 들어 있음'; record "셋팅코드" "있음"
else
  ZIPFILE="$(ls -t "$HOME/Downloads"/*셋팅코드*.zip "$HOME/Desktop"/*셋팅코드*.zip 2>/dev/null | head -n 1)"
  # 사파리는 "안전한 파일 자동 열기"가 기본 켜짐이라 zip 을 받자마자 풀어 버린다.
  # 그러면 zip 이 아니라 폴더만 남는다 — 그 경우도 받아 준다.
  UNZIPPED=""
  if [ -z "$ZIPFILE" ]; then
    UNZIPPED="$(find "$HOME/Downloads" "$HOME/Desktop" -maxdepth 3 -name '공장.py' 2>/dev/null | head -n 1)"
  fi
  if [ -n "$UNZIPPED" ]; then
    say "  이미 풀려 있는 셋팅코드를 찾았습니다 (사파리가 자동으로 푼 것으로 보입니다)"
    cp -R "$(dirname "$UNZIPPED")"/. "$FACTORY"/ 2>/dev/null
    if [ -f "$FACTORY/공장.py" ]; then ok '셋팅코드 넣기 완료'; record "셋팅코드" "방금 넣음"
    else warn '옮기는 데 실패했습니다'; record "셋팅코드" "확인 필요"; fi
  elif [ -n "$ZIPFILE" ]; then
    unzip -o -q "$ZIPFILE" -d "$FACTORY" 2>/dev/null
    if [ ! -f "$FACTORY/공장.py" ]; then
      INNER="$(find "$FACTORY" -maxdepth 2 -name '공장.py' 2>/dev/null | head -n 1)"
      [ -n "$INNER" ] && mv "$(dirname "$INNER")"/* "$FACTORY"/ 2>/dev/null
    fi
    if [ -f "$FACTORY/공장.py" ]; then ok '셋팅코드 넣기 완료'; record "셋팅코드" "방금 넣음"
    else warn '압축은 풀렸는데 공장.py 를 찾지 못했습니다'; record "셋팅코드" "확인 필요"; fi
  else
    ok '셋팅코드 - 오늘은 필요 없습니다 (챌린지 시작할 때 씁니다)'
    printf '     나중에 받은 zip 을 다운로드한 뒤 이 설치 한 줄을 한 번 더 실행하면 자동으로 들어갑니다.\n'
    record "셋팅코드" "나중에"
  fi
fi

# ── 7-b) 구글 열쇠 (안내서 8단계에서 받아 둔 것) ────────
step '7-b  구글 열쇠 넣기'
if [ -f "$FACTORY/구글인증.json" ]; then
  ok '구글 열쇠 - 이미 들어 있음'
  record "구글 열쇠" "있음"
else
  # 구글 콘솔에서 받으면 client_secret_*.json 이라는 이름으로 다운로드된다
  KEYFILE="$(ls -t "$HOME/Downloads"/client_secret*.json "$HOME/Desktop"/client_secret*.json 2>/dev/null | head -n 1)"
  if [ -n "$KEYFILE" ]; then
    cp "$KEYFILE" "$FACTORY/구글인증.json" 2>/dev/null
    if [ -f "$FACTORY/구글인증.json" ]; then
      ok "구글 열쇠 넣기 완료 ($(basename "$KEYFILE"))"
      record "구글 열쇠" "방금 넣음"
    else warn '옮기는 데 실패했습니다'; record "구글 열쇠" "확인 필요"; fi
  else
    ok '구글 열쇠 - 아직 안 만드셨네요 (안내서 8단계에서 만듭니다)'
    printf '     만든 뒤 이 설치 한 줄을 한 번 더 실행하면 자동으로 들어갑니다.\n'
    record "구글 열쇠" "나중에"
  fi
fi

# ── 8) 수노용 Playwright ───────────────────────────────
step '8/8  수노용 브라우저 도구 준비'
if ! has npx; then
  warn 'Node.js 가 아직 인식되지 않아 건너뜁니다 (나중에 AI가 처리합니다)'
  record "수노 브라우저" "나중에"
else
  SUNO="$FACTORY/기록/수노브라우저"
  mkdir -p "$SUNO"
  say '  Playwright 내려받는 중... (처음 한 번만, 몇 분 걸립니다)'
  npx -y "@playwright/mcp@latest" --browser chrome --user-data-dir "$SUNO" --help >/dev/null 2>&1
  ok 'Playwright 준비 완료'
  record "수노 브라우저" "준비됨"
  ( cd "$FACTORY" 2>/dev/null || exit 0
    if [ "$AI" = "codex" ] && has codex; then
      codex mcp list 2>/dev/null | grep -q playwright || \
        codex mcp add playwright -- npx -y "@playwright/mcp@latest" --browser chrome --user-data-dir "./기록/수노브라우저" >/dev/null 2>&1
    elif [ "$AI" = "claude" ] && has claude; then
      claude mcp list 2>/dev/null | grep -q playwright || \
        claude mcp add --scope local playwright -- npx -y "@playwright/mcp@latest" --browser chrome --user-data-dir "./기록/수노브라우저" >/dev/null 2>&1
    fi )
fi

# ── 결과 표 ────────────────────────────────────────────
step '설치 결과'
printf '\n  내 맥: %s\n\n' "$KIND"
PROBLEMS=0
while IFS='|' read -r NAME STATE; do
  [ -z "$NAME" ] && continue
  case "$STATE" in
    있음|"방금 설치"|준비됨|"방금 넣음"|나중에) printf '  \033[32m[OK]\033[0m %s — %s\n' "$NAME" "$STATE" ;;
    *) printf '  \033[33m[확인]\033[0m %s — %s\n' "$NAME" "$STATE"; PROBLEMS=$((PROBLEMS+1)) ;;
  esac
done <<< "$RESULT"
printf '\n'

if [ "$PROBLEMS" -eq 0 ]; then
  printf '  \033[32m✅ 설치 준비 완료\033[0m\n'
else
  warn "확인이 필요한 항목이 ${PROBLEMS}개 있습니다."
  warn '대부분은 터미널을 닫고 설치 한 줄을 한 번 더 실행하면 해결됩니다.'
fi

# ── 로그인 ─────────────────────────────────────────────
printf '\n'
say '─────────────────────────────────────'
if [ "$AI" = "codex" ] && has codex; then
  say '마지막 순서: ChatGPT(Codex) 로그인'
  say '브라우저가 열리면 평소 쓰는 계정으로 로그인하세요.'
  codex login
elif [ "$AI" = "claude" ] && has claude; then
  say '마지막 순서: 클로드 로그인'
  say '브라우저가 열리면 평소 쓰는 계정으로 로그인하세요.'
  claude
else
  warn "$AI_NAME 이 인식되지 않아 로그인 단계를 건너뜁니다."
  warn '터미널을 닫고 설치 한 줄을 한 번 더 실행해 주세요.'
fi

printf '\n'
say '여기까지 되었으면 설명서 다음 단계로 가세요.'
say "Orca 를 열고 폴더는 $FACTORY 을 고르면 됩니다."
