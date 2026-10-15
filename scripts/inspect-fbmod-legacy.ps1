param(
    [Parameter(Mandatory = $true)]
    [string]$ModPath,

    [Parameter(Mandatory = $true)]
    [string]$FrostyInstall,

    [string]$OriginalMembersDirectory,

    [switch]$ShowExpandedHeader
)

# Read-only inspection through the Frosty assemblies shipped with the install.
# Does not export, modify, or apply resources. The profile is set in-process
# because FrostyModReader validates the profile against ProfilesLibrary.
$ErrorActionPreference = 'Stop'
$ModPath = (Resolve-Path -LiteralPath $ModPath).Path
$FrostyInstall = (Resolve-Path -LiteralPath $FrostyInstall).Path

foreach ($dll in 'FrostySdk.dll', 'FrostyHash.dll', 'FrostyCore.dll') {
    $dllPath = Join-Path $FrostyInstall $dll
    if (-not (Test-Path -LiteralPath $dllPath -PathType Leaf)) {
        throw "Required Frosty assembly not found: $dllPath"
    }
}

$sdk = [System.Reflection.Assembly]::LoadFrom((Join-Path $FrostyInstall 'FrostySdk.dll'))
[void][System.Reflection.Assembly]::LoadFrom((Join-Path $FrostyInstall 'FrostyHash.dll'))
$core = [System.Reflection.Assembly]::LoadFrom((Join-Path $FrostyInstall 'FrostyCore.dll'))

# FIFA 17's Frosty profile name in this FBMOD format is FIFA17.
$profilesType = $sdk.GetType('FrostySdk.ProfilesLibrary', $true)
$profileType = $sdk.GetType('FrostySdk.Profile', $true)
$profile = [System.Runtime.Serialization.FormatterServices]::GetUninitializedObject($profileType)
$profileType.GetField('Name', [System.Reflection.BindingFlags]'Public,NonPublic,Instance').SetValue($profile, 'FIFA17')
$profilesType.GetField('effectiveProfile', [System.Reflection.BindingFlags]'NonPublic,Static').SetValue($null, $profile)

$modType = $core.GetType('Frosty.Core.Mod.FrostyMod', $true)
$constructor = $modType.GetConstructor([type[]]@([string]))
$mod = $constructor.Invoke(@($ModPath))
if (-not $mod.NewFormat) {
    throw 'The Frosty reader did not accept this file as a supported FIFA17 FBMOD.'
}

$header = [System.IO.File]::OpenRead($ModPath)
try {
    $reader = [System.IO.BinaryReader]::new($header)
    [void]$reader.ReadBytes(8) # magic
    $formatVersion = $reader.ReadUInt32()
    $dataOffset = $reader.ReadInt64()
    $dataCount = $reader.ReadInt32()
    $profileNameLength = $reader.ReadByte()
    $profileName = [System.Text.Encoding]::UTF8.GetString($reader.ReadBytes($profileNameLength))
} finally {
    $header.Dispose()
}

"FBMOD: $ModPath"
"FormatVersion: $formatVersion; Profile: $profileName; DataOffset: $dataOffset; DataCount: $dataCount"
"Title: $($mod.ModDetails.Title); Author: $($mod.ModDetails.Author); Version: $($mod.ModDetails.Version)"
''
'Resources:'

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
[UnmanagedFunctionPointer(CallingConvention.Cdecl)] public delegate UIntPtr FbmodZstdDecompress(byte[] dst, UIntPtr capacity, byte[] src, UIntPtr srcSize);
[UnmanagedFunctionPointer(CallingConvention.Cdecl)] public delegate uint FbmodZstdIsError(UIntPtr code);
[UnmanagedFunctionPointer(CallingConvention.Cdecl)] public delegate IntPtr FbmodZstdGetErrorName(UIntPtr code);
'@

function Find-ByteSequence([byte[]]$Haystack, [byte[]]$Needle) {
    for ($i = 0; $i -le $Haystack.Length - $Needle.Length; $i++) {
        if ($Haystack[$i] -ne $Needle[0]) { continue }
        $match = $true
        for ($j = 1; $j -lt $Needle.Length; $j++) {
            if ($Haystack[$i + $j] -ne $Needle[$j]) { $match = $false; break }
        }
        if ($match) { return $i }
    }
    return -1
}

function Read-BigEndianUInt32([System.IO.BinaryReader]$Reader) {
    $bytes = $Reader.ReadBytes(4)
    if ($bytes.Length -ne 4) { throw 'Truncated BIG table field.' }
    [Array]::Reverse($bytes)
    [BitConverter]::ToUInt32($bytes, 0)
}

function Read-BigNullString([System.IO.BinaryReader]$Reader) {
    $bytes = [System.Collections.Generic.List[byte]]::new()
    while ($Reader.BaseStream.Position -lt $Reader.BaseStream.Length) {
        $value = $Reader.ReadByte()
        if ($value -eq 0) { return [Text.Encoding]::ASCII.GetString($bytes.ToArray()) }
        $bytes.Add($value)
    }
    throw 'Unterminated BIG table string.'
}

function Show-BigFileEntries([byte[]]$Bytes) {
    # Mirrors the installed LegacyBigFilePlugin reader: little-endian magic/
    # file length, then big-endian entry count/header fields and table records.
    $memory = [IO.MemoryStream]::new($Bytes, $false)
    $reader = [IO.BinaryReader]::new($memory)
    try {
        $magic = [Text.Encoding]::ASCII.GetString($reader.ReadBytes(4))
        $declaredLength = $reader.ReadUInt32()
        $count = Read-BigEndianUInt32 $reader
        $headerField = Read-BigEndianUInt32 $reader
        "BIG reader fields: magic=$magic; declaredLength=$declaredLength; entryRecords=$count; field12=$headerField; actualLength=$($Bytes.Length)"
        $kind = 'DAT'
        for ($index = 0; $index -lt $count; $index++) {
            $offset = Read-BigEndianUInt32 $reader
            $size = Read-BigEndianUInt32 $reader
            $name = Read-BigNullString $reader
            if ($size -eq 0) {
                if ($name -eq 'sg2') { $kind = 'APT' }
                elseif ($name -eq 'sg1') { $kind = 'DDS' }
                "BIG record[$index]: type marker '$name'; offsetField=$offset; size=0; subsequentType=$kind"
                continue
            }
            $leading = if ($offset -lt $Bytes.Length) {
                $n = [Math]::Min(16, [Math]::Min([long]$size, $Bytes.Length - [long]$offset))
                [Convert]::ToHexString($Bytes[[int]$offset..([int]($offset + $n - 1))])
            } else { '<offset outside file>' }
            "BIG record[$index]: type=$kind; name='$name'; offset=$offset; size=$size; leadingBytes=$leading"
        }
    } finally {
        $reader.Dispose()
    }
}

foreach ($resource in $mod.Resources) {
    $data = $mod.GetResourceData($resource)
    $payloadLength = if ($null -eq $data) { 0 } else { $data.Length }
    $payloadHash = if ($payloadLength -gt 0) {
        [Convert]::ToHexString([System.Security.Cryptography.SHA1]::HashData($data)).ToLowerInvariant()
    } else { '' }

    [pscustomobject]@{
        Type = $resource.Type
        Name = $resource.Name
        UserData = $resource.UserData
        ResourceIndex = $resource.ResourceIndex
        PayloadBytes = $payloadLength
        PayloadSha1 = $payloadHash
        Handler = $resource.Handler
    } | Format-List

    if ($null -ne $data -and $resource.UserData -like 'legacy;data/*' -and $payloadLength -ge 8) {
        $expandedSize = ([uint32]$data[0] -shl 24) -bor ([uint32]$data[1] -shl 16) -bor
            ([uint32]$data[2] -shl 8) -bor [uint32]$data[3]
        $compressedBody = [byte[]]::new($payloadLength - 8)
        [Array]::Copy($data, 8, $compressedBody, 0, $compressedBody.Length)
        $zstdPath = Join-Path $FrostyInstall 'ThirdParty\libzstd.dll'
        if (Test-Path -LiteralPath $zstdPath -PathType Leaf) {
            $native = [System.Runtime.InteropServices.NativeLibrary]::Load($zstdPath)
            try {
                $decompressPtr = [System.Runtime.InteropServices.NativeLibrary]::GetExport($native, 'ZSTD_decompress')
                $isErrorPtr = [System.Runtime.InteropServices.NativeLibrary]::GetExport($native, 'ZSTD_isError')
                $errorNamePtr = [System.Runtime.InteropServices.NativeLibrary]::GetExport($native, 'ZSTD_getErrorName')
                $decompress = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
                    $decompressPtr, [type][FbmodZstdDecompress])
                $isError = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
                    $isErrorPtr, [type][FbmodZstdIsError])
                $errorName = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
                    $errorNamePtr, [type][FbmodZstdGetErrorName])
                $expanded = [byte[]]::new([int]$expandedSize)
                $result = $decompress.Invoke($expanded, [UIntPtr]::new([uint64]$expanded.Length),
                    $compressedBody, [UIntPtr]::new([uint64]$compressedBody.Length))
                if ($isError.Invoke($result) -ne 0) {
                    $message = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($errorName.Invoke($result))
                    throw "Zstandard decode failed: $message"
                }
                if ($result.ToUInt64() -ne $expandedSize) {
                    throw "Expanded size mismatch: expected $expandedSize, got $($result.ToUInt64())"
                }
                if ([Text.Encoding]::ASCII.GetString($expanded, 0, [Math]::Min(4, $expanded.Length)) -eq 'BIGF') {
                    "Expanded Legacy BIGF: $($expanded.Length) bytes"
                    if ($ShowExpandedHeader) {
                        $headerLength = [Math]::Min(128, $expanded.Length)
                        "Expanded BIG header (first $headerLength bytes): $([Convert]::ToHexString($expanded[0..($headerLength - 1)]))"
                        Show-BigFileEntries $expanded
                    }
                    if ($OriginalMembersDirectory) {
                        foreach ($member in Get-ChildItem -LiteralPath $OriginalMembersDirectory -File |
                            Where-Object Extension -in '.DAT', '.APT') {
                            $original = [IO.File]::ReadAllBytes($member.FullName)
                            $offset = Find-ByteSequence $expanded $original
                            "Member $($member.Name): exact bytes at offset $offset (size $($original.Length))"
                        }
                    }
                } else {
                    'Expanded payload does not begin with BIGF; not interpreted as a BIG container.'
                }
            } finally {
                [System.Runtime.InteropServices.NativeLibrary]::Free($native)
            }
        }
    }

    if ($null -eq $data -or $resource.UserData -notlike 'legacy;Collector*') {
        continue
    }

    $stream = [System.IO.MemoryStream]::new($data)
    $binary = [System.IO.BinaryReader]::new($stream)
    try {
        while ($stream.Position -lt $stream.Length) {
            $nameHash = $binary.ReadInt32()
            $nameBytes = [System.Collections.Generic.List[byte]]::new()
            while ($stream.Position -lt $stream.Length) {
                $byte = $binary.ReadByte()
                if ($byte -eq 0) { break }
                $nameBytes.Add($byte)
            }
            $legacyName = [System.Text.Encoding]::UTF8.GetString($nameBytes.ToArray())
            $chunkId = [Guid]::new($binary.ReadBytes(16))
            $offset = $binary.ReadInt64()
            $compressedOffset = $binary.ReadInt64()
            $compressedSize = $binary.ReadInt64()
            $size = $binary.ReadInt64()
            $expectedHash = [Frosty.Hash.Fnv1]::HashString($legacyName)

            [pscustomobject]@{
                CollectorEntry = $legacyName
                Hash = ('0x{0:X8}' -f [uint32]$nameHash)
                HashMatchesFrosty = ($nameHash -eq $expectedHash)
                ChunkId = $chunkId
                Offset = $offset
                CompressedOffset = $compressedOffset
                CompressedSize = $compressedSize
                UncompressedSize = $size
            } | Format-List
        }
    } finally {
        $binary.Dispose()
        $stream.Dispose()
    }
}
