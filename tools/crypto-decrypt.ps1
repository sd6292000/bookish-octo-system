# ============================================================
# QClaw Crypto Decrypt
# Decrypts an armored .md/.txt file back to plaintext
#
# Usage:
#   .\crypto-decrypt.ps1 -Source ".\secret.enc.md" -Password "mykey"
#   .\crypto-decrypt.ps1 -Source ".\secret.enc.md" -Password "mykey" -Target ".\plain.md"
#
# Parameters:
#   -Source   Path to encrypted file
#   -Password Decryption password / key
#   -Target   Output path (default: stdout; or specify a file)
# ============================================================

param(
    [Parameter(Mandatory=$true)][string]$Source,
    [Parameter(Mandatory=$true)][string]$Password,
    [string]$Target = ""
)

$ErrorActionPreference = "Stop"

# ---- Read armored file ----
if (-not (Test-Path $Source)) {
    Write-Host "[ERROR] Source not found: $Source" -ForegroundColor Red
    exit 1
}
$Text = [System.IO.File]::ReadAllText((Resolve-Path $Source), [System.Text.UTF8Encoding]::new($false))

# ---- Validate header ----
if ($Text -notmatch '-----BEGIN QCLAW ENCRYPTED-----\s*\r?\n(.*?)\r?\n(.*?)\r?\n(.*?)\r?\n-----END QCLAW ENCRYPTED-----') {
    Write-Host "[ERROR] Not a QClaw encrypted file (missing or invalid armor)" -ForegroundColor Red
    exit 1
}

$Salt64   = $Matches[1].Trim()
$IV64     = $Matches[2].Trim()
$Cipher64 = $Matches[3].Trim()

# ---- Decode from base64 ----
try {
    $Salt   = [Convert]::FromBase64String($Salt64)
    $IV     = [Convert]::FromBase64String($IV64)
    $Cipher = [Convert]::FromBase64String($Cipher64)
} catch {
    Write-Host "[ERROR] Invalid base64 in armored file: $_" -ForegroundColor Red
    exit 1
}

# ---- Derive key via PBKDF2 ----
$Pbkdf2 = New-Object System.Security.Cryptography.Rfc2898DeriveBytes(
    $Password,
    $Salt,
    200000,
    [System.Security.Cryptography.HashAlgorithmName]::SHA256
)
$Key = $Pbkdf2.GetBytes(32)

# ---- AES-256-CBC decrypt ----
try {
    $Aes = [System.Security.Cryptography.Aes]::Create()
    $Aes.Key = $Key
    $Aes.IV = $IV
    $Aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $Aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

    $Decryptor = $Aes.CreateDecryptor()
    $PlainBytes = $Decryptor.TransformFinalBlock($Cipher, 0, $Cipher.Length)
    $Decryptor.Dispose()
    $Aes.Dispose()
} catch {
    Write-Host "[ERROR] Decryption failed — wrong password or corrupted file" -ForegroundColor Red
    exit 1
}

# ---- Output ----
if ($Target -ne "") {
    [System.IO.File]::WriteAllBytes($Target, $PlainBytes)
    Write-Host "[OK] Decrypted: $Source → $Target" -ForegroundColor Green
} else {
    # Output to stdout as UTF-8 text
    $PlainText = [System.Text.Encoding]::UTF8.GetString($PlainBytes)
    Write-Host $PlainText
}
