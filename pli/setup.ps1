# =====================================================
#  유튜브 플리 자동화 챌린지 — 설치 도우미 (윈도우)
#  하는 일: Git → 클로드코드 → Orca 확인/설치 → 클로드 로그인 창
#  이미 설치된 것은 건너뜁니다 (여러 번 실행해도 안전)
# =====================================================
$ErrorActionPreference = 'Continue'

function Say($t)  { Write-Host $t -ForegroundColor Cyan }
function Ok($t)   { Write-Host ("  [OK] " + $t) -ForegroundColor Green }
function Warn($t) { Write-Host ("  [!] " + $t) -ForegroundColor Yellow }
function Has($n)  { return ($null -ne (Get-Command $n -ErrorAction SilentlyContinue)) }
function RefreshPath {
  $m = [Environment]::GetEnvironmentVariable('Path','Machine')
  $u = [Environment]::GetEnvironmentVariable('Path','User')
  $env:Path = $m + ';' + $u
}

Say '====================================================='
Say '  유튜브 플리 자동화 챌린지 - 설치 도우미'
Say '  이 창이 알아서 설치합니다. 닫지 말고 기다려 주세요.'
Say '====================================================='
Say ''

# 0) winget (윈도우 기본 앱 설치 관리자)
if (-not (Has 'winget')) {
  Warn 'winget(앱 설치 관리자)이 없는 PC입니다.'
  Warn '지금 열리는 스토어 페이지에서 [설치]를 누른 뒤, 처음부터 다시 실행해 주세요.'
  Start-Process 'ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1'
  Read-Host '읽었으면 엔터를 눌러 종료'
  exit 1
}
Ok 'winget 확인'

# 1) Git
if (Has 'git') { Ok 'Git - 이미 설치되어 있음' }
else {
  Say '[1/3] Git 설치 중... (몇 분 걸릴 수 있어요)'
  winget install -e --id Git.Git --accept-package-agreements --accept-source-agreements --silent | Out-Null
  RefreshPath
  if (Has 'git') { Ok 'Git 설치 완료' }
  else { Warn 'Git이 아직 인식되지 않습니다. 이 창을 닫고 한 번 더 실행해 주세요.' }
}

# 2) 클로드코드
RefreshPath
if (Has 'claude') { Ok '클로드코드 - 이미 설치되어 있음' }
else {
  Say '[2/3] 클로드코드 설치 중...'
  try { Invoke-RestMethod 'https://claude.ai/install.ps1' | Invoke-Expression }
  catch { Warn ('클로드코드 설치 중 오류: ' + $_.Exception.Message) }
  RefreshPath
  if (Has 'claude') { Ok '클로드코드 설치 완료' }
  else { Warn '클로드코드가 아직 인식되지 않습니다. 이 창을 닫고 한 번 더 실행해 주세요.' }
}

# 3) Orca
$orcaExe = Join-Path $env:LOCALAPPDATA 'Programs\orca\Orca.exe'
if (Test-Path $orcaExe) { Ok 'Orca - 이미 설치되어 있음' }
else {
  Say '[3/3] Orca 내려받는 중... (조금 걸립니다)'
  $tmp = Join-Path $env:TEMP 'orca-windows-setup.exe'
  try {
    Invoke-WebRequest 'https://github.com/stablyai/orca/releases/latest/download/orca-windows-setup.exe' -OutFile $tmp -UseBasicParsing
    Ok '다운로드 완료. 설치 창이 뜨면 안내대로 [다음]을 눌러 주세요.'
    Start-Process $tmp
  } catch {
    Warn ('자동 다운로드 실패: ' + $_.Exception.Message)
    Warn '브라우저가 열리면 Windows용 설치 파일을 직접 받아 실행해 주세요.'
    Start-Process 'https://onorca.dev/download'
  }
}

# 4) 클로드 로그인
Say ''
Say '─────────────────────────────────────'
if (Has 'claude') {
  Say '마지막 순서: 클로드 로그인'
  Say '잠시 후 검은 새 창에 클로드가 열립니다.'
  Say '안내에 따라 브라우저에서 로그인하세요. 끝나면 그 창은 닫아도 됩니다.'
  Start-Process cmd -ArgumentList '/k','claude'
} else {
  Warn '클로드코드가 인식되지 않아 로그인 단계를 건너뜁니다.'
  Warn '이 창을 닫고, 설치 한 줄을 한 번 더 실행해 주세요.'
}
Say ''
Say '여기까지 되었으면 설명서 다음 단계(Orca 열기)로 가세요.'
Read-Host '엔터를 누르면 이 창이 닫힙니다'
