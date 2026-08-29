$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$url = 'https://kimyoungil21.github.io/r-64fe20c017/pli/setup.ps1'
$expected = '54737A5B520D689107E96B40CC14186B1950B4A8D8A17FA1891B7DDBE6CE2462'

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
