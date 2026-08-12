# =====================================================
#  유튜브 플리 자동화 챌린지 — 설치 도우미 (윈도우)
#
#  쓰는 법 (설명서의 복사 버튼이 알아서 골라 줍니다):
#    클로드 길 :  irm https://raw.githubusercontent.com/KIMYOUNGIL21/r-64fe20c017/main/pli/setup.ps1 | iex
#    코덱스 길 :  $env:PLI_AI='codex'; irm https://raw.githubusercontent.com/KIMYOUNGIL21/r-64fe20c017/main/pli/setup.ps1 | iex
#
#  하는 일: 필요한 것을 "처음에 전부" 설치한다.
#    Git · Python · ffmpeg · Node.js · Chrome · (클로드코드 또는 Codex) · Orca
#    + 유튜브 업로드용 파이썬 패키지 2개
#    + C:\플리공장 폴더와 재료/완성/기록 만들기
#    + 다운로드 폴더의 셋팅코드 zip 풀어 넣기
#    + 수노용 Playwright 미리 받아 두기
#    마지막에 자가진단 표를 보여주고 로그인 창을 연다.
#
#  여러 번 실행해도 안전합니다 (이미 된 것은 건너뜁니다).
# =====================================================

& {
$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'SilentlyContinue'   # winget/다운로드 진행바가 화면을 어지럽히지 않게

# ── 고른 AI (환경변수로 넘어온다. 없으면 클로드) ──
$AI = if ($env:PLI_AI -eq 'codex') { 'codex' } else { 'claude' }
$AI이름 = if ($AI -eq 'codex') { 'Codex' } else { '클로드코드' }

$공장 = 'C:\플리공장'
$결과 = [ordered]@{}

function Say($t)  { Write-Host $t -ForegroundColor Cyan }
function Ok($t)   { Write-Host ("  [OK] "  + $t) -ForegroundColor Green }
function Warn($t) { Write-Host ("  [!] "   + $t) -ForegroundColor Yellow }
function Step($t) { Write-Host ''; Write-Host ("▶ " + $t) -ForegroundColor White }
function Has($n)  { return ($null -ne (Get-Command $n -ErrorAction SilentlyContinue)) }

function RefreshPath {
  $m = [Environment]::GetEnvironmentVariable('Path','Machine')
  $u = [Environment]::GetEnvironmentVariable('Path','User')
  $env:Path = $m + ';' + $u
}

# 한글은 화면에서 두 칸을 차지한다 — 그걸 세어서 칸을 맞춘다 (표가 어긋나지 않게)
function 폭맞춤($문자열, $칸) {
  $폭 = 0
  foreach ($c in $문자열.ToCharArray()) { $폭 += if ([int]$c -gt 0x1100) { 2 } else { 1 } }
  return $문자열 + (' ' * [Math]::Max(0, $칸 - $폭))
}

# winget 으로 하나 설치 (이미 있으면 건너뜀)
function Need($id, $이름, $명령) {
  if (Has $명령) { Ok ($이름 + ' - 이미 있음'); $결과[$이름] = '있음'; return }
  Say ('  ' + $이름 + ' 설치 중... 창을 닫지 마세요.')
  winget install -e --id $id --accept-package-agreements --accept-source-agreements --silent | Out-Null
  RefreshPath
  if (Has $명령) { Ok ($이름 + ' 설치 완료'); $결과[$이름] = '방금 설치' }
  else { Warn ($이름 + ' 이 아직 인식되지 않습니다 (창을 닫고 한 번 더 실행하면 대개 잡힙니다)'); $결과[$이름] = '확인 필요' }
}

Say '====================================================='
Say '  유튜브 플리 자동화 챌린지 - 설치 도우미'
Say ('  고른 AI: ' + $AI이름)
Say '  이 창이 알아서 전부 설치합니다. 닫지 말고 기다려 주세요.'
Say '  (10~20분 걸릴 수 있습니다. 중간에 조용해 보여도 진행 중입니다.)'
Say '====================================================='

# ── 0) winget 확인 ─────────────────────────────────────
Step '0/8  앱 설치 관리자 확인'
if (-not (Has 'winget')) {
  Warn 'winget(앱 설치 관리자)이 없는 PC입니다.'
  Warn '지금 열리는 스토어에서 [설치]를 누른 뒤, 이 설치 한 줄을 처음부터 다시 실행해 주세요.'
  Start-Process 'ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1'
  Read-Host '읽었으면 엔터'
  return
}
Ok 'winget 확인'

# ── 1) 기본 도구 한꺼번에 ──────────────────────────────
Step '1/8  기본 도구 설치 (Git · Python · ffmpeg · Node.js · Chrome)'
Need 'Git.Git'             'Git'      'git'
Need 'Python.Python.3.12'  'Python'   'python'
Need 'Gyan.FFmpeg'         'ffmpeg'   'ffmpeg'
Need 'OpenJS.NodeJS.LTS'   'Node.js'  'npm'
Need 'Google.Chrome'       'Chrome'   'chrome'

# Chrome 은 PATH 에 안 잡히는 경우가 많아 설치 경로로 한 번 더 확인
if ($결과['Chrome'] -ne '있음' -and $결과['Chrome'] -ne '방금 설치') {
  $크롬 = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
  ) | Where-Object { Test-Path $_ } | Select-Object -First 1
  if ($크롬) { Ok 'Chrome - 설치되어 있음'; $결과['Chrome'] = '있음' }
}

# ── 2) 고른 AI 도구 ────────────────────────────────────
Step ('2/8  ' + $AI이름 + ' 설치')
if ($AI -eq 'codex') {
  if (Has 'codex') { Ok 'Codex - 이미 있음'; $결과['Codex'] = '있음' }
  else {
    if (-not (Has 'npm')) {
      Warn 'Node.js 가 아직 인식되지 않아 Codex 를 설치할 수 없습니다.'
      Warn '이 창을 닫고 설치 한 줄을 한 번 더 실행해 주세요. (Node.js 는 이미 깔렸습니다)'
      $결과['Codex'] = '재실행 필요'
    } else {
      Say '  Codex 설치 중... 창을 닫지 마세요.'
      npm.cmd install -g @openai/codex 2>&1 | Out-Null
      RefreshPath
      if (Has 'codex') { Ok 'Codex 설치 완료'; $결과['Codex'] = '방금 설치' }
      else { Warn 'Codex 가 아직 인식되지 않습니다 (창 닫고 한 번 더 실행)'; $결과['Codex'] = '확인 필요' }
    }
  }
} else {
  if (Has 'claude') { Ok '클로드코드 - 이미 있음'; $결과['클로드코드'] = '있음' }
  else {
    Say '  클로드코드 설치 중... 창을 닫지 마세요.'
    try { Invoke-RestMethod 'https://claude.ai/install.ps1' | Invoke-Expression }
    catch { Warn ('설치 중 오류: ' + $_.Exception.Message) }
    RefreshPath
    if (Has 'claude') { Ok '클로드코드 설치 완료'; $결과['클로드코드'] = '방금 설치' }
    else { Warn '클로드코드가 아직 인식되지 않습니다 (창 닫고 한 번 더 실행)'; $결과['클로드코드'] = '확인 필요' }
  }
}

# ── 3) Orca ────────────────────────────────────────────
Step '3/8  Orca 설치'
$orcaExe = Join-Path $env:LOCALAPPDATA 'Programs\orca\Orca.exe'
if (Test-Path $orcaExe) { Ok 'Orca - 이미 있음'; $결과['Orca'] = '있음' }
else {
  Say '  Orca 설치 파일 내려받는 중...'
  $tmp = Join-Path $env:TEMP 'orca-windows-setup.exe'
  try {
    Invoke-WebRequest 'https://github.com/stablyai/orca/releases/latest/download/orca-windows-setup.exe' -OutFile $tmp -UseBasicParsing
    Warn 'Orca 설치 창이 열립니다 — [다음] · [설치] · [마침] 을 눌러 주세요. 끝나면 여기가 이어집니다.'
    Start-Process $tmp -Wait
    if (Test-Path $orcaExe) { Ok 'Orca 설치 완료'; $결과['Orca'] = '방금 설치' }
    else { Warn 'Orca 설치를 확인하지 못했습니다'; $결과['Orca'] = '확인 필요' }
  } catch {
    Warn ('자동 다운로드 실패: ' + $_.Exception.Message)
    Warn '브라우저가 열리면 Windows용 설치 파일을 직접 받아 실행해 주세요.'
    Start-Process 'https://onorca.dev/download'
    $결과['Orca'] = '직접 설치'
  }
}

# ── 4) 유튜브 업로드용 파이썬 패키지 ───────────────────
Step '4/8  유튜브 업로드용 파이썬 패키지'
RefreshPath
$파이썬 = if (Has 'python') { 'python' } elseif (Has 'py') { 'py' } else { $null }
if (-not $파이썬) {
  Warn 'Python 이 아직 인식되지 않습니다. 창을 닫고 한 번 더 실행해 주세요.'
  $결과['파이썬 패키지'] = '재실행 필요'
} else {
  & $파이썬 -m pip install --quiet --upgrade pip 2>&1 | Out-Null
  & $파이썬 -m pip install --quiet google-api-python-client google-auth-oauthlib 2>&1 | Out-Null
  & $파이썬 -c "import googleapiclient, google_auth_oauthlib" 2>&1 | Out-Null
  if ($LASTEXITCODE -eq 0) { Ok '유튜브 업로드용 패키지 준비 완료'; $결과['파이썬 패키지'] = '준비됨' }
  else { Warn '패키지 설치를 확인하지 못했습니다 (나중에 AI가 다시 시도합니다)'; $결과['파이썬 패키지'] = '확인 필요' }
}

# ── 5) 공장 폴더 ───────────────────────────────────────
Step '5/8  공장 폴더 만들기'
foreach ($p in @($공장, "$공장\재료", "$공장\완성", "$공장\기록")) {
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
}
Ok ($공장 + ' 준비 완료 (재료 · 완성 · 기록)')
$결과['공장 폴더'] = '준비됨'

# ── 6) 셋팅코드 zip 풀기 ───────────────────────────────
Step '6/8  셋팅코드 넣기'
# 원드라이브를 쓰는 PC는 진짜 바탕화면/다운로드가 OneDrive 아래에 있다 — 둘 다 본다
$받은폴더 = @(
  "$env:USERPROFILE\Downloads",
  "$env:USERPROFILE\Desktop",
  "$env:OneDrive\Downloads",
  "$env:OneDrive\Desktop",
  "$env:USERPROFILE\OneDrive\Downloads",
  "$env:USERPROFILE\OneDrive\Desktop"
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique
$zip = $받은폴더 | ForEach-Object { Get-ChildItem $_ -Filter '*셋팅코드*.zip' -ErrorAction SilentlyContinue } |
       Sort-Object LastWriteTime -Descending | Select-Object -First 1

# 압축을 직접 푼 사람도 있다 — 풀린 폴더가 있으면 그것도 받아 준다
$풀린것 = $null
if (-not $zip -and -not (Test-Path "$공장\공장.py")) {
  $풀린것 = $받은폴더 | ForEach-Object {
    Get-ChildItem $_ -Recurse -Depth 2 -Filter '공장.py' -ErrorAction SilentlyContinue
  } | Select-Object -First 1
}

if (Test-Path "$공장\공장.py") {
  Ok '셋팅코드 - 이미 들어 있음'
  $결과['셋팅코드'] = '있음'
} elseif ($풀린것) {
  Say '  이미 풀려 있는 셋팅코드를 찾았습니다'
  Copy-Item (Join-Path $풀린것.DirectoryName '*') -Destination $공장 -Recurse -Force -ErrorAction SilentlyContinue
  if (Test-Path "$공장\공장.py") { Ok '셋팅코드 넣기 완료'; $결과['셋팅코드'] = '방금 넣음' }
  else { Warn '옮기는 데 실패했습니다'; $결과['셋팅코드'] = '확인 필요' }
} elseif ($zip) {
  try {
    Expand-Archive -Path $zip.FullName -DestinationPath $공장 -Force
    # zip 안에 폴더가 한 겹 더 있으면 끌어올린다
    if (-not (Test-Path "$공장\공장.py")) {
      $안쪽 = Get-ChildItem $공장 -Directory | Where-Object { Test-Path (Join-Path $_.FullName '공장.py') } | Select-Object -First 1
      if ($안쪽) {
        Get-ChildItem $안쪽.FullName -Force | Move-Item -Destination $공장 -Force
        Remove-Item $안쪽.FullName -Recurse -Force -ErrorAction SilentlyContinue
      }
    }
    if (Test-Path "$공장\공장.py") { Ok ('셋팅코드 넣기 완료 (' + $zip.Name + ')'); $결과['셋팅코드'] = '방금 넣음' }
    else { Warn '압축은 풀렸는데 공장.py 를 찾지 못했습니다'; $결과['셋팅코드'] = '확인 필요' }
  } catch {
    Warn ('압축 풀기 실패: ' + $_.Exception.Message)
    $결과['셋팅코드'] = '확인 필요'
  }
} else {
  Ok '셋팅코드 - 오늘은 필요 없습니다 (챌린지 시작할 때 씁니다)'
  Say '     나중에 메일로 받은 zip 을 다운로드한 뒤 이 설치 한 줄을 한 번 더 실행하면 자동으로 들어갑니다.'
  $결과['셋팅코드'] = '나중에'
}

# ── 6-b) 구글 열쇠 (안내서 8단계에서 받아 둔 것) ────────
Step '6-b  구글 열쇠 넣기'
if (Test-Path "$공장\구글인증.json") {
  Ok '구글 열쇠 - 이미 들어 있음'
  $결과['구글 열쇠'] = '있음'
} else {
  # 구글 콘솔에서 받으면 client_secret_*.json 이라는 이름으로 다운로드된다
  $열쇠 = $받은폴더 | ForEach-Object {
    Get-ChildItem $_ -Filter 'client_secret*.json' -ErrorAction SilentlyContinue
  } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($열쇠) {
    Copy-Item $열쇠.FullName -Destination "$공장\구글인증.json" -Force -ErrorAction SilentlyContinue
    if (Test-Path "$공장\구글인증.json") {
      Ok ('구글 열쇠 넣기 완료 (' + $열쇠.Name + ')')
      $결과['구글 열쇠'] = '방금 넣음'
    } else { Warn '옮기는 데 실패했습니다'; $결과['구글 열쇠'] = '확인 필요' }
  } else {
    Ok '구글 열쇠 - 아직 안 만드셨네요 (안내서 8단계에서 만듭니다)'
    Say '     만든 뒤 이 설치 한 줄을 한 번 더 실행하면 자동으로 들어갑니다.'
    $결과['구글 열쇠'] = '나중에'
  }
}

# ── 7) 수노용 Playwright 미리 받기 ─────────────────────
Step '7/8  수노용 브라우저 도구 준비'
RefreshPath
if (-not (Has 'npx')) {
  Warn 'Node.js 가 아직 인식되지 않아 건너뜁니다 (나중에 AI가 처리합니다)'
  $결과['수노 브라우저'] = '나중에'
} else {
  $수노 = "$공장\기록\수노브라우저"
  if (-not (Test-Path $수노)) { New-Item -ItemType Directory -Path $수노 -Force | Out-Null }
  Say '  Playwright 내려받는 중... (처음 한 번만, 몇 분 걸립니다)'
  npx.cmd -y "@playwright/mcp@latest" --browser chrome --user-data-dir $수노 --help 2>&1 | Out-Null
  Ok 'Playwright 준비 완료'
  $결과['수노 브라우저'] = '준비됨'

  # MCP 등록은 공장 폴더 안에서 (실패해도 AI가 나중에 다시 한다)
  Push-Location $공장
  try {
    if ($AI -eq 'codex' -and (Has 'codex')) {
      $이미 = (codex mcp list 2>&1 | Out-String)
      if ($이미 -notmatch 'playwright') {
        codex mcp add playwright -- npx -y "@playwright/mcp@latest" --browser chrome --user-data-dir ".\기록\수노브라우저" 2>&1 | Out-Null
      }
      Ok 'Codex 에 수노 브라우저 연결'
    } elseif ($AI -eq 'claude' -and (Has 'claude')) {
      $이미 = (claude mcp list 2>&1 | Out-String)
      if ($이미 -notmatch 'playwright') {
        claude mcp add --scope local playwright -- npx -y "@playwright/mcp@latest" --browser chrome --user-data-dir ".\기록\수노브라우저" 2>&1 | Out-Null
      }
      Ok '클로드에 수노 브라우저 연결'
    }
  } catch { Warn '수노 브라우저 연결은 나중에 AI가 처리합니다' }
  Pop-Location
}

# ── 8) 자가진단 ────────────────────────────────────────
Step '8/8  설치 결과'
RefreshPath
Write-Host ''
Write-Host '  ┌──────────────────────┬──────────────┐' -ForegroundColor DarkGray
foreach ($k in $결과.Keys) {
  $v = $결과[$k]
  $색 = if ($v -match '있음|방금|준비됨|넣음') { 'Green' } else { 'Yellow' }
  Write-Host ('  │ ' + (폭맞춤 $k 20) + ' │ ') -NoNewline -ForegroundColor DarkGray
  Write-Host (폭맞춤 $v 12) -NoNewline -ForegroundColor $색
  Write-Host '│' -ForegroundColor DarkGray
}
Write-Host '  └──────────────────────┴──────────────┘' -ForegroundColor DarkGray
Write-Host ''

$문제 = @($결과.Keys | Where-Object { $결과[$_] -notmatch '있음|방금|준비됨|넣음|나중에' })
if ($문제.Count -eq 0) {
  Write-Host '  ✅ 설치 준비 완료' -ForegroundColor Green
} else {
  Warn ('아직 확인이 필요한 것: ' + ($문제 -join ', '))
  Warn '대부분은 이 창을 닫고 설치 한 줄을 한 번 더 실행하면 해결됩니다.'
}

# ── 로그인 ─────────────────────────────────────────────
Write-Host ''
Say '─────────────────────────────────────'
if ($AI -eq 'codex' -and (Has 'codex')) {
  Say '마지막 순서: ChatGPT(Codex) 로그인'
  Say '검은 새 창이 열립니다. 안내에 따라 브라우저에서 로그인하세요.'
  Start-Process cmd -ArgumentList '/k','codex login'
} elseif ($AI -eq 'claude' -and (Has 'claude')) {
  Say '마지막 순서: 클로드 로그인'
  Say '검은 새 창이 열립니다. 안내에 따라 브라우저에서 로그인하세요.'
  Start-Process cmd -ArgumentList '/k','claude'
} else {
  Warn ($AI이름 + ' 이 인식되지 않아 로그인 단계를 건너뜁니다.')
  Warn '이 창을 닫고 설치 한 줄을 한 번 더 실행해 주세요.'
}

Write-Host ''
Say '여기까지 되었으면 설명서 다음 단계로 가세요.'
Say ('Orca 를 열고 폴더는 ' + $공장 + ' 를 고르면 됩니다.')
Read-Host '다 보셨으면 엔터를 눌러 주세요 (이 창은 저절로 닫히지 않습니다)'
}
