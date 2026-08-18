$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$url = 'https://kimyoungil21.github.io/r-64fe20c017/pli-1on1/setup.ps1'
$expected = '435AFE9C4CF07496A3676097010FC79CC9B08E0FE412562594E510C2B1610DC0'

$client = New-Object Net.WebClient
try {
  [byte[]]$bytes = $client.DownloadData($url)
} finally {
  $client.Dispose()
}

$hasher = [Security.Cryptography.SHA256]::Create()
try {
  $actual = [BitConverter]::ToString($hasher.ComputeHash($bytes)).Replace('-', '')
} finally {
  $hasher.Dispose()
}

if ($actual -cne $expected) {
  throw "Setup hash mismatch. Expected $expected but received $actual."
}

$code = [Text.Encoding]::UTF8.GetString($bytes)
& ([ScriptBlock]::Create($code))
