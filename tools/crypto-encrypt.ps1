# ============================================================
# QClaw Crypto Encrypt
# Encrypts any text file → armored .md/.txt (AES-256-CBC + PBKDF2)
#
# Usage:
#   .\crypto-encrypt.ps1 -Source ".\secret.md" -Password "mykey"
#   .\crypto-encrypt.ps1 -Source ".\secret.md" -Password "mykey" -Target ".\encrypted.md"
#
# Parameters:
#   -Source   Path to plaintext file
#   -Password Encryption password / key (any string)
#   -Target   Output path (default: <source>.enc.<ext>)
# ============================================================

param(
    [Parameter(Mandatory=$true)][string]$Source,
    [Parameter(Mandatory=$true)][string]$Password,
    [string]$Target = ""
)

$ErrorActionPreference = "Stop"

# ---- Resolve target path ----
if ($Target -eq "") {
    $Dir = Split-Path $Source -Parent
    $Name = [System.IO.Path]::GetFileNameWithoutExtension($Source)
    $Ext = [System.IO.Path]::GetExtension($Source)
    if ($Ext -eq "") { $Ext = ".md" }
    $Target = Join-Path $Dir "$Name.enc$Ext"
}

# ---- Read plaintext ----
if (-not (Test-Path $Source)) {
    Write-Host "[ERROR] Source not found: $Source" -ForegroundColor Red
    exit 1
}
$PlainBytes = [System.IO.File]::ReadAllBytes((Resolve-Path $Source))

# ---- Generate random salt + IV ----
$Rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$Salt = New-Object byte[] 16; $Rng.GetBytes($Salt)
$IV   = New-Object byte[] 16; $Rng.GetBytes($IV)

# ---- Derive AES-256 key via PBKDF2 ----
$Pbkdf2 = New-Object System.Security.Cryptography.Rfc2898DeriveBytes(
    $Password,
    $Salt,
    200000,
    [System.Security.Cryptography.HashAlgorithmName]::SHA256
)
$Key = $Pbkdf2.GetBytes(32)  # 256-bit key

# ---- AES-256-CBC encrypt ----
$Aes = [System.Security.Cryptography.Aes]::Create()
$Aes.Key = $Key
$Aes.IV = $IV
$Aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
$Aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

$Encryptor = $Aes.CreateEncryptor()
$CipherBytes = $Encryptor.TransformFinalBlock($PlainBytes, 0, $PlainBytes.Length)
$Encryptor.Dispose()
$Aes.Dispose()

# ---- Base64 armor ----
$Salt64   = [Convert]::ToBase64String($Salt)
$IV64     = [Convert]::ToBase64String($IV)
$Cipher64 = [Convert]::ToBase64String($CipherBytes)

# ---- Write output ----
$Armored = @"
-----BEGIN QCLAW ENCRYPTED-----
$Salt64
$IV64
$Cipher64
-----END QCLAW ENCRYPTED-----
"@

$OutPath = try { (Resolve-Path $Target -ErrorAction Stop).Path } catch { $Target }
[System.IO.File]::WriteAllText($OutPath, $Armored, [System.Text.UTF8Encoding]::new($false))

$Size = [math]::Round((Get-Item $Target).Length / 1KB, 1)
Write-Host "[OK] Encrypted: $Source → $Target ($Size KB)" -ForegroundColor Green
Write-Host "     Algorithm: AES-256-CBC | PBKDF2-SHA256 | 200k iterations" -ForegroundColor Gray
