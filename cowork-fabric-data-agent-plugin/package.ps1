$ErrorActionPreference = "Stop"

$manifestPath = Join-Path $PSScriptRoot "manifest.json"
$toolDescriptionPath = Join-Path $PSScriptRoot "toolDescription.json"
$colorIconPath = Join-Path $PSScriptRoot "color.png"
$outlineIconPath = Join-Path $PSScriptRoot "outline.png"
$skillsDirectory = Join-Path $PSScriptRoot "skills"
$skillPath = Join-Path $skillsDirectory "luxmoto-seguros\SKILL.md"
$buildDirectory = Join-Path $PSScriptRoot "build"
$packagePath = Join-Path $buildDirectory "luxmoto-data-agent-cowork-plugin.zip"

$requiredFiles = @($manifestPath, $toolDescriptionPath, $colorIconPath, $outlineIconPath, $skillPath)
foreach ($file in $requiredFiles) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required plugin file is missing: $file"
  }
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$toolDescription = Get-Content -LiteralPath $toolDescriptionPath -Raw | ConvertFrom-Json
$expectedEndpoint = "https://api.fabric.microsoft.com/v1/mcp/workspaces/d15dc07d-3e17-457a-9346-3b3dae156262/dataagents/9400461b-ecc3-4108-b7ad-bd3152f82a00/agent"
$actualEndpoint = $manifest.agentConnectors[0].toolSource.remoteMcpServer.mcpServerUrl

if ($actualEndpoint -ne $expectedEndpoint) {
  throw "Unexpected Ontology MCP endpoint in manifest.json: $actualEndpoint"
}

if ($null -eq $toolDescription.tools -or $toolDescription.tools.Count -eq 0) {
  throw "toolDescription.json must contain a non-empty tools array."
}

$expectedToolName = "DataAgent_Data_Agent_Fabric_LuxMotoSeguros"
$actualToolName = $toolDescription.tools[0].name
if ($actualToolName -ne $expectedToolName) {
  throw "Unexpected Data Agent MCP tool name in toolDescription.json: $actualToolName"
}

$authorization = $manifest.agentConnectors[0].toolSource.remoteMcpServer.authorization
if ($authorization.type -ne "OAuthPluginVault" -or [string]::IsNullOrWhiteSpace($authorization.referenceId)) {
  throw "The Data Agent MCP connector requires OAuthPluginVault with a referenceId."
}

$skillFolder = $manifest.agentSkills[0].folder
if ($skillFolder -ne "./skills/luxmoto-seguros") {
  throw "Unexpected agentSkills folder in manifest.json: $skillFolder"
}

New-Item -ItemType Directory -Path $buildDirectory -Force | Out-Null
if (Test-Path -LiteralPath $packagePath) {
  Remove-Item -LiteralPath $packagePath -Force
}

Add-Type -AssemblyName System.IO.Compression

$entries = @(
  @{ Source = $manifestPath; Name = "manifest.json" },
  @{ Source = $toolDescriptionPath; Name = "toolDescription.json" },
  @{ Source = $colorIconPath; Name = "color.png" },
  @{ Source = $outlineIconPath; Name = "outline.png" },
  @{ Source = $skillPath; Name = "skills/luxmoto-seguros/SKILL.md" }
)

$fileStream = [System.IO.File]::Open(
  $packagePath,
  [System.IO.FileMode]::CreateNew,
  [System.IO.FileAccess]::ReadWrite,
  [System.IO.FileShare]::None
)

try {
  $archive = New-Object System.IO.Compression.ZipArchive(
    $fileStream,
    [System.IO.Compression.ZipArchiveMode]::Create,
    $false
  )

  try {
    foreach ($item in $entries) {
      $entryName = $item.Name
      if (
        [System.IO.Path]::IsPathRooted($entryName) -or
        $entryName.Contains("\") -or
        $entryName.Split("/") -contains ".."
      ) {
        throw "Unsafe ZIP entry path: $entryName"
      }

      $entry = $archive.CreateEntry(
        $entryName,
        [System.IO.Compression.CompressionLevel]::Optimal
      )
      $inputStream = [System.IO.File]::OpenRead($item.Source)
      $outputStream = $entry.Open()
      try {
        $inputStream.CopyTo($outputStream)
      } finally {
        $outputStream.Dispose()
        $inputStream.Dispose()
      }
    }
  } finally {
    $archive.Dispose()
  }
} finally {
  $fileStream.Dispose()
}

Write-Host "Created Cowork plugin package: $packagePath"
