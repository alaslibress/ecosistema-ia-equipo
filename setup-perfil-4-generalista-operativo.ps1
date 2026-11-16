#Requires -Version 5.1
<#
.SYNOPSIS
    Aprovisionamiento del PERFIL 4: Generalista operativo - Sistemas, redes y auditoría (Windows 11 ARM64 / Surface). Persona: Javi.
.DESCRIPTION
    Instala el Nivel 0 (claude-code-router, RTK, Caveman bloqueado en Lite, Context Mode, /empezar),
    las Document Skills oficiales de Anthropic (docx, pdf, xlsx), los paquetes Python python-docx, pypdf,
    openpyxl y pillow, agent-browser y la skill interna asistente-operativo-it.
    Prohibido en este perfil: hola-ai, ponytail, Agent Skills (Addy Osmani), graphify, grill-me, find-skills.
    Idempotente: se puede relanzar para actualizar.
.PARAMETER SkipWinget
    Omite la instalación/actualización de paquetes del sistema con winget.
.EXAMPLE
    .\setup-perfil-4-generalista-operativo.ps1
#>
[CmdletBinding()]
param(
    [switch]$SkipWinget
)

$PerfilId       = 4
$PerfilNombre   = 'Generalista operativo - Sistemas, redes y auditoría'
$PerfilPersona  = 'Javi'
$EmpezarSource  = 'empezar-perfil-4'
$CavemanLock    = $true
$ForbiddenSkills = @(
    'backlog', 'story', 'pair', 'ponytail*', 'graphify*', 'grill-me*', 'find-skill*',
    'using-agent-skills', 'spec-driven-development', 'interview-me', 'planning-and-task-breakdown',
    'incremental-implementation', 'test-driven-development', 'source-driven-development',
    'doubt-driven-development', 'code-review-and-quality', 'code-simplification',
    'security-and-hardening', 'shipping-and-launch'
)
$ForbiddenPlugins = @('ponytail@ponytail')
$NextSteps = @(
    'Abre una terminal nueva y escribe: ccr code',
    'Escribe /empezar y sigue la guía de 3 minutos.',
    'Para auditar plantillas, pon primero todos los archivos en una sola carpeta.',
    'Guía de bolsillo: guias-equipo\GUIA-PERFIL-4-GENERALISTA-OPERATIVO.md'
)

# =============================================================================
# CONFIGURACIÓN GENERAL
# =============================================================================
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$PSNativeCommandUseErrorActionPreference = $false
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$ModelHaiku  = 'claude-haiku-5-5'
$ModelSonnet = 'claude-sonnet-5-5'
$ModelOpus   = 'claude-opus-5-5'

# =============================================================================
# ELEVACIÓN A ADMINISTRADOR
# =============================================================================
function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    Write-Host 'Se necesitan privilegios de Administrador. Relanzando el script elevado...' -ForegroundColor Yellow
    $hostExe = 'powershell'
    if (Get-Command pwsh -ErrorAction SilentlyContinue) { $hostExe = 'pwsh' }
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $PSCommandPath))
    foreach ($key in $PSBoundParameters.Keys) {
        $val = $PSBoundParameters[$key]
        if ($val -is [System.Management.Automation.SwitchParameter]) {
            if ($val.IsPresent) { $argList += "-$key" }
        }
        else {
            $argList += "-$key"
            $argList += ('"{0}"' -f $val)
        }
    }
    Start-Process -FilePath $hostExe -Verb RunAs -ArgumentList $argList
    exit
}

try {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}
catch {
    Write-Warning "No se pudo fijar ExecutionPolicy (posible directiva de grupo): $($_.Exception.Message)"
}

# =============================================================================
# RUTAS Y ESTADO
# =============================================================================
$ClaudeHome      = Join-Path $env:USERPROFILE '.claude'
$SkillsDir       = Join-Path $ClaudeHome 'skills'
$ToolsDir        = Join-Path $ClaudeHome 'tools'
$QuarantineDir   = Join-Path $ClaudeHome ('skills-cuarentena\' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$CustomSkillsDir = Join-Path $PSScriptRoot 'custom-skills'
$TempRoot        = Join-Path $env:TEMP ('ia-setup-' + [guid]::NewGuid().ToString('N'))
$LogFile         = Join-Path $env:TEMP ('setup-perfil-{0}-{1}.log' -f $PerfilId, (Get-Date -Format 'yyyyMMdd-HHmmss'))

foreach ($dir in @($ClaudeHome, $SkillsDir, $ToolsDir, $TempRoot)) {
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

try { Start-Transcript -Path $LogFile -Force | Out-Null } catch { }

$Script:Results   = New-Object System.Collections.Generic.List[object]
$Script:RepoCache = @{}
$IsArm64 = ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') -or ($env:PROCESSOR_ARCHITEW6432 -eq 'ARM64')

# =============================================================================
# UTILIDADES
# =============================================================================
function Write-Section {
    param([string]$Title)
    Write-Host ''
    Write-Host ('=' * 78) -ForegroundColor DarkCyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host ('=' * 78) -ForegroundColor DarkCyan
}

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    [System.IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding($false)))
}

function Invoke-Step {
    param([string]$StepName, [scriptblock]$StepAction)
    Write-Host ''
    Write-Host ">> $StepName" -ForegroundColor Cyan
    try {
        $stepOut = & $StepAction
        $detail = (($stepOut | Out-String).Trim() -replace '\s+', ' ')
        if ($detail.Length -gt 140) { $detail = $detail.Substring(0, 140) + '...' }
        $estado = 'OK'
        if ($detail -like 'OMITIDO*') { $estado = 'OMITIDO' }
        $Script:Results.Add([pscustomobject]@{ Paso = $StepName; Estado = $estado; Detalle = $detail })
        if ($estado -eq 'OK') { Write-Host "   OK  $detail" -ForegroundColor Green }
        else { Write-Host "   $detail" -ForegroundColor Yellow }
    }
    catch {
        $Script:Results.Add([pscustomobject]@{ Paso = $StepName; Estado = 'FALLO'; Detalle = $_.Exception.Message })
        Write-Host "   FALLO: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Invoke-Native {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$Arguments = @(),
        [int[]]$OkCodes = @(0)
    )
    $ErrorActionPreference = 'Continue'
    & $FilePath @Arguments | Out-Host
    $code = $LASTEXITCODE
    if ($OkCodes -notcontains $code) {
        throw ('Comando fallido (código {0}): {1} {2}' -f $code, $FilePath, ($Arguments -join ' '))
    }
}

function Get-Cli {
    param([string]$Name, [switch]$ExcludeWindowsApps)
    $cmd = Get-Command -Name @("$Name.exe", "$Name.cmd") -CommandType Application -ErrorAction SilentlyContinue |
        Where-Object { (-not $ExcludeWindowsApps) -or ($_.Source -notlike '*\WindowsApps\*') } |
        Select-Object -First 1
    if (-not $cmd) { throw "No se encuentra '$Name' en el PATH." }
    return $cmd.Source
}

function Test-Cli {
    param([string]$Name)
    try { $null = Get-Cli $Name; return $true } catch { return $false }
}

function Update-SessionPath {
    $entries = New-Object System.Collections.Generic.List[string]
    foreach ($scope in @('Machine', 'User')) {
        $value = [Environment]::GetEnvironmentVariable('Path', $scope)
        if ($value) { foreach ($p in ($value -split ';')) { $entries.Add([Environment]::ExpandEnvironmentVariables($p)) } }
    }
    $extra = @(
        (Join-Path $env:USERPROFILE '.cargo\bin'),
        (Join-Path $env:USERPROFILE '.local\bin'),
        (Join-Path $env:APPDATA 'npm'),
        (Join-Path $env:ProgramFiles 'Git\cmd'),
        (Join-Path $env:ProgramFiles 'nodejs'),
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links')
    )
    foreach ($root in @((Join-Path $env:LOCALAPPDATA 'Programs\Python'), $env:ProgramFiles, (Join-Path $env:APPDATA 'Python'))) {
        if (Test-Path $root) {
            Get-ChildItem -Path $root -Directory -Filter 'Python3*' -ErrorAction SilentlyContinue | ForEach-Object {
                $extra += $_.FullName
                $extra += (Join-Path $_.FullName 'Scripts')
            }
        }
    }
    foreach ($p in $extra) { $entries.Add($p) }
    $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $final = New-Object System.Collections.Generic.List[string]
    foreach ($p in $entries) {
        $clean = $p.Trim().TrimEnd('\')
        if ($clean -and (Test-Path $clean) -and $seen.Add($clean)) { $final.Add($clean) }
    }
    $env:Path = ($final -join ';')
}

function Install-WingetPackage {
    param([string]$Id)
    $ErrorActionPreference = 'Continue'
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'winget no está disponible. Instala o actualiza "Instalador de aplicación" desde Microsoft Store.'
    }
    $common = @('--id', $Id, '--exact', '--silent', '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity')
    $okCodes = @(0, -1978335189, -1978335135)
    & winget list --id $Id --exact --accept-source-agreements --disable-interactivity | Out-Null
    if ($LASTEXITCODE -eq 0) {
        & winget upgrade @common | Out-Host
        return "$Id ya instalado (actualizado si había versión nueva)"
    }
    $archs = @('x64')
    if ($IsArm64) { $archs = @('arm64', 'x64') }
    foreach ($arch in $archs) {
        & winget install @common --architecture $arch | Out-Host
        if ($okCodes -contains $LASTEXITCODE) { return "$Id instalado ($arch)" }
        Write-Warning "winget no pudo instalar $Id para $arch (código $LASTEXITCODE). Probando alternativa..."
    }
    & winget install @common | Out-Host
    if ($okCodes -contains $LASTEXITCODE) { return "$Id instalado (arquitectura por defecto)" }
    throw "winget no pudo instalar $Id (código $LASTEXITCODE)"
}

function Install-NpmGlobal {
    param([string]$Package)
    Invoke-Native -FilePath (Get-Cli npm) -Arguments @('install', '-g', "$Package@latest", '--no-fund', '--no-audit')
    Update-SessionPath
    return "$Package@latest instalado/actualizado"
}

function Get-PythonCommand {
    $ErrorActionPreference = 'Continue'
    if (Get-Command py -ErrorAction SilentlyContinue) {
        & py -3.12 -c "import sys" 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { return , @('py', '-3.12') }
    }
    foreach ($c in @('python', 'python3')) {
        try { return , @((Get-Cli $c -ExcludeWindowsApps)) } catch { }
    }
    throw 'Python 3.12 no encontrado en el PATH.'
}

function Invoke-Python {
    param([string[]]$Arguments)
    $py = Get-PythonCommand
    $prefix = @()
    if ($py.Count -gt 1) { $prefix = $py[1..($py.Count - 1)] }
    Invoke-Native -FilePath $py[0] -Arguments ($prefix + $Arguments)
}

function Install-PipPackages {
    param([string[]]$Packages)
    Invoke-Python -Arguments (@('-m', 'pip', 'install', '--upgrade', '--quiet', '--disable-pip-version-check') + $Packages)
    Update-SessionPath
    return ('pip: ' + ($Packages -join ', ') + ' instalados/actualizados')
}

function Get-RepoClone {
    param([string]$Repo)
    if ($Script:RepoCache.ContainsKey($Repo)) { return $Script:RepoCache[$Repo] }
    $dest = Join-Path $TempRoot ($Repo -replace '[/\\]', '__')
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    Invoke-Native -FilePath (Get-Cli git) -Arguments @('clone', '--depth', '1', '--quiet', "https://github.com/$Repo.git", $dest)
    $Script:RepoCache[$Repo] = $dest
    return $dest
}

function Find-SkillDirectory {
    param([string]$Root, [string[]]$Names, [switch]$AllowRoot)
    $all = @(Get-ChildItem -Path $Root -Recurse -File -Filter 'SKILL.md' -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\(node_modules|\.git)\\' })
    foreach ($n in $Names) {
        $hit = $all | Where-Object { $_.Directory.Name -ieq $n } | Sort-Object { $_.FullName.Length } | Select-Object -First 1
        if ($hit) { return $hit.Directory.FullName }
    }
    foreach ($n in $Names) {
        $pattern = '^name:\s*["'']?' + [regex]::Escape($n) + '["'']?\s*$'
        foreach ($f in $all) {
            $head = Get-Content -Path $f.FullName -TotalCount 15 -Encoding UTF8
            if ($head -match $pattern) { return $f.Directory.FullName }
        }
    }
    if ($AllowRoot -and (Test-Path (Join-Path $Root 'SKILL.md'))) { return $Root }
    return $null
}

function Copy-SkillFolder {
    param([string]$Source, [string]$Name)
    $dest = Join-Path $SkillsDir $Name
    $accion = 'instalada'
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force; $accion = 'actualizada' }
    Copy-Item -Path $Source -Destination $dest -Recurse -Force
    Get-ChildItem -Path $dest -Recurse -Force -Directory -Filter '.git' -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
    Get-ChildItem -Path $dest -Recurse -Force -File -Filter '.git' -ErrorAction SilentlyContinue | Remove-Item -Force
    return $accion
}

function Install-SkillFromRepo {
    param([string]$Repo, [string]$SkillName, [string[]]$Candidates, [switch]$AllowRoot)
    if (-not $Candidates) { $Candidates = @($SkillName) }
    $root = Get-RepoClone $Repo
    $src = Find-SkillDirectory -Root $root -Names $Candidates -AllowRoot:$AllowRoot
    if (-not $src) { throw "No se encontró la skill '$SkillName' dentro de $Repo" }
    $accion = Copy-SkillFolder -Source $src -Name $SkillName
    return "$SkillName $accion desde $Repo"
}

function Install-SkillGroupFromRepo {
    param([string]$Repo, [string]$Pattern)
    $root = Get-RepoClone $Repo
    $dirs = Get-ChildItem -Path $root -Recurse -File -Filter 'SKILL.md' -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\(node_modules|\.git)\\' -and $_.Directory.Name -like $Pattern } |
        Sort-Object { $_.FullName.Length } |
        ForEach-Object { $_.Directory } |
        Group-Object Name | ForEach-Object { $_.Group[0] }
    if (-not $dirs) { throw "No hay skills '$Pattern' en $Repo" }
    $done = @()
    foreach ($d in $dirs) {
        $null = Copy-SkillFolder -Source $d.FullName -Name $d.Name
        $done += $d.Name
    }
    return ('instaladas: ' + ($done -join ', '))
}

function Copy-CustomSkill {
    param([string]$Source, [string]$SkillName)
    $src = Join-Path $CustomSkillsDir $Source
    if (-not (Test-Path (Join-Path $src 'SKILL.md'))) {
        throw "Falta $src\SKILL.md. Copia la carpeta custom-skills junto al script."
    }
    $accion = Copy-SkillFolder -Source $src -Name $SkillName
    return "$SkillName $accion desde custom-skills\$Source"
}

function Remove-ForbiddenSkills {
    param([string[]]$Patterns, [string[]]$Plugins = @())
    $ErrorActionPreference = 'Continue'
    $moved = @()
    if (Test-Path $SkillsDir) {
        foreach ($p in $Patterns) {
            Get-ChildItem -Path $SkillsDir -Directory -Filter $p -ErrorAction SilentlyContinue | ForEach-Object {
                if (-not (Test-Path $QuarantineDir)) { New-Item -ItemType Directory -Path $QuarantineDir -Force | Out-Null }
                Move-Item -Path $_.FullName -Destination (Join-Path $QuarantineDir $_.Name) -Force
                $moved += $_.Name
            }
        }
    }
    if ($Plugins.Count -gt 0 -and (Test-Cli claude)) {
        $claudeCli = Get-Cli claude
        foreach ($pl in $Plugins) { & $claudeCli plugin uninstall $pl 2>&1 | Out-Null }
    }
    if ($moved.Count -gt 0) { return ('movidas a cuarentena (' + $QuarantineDir + '): ' + ($moved -join ', ')) }
    return 'ninguna skill prohibida encontrada'
}

function Set-ClaudeEnvSetting {
    param([string]$Key, [string]$Value)
    $path = Join-Path $ClaudeHome 'settings.json'
    $obj = $null
    if (Test-Path $path) {
        $raw = Get-Content -Path $path -Raw -Encoding UTF8
        if ($raw -and $raw.Trim()) {
            try { $obj = $raw | ConvertFrom-Json } catch { throw "settings.json no es JSON válido; no se modifica ($path)" }
        }
        Copy-Item -Path $path -Destination "$path.bak" -Force
    }
    if (-not $obj) { $obj = New-Object psobject }
    if (-not ($obj.PSObject.Properties.Name -contains 'env')) {
        $obj | Add-Member -NotePropertyName 'env' -NotePropertyValue (New-Object psobject)
    }
    if ($obj.env.PSObject.Properties.Name -contains $Key) { $obj.env.$Key = $Value }
    else { $obj.env | Add-Member -NotePropertyName $Key -NotePropertyValue $Value }
    Write-Utf8NoBom -Path $path -Content ($obj | ConvertTo-Json -Depth 30)
}

function Set-CavemanLite {
    param([switch]$Lock)
    [Environment]::SetEnvironmentVariable('CAVEMAN_DEFAULT_MODE', 'lite', 'User')
    if ($Lock) { [Environment]::SetEnvironmentVariable('CAVEMAN_DEFAULT_MODE', 'lite', 'Machine') }
    $env:CAVEMAN_DEFAULT_MODE = 'lite'
    foreach ($dir in @((Join-Path $env:USERPROFILE '.config\caveman'), (Join-Path $env:APPDATA 'caveman'))) {
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Write-Utf8NoBom -Path (Join-Path $dir 'config.json') -Content '{ "defaultMode": "lite" }'
    }
    Set-ClaudeEnvSetting -Key 'CAVEMAN_DEFAULT_MODE' -Value 'lite'
    if ($Lock) { return 'Caveman bloqueado en modo Lite (usuario + máquina + settings.json)' }
    return 'Caveman en modo Lite (variable de usuario + config + settings.json)'
}

function Install-ContextMode {
    $ErrorActionPreference = 'Continue'
    if (Test-Cli claude) {
        $claudeCli = Get-Cli claude
        & $claudeCli plugin marketplace add mksglu/context-mode 2>&1 | Out-Host
        & $claudeCli plugin install context-mode@context-mode 2>&1 | Out-Host
        if ($LASTEXITCODE -eq 0) { return 'plugin context-mode instalado/actualizado (hooks + skill)' }
        & $claudeCli plugin update context-mode@context-mode 2>&1 | Out-Host
        if ($LASTEXITCODE -eq 0) { return 'plugin context-mode actualizado' }
        $mcpArgs = @('mcp', 'add', '--scope', 'user', 'context-mode', '--', 'npx', '-y', 'context-mode')
        & $claudeCli @mcpArgs 2>&1 | Out-Host
        if ($LASTEXITCODE -eq 0) { return 'context-mode registrado como servidor MCP de usuario (sin hooks)' }
    }
    return (Install-SkillFromRepo -Repo 'mksglu/context-mode' -SkillName 'context-mode' -Candidates @('context-mode', 'ctx') -AllowRoot)
}

function Install-Rtk {
    if (-not (Test-Cli rtk)) {
        try { $null = Install-WingetPackage -Id 'rtk-ai.rtk' } catch { Write-Warning $_.Exception.Message }
        Update-SessionPath
    }
    if (-not (Test-Cli rtk)) {
        Write-Host '   rtk no disponible por winget; compilando con cargo (puede tardar varios minutos)...' -ForegroundColor Yellow
        Invoke-Native -FilePath (Get-Cli cargo) -Arguments @('install', '--git', 'https://github.com/rtk-ai/rtk', '--locked')
        Update-SessionPath
    }
    if (-not (Test-Cli rtk)) { throw 'rtk no quedó disponible en el PATH.' }
    return ('rtk disponible en ' + (Get-Cli rtk))
}

function Install-Level0 {
    Write-Host ''
    Write-Host "Hola $PerfilPersona, empieza la instalación de tu perfil (Perfil $PerfilId - $PerfilNombre)." -ForegroundColor Cyan
    Write-Section "NIVEL 0 - Infraestructura global (Perfil $PerfilId - $PerfilNombre)"
    if ($IsArm64) { Write-Host 'Arquitectura detectada: ARM64 (se prioriza --architecture arm64)' -ForegroundColor Green }
    else { Write-Host "Arquitectura detectada: $($env:PROCESSOR_ARCHITECTURE) (se usará x64)" -ForegroundColor Yellow }

    if (-not $SkipWinget) {
        foreach ($pkg in @('Git.Git', 'OpenJS.NodeJS.LTS', 'Python.Python.3.12', 'Rustlang.Rustup', 'BurntSushi.ripgrep.MSVC')) {
            $wingetId = $pkg
            Invoke-Step "winget $wingetId" { Install-WingetPackage -Id $wingetId }
        }
    }
    Update-SessionPath

    Invoke-Step 'Verificar git, node, npm, npx y python en la sesión' {
        $found = @()
        foreach ($t in @('git', 'node', 'npm', 'npx')) { $found += ($t + '=' + (Get-Cli $t)) }
        $found += ('python=' + ((Get-PythonCommand) -join ' '))
        $found -join ' | '
    }

    Invoke-Step 'Toolchain Rust estable (rustup)' {
        $ErrorActionPreference = 'Continue'
        $rustup = Get-Cli rustup
        $tc = (& $rustup toolchain list 2>&1 | Out-String)
        if ((-not $tc.Trim()) -or ($tc -match 'no installed toolchains')) {
            Invoke-Native -FilePath $rustup -Arguments @('default', 'stable')
        }
        Update-SessionPath
        'rustup con toolchain estable'
    }

    Invoke-Step 'Claude Code CLI' {
        if (Test-Cli claude) { 'claude ya disponible: ' + (Get-Cli claude) }
        else { Install-NpmGlobal '@anthropic-ai/claude-code' }
    }
    Invoke-Step 'claude-code-router (@musistudio/claude-code-router)' { Install-NpmGlobal '@musistudio/claude-code-router' }
    Invoke-Step 'RTK (Rust Token Killer)' { Install-Rtk }
    Invoke-Step 'RTK hook global (rtk init -g)' {
        & (Get-Cli rtk) init -g
        if ($LASTEXITCODE -ne 0) { throw "rtk init -g terminó con código $LASTEXITCODE" }
        'hook global de rtk configurado'
    }
    Invoke-Step 'Skill global caveman' { Install-SkillFromRepo -Repo 'JuliusBrussee/caveman' -SkillName 'caveman' -AllowRoot }
    Invoke-Step 'Caveman en modo Lite' { Set-CavemanLite -Lock:$CavemanLock }
    Invoke-Step 'Context Mode' { Install-ContextMode }
    Invoke-Step 'Skill onboarding /empezar' { Copy-CustomSkill -Source $EmpezarSource -SkillName 'empezar' }
}

function Read-ApiKey {
    $prompt = 'Introduce tu API Key de Anthropic (Enter vacío = mantener la actual)'
    if ($PSVersionTable.PSVersion -ge [version]'7.1') {
        return [string](Read-Host -Prompt $prompt -MaskInput)
    }
    $secure = Read-Host -Prompt $prompt -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

function Write-CcrConfig {
    $dir = Join-Path $env:USERPROFILE '.claude-code-router'
    $file = Join-Path $dir 'config.json'
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $existingKey = ''
    if (Test-Path $file) {
        try {
            $old = Get-Content -Path $file -Raw -Encoding UTF8 | ConvertFrom-Json
            $prov = @($old.Providers) | Where-Object { $_.name -eq 'anthropic' } | Select-Object -First 1
            if ($prov) { $existingKey = [string]$prov.api_key }
        }
        catch { Write-Warning 'El config.json existente no se pudo leer; se regenerará.' }
        Copy-Item -Path $file -Destination ($file + '.bak-' + (Get-Date -Format 'yyyyMMdd-HHmmss')) -Force
    }
    $key = (Read-ApiKey).Trim()
    if (-not $key) {
        if ($existingKey) { $key = $existingKey; Write-Host '   Se mantiene la API Key existente.' -ForegroundColor Yellow }
        else { throw 'No se introdujo ninguna API Key. Vuelve a ejecutar el script para configurarla.' }
    }
    if ($key -notlike 'sk-ant-*') { Write-Warning 'La clave no empieza por "sk-ant-". Revisa que sea una API Key de Anthropic.' }
    $config = [ordered]@{
        LOG            = $false
        HOST           = '127.0.0.1'
        PORT           = 3456
        API_TIMEOUT_MS = 600000
        Providers      = @(
            [ordered]@{
                name         = 'anthropic'
                api_base_url = 'https://api.anthropic.com/v1/messages'
                api_key      = $key
                models       = @($ModelHaiku, $ModelSonnet, $ModelOpus)
                transformer  = [ordered]@{ use = @('Anthropic') }
            }
        )
        Router         = [ordered]@{
            default              = "anthropic,$ModelSonnet"
            background           = "anthropic,$ModelHaiku"
            think                = "anthropic,$ModelOpus"
            longContext          = "anthropic,$ModelSonnet"
            longContextThreshold = 60000
        }
    }
    Write-Utf8NoBom -Path $file -Content ($config | ConvertTo-Json -Depth 10)
    $sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    & icacls $file /inheritance:r /grant:r "*${sid}:(F)" /grant:r '*S-1-5-18:(F)' | Out-Null
    return "config.json generado en $file (background=Haiku, default=Sonnet, think=Opus; acceso solo para tu usuario)"
}

function Show-BurnerWarning {
    Write-Host ''
    Write-Host ('!' * 78) -ForegroundColor Red
    Write-Host '  AVISO AGENT REACH: usa SOLO cuentas secundarias (burners) en X, Reddit,' -ForegroundColor Red
    Write-Host '  Instagram, LinkedIn y YouTube. NUNCA cuentas corporativas ni personales.' -ForegroundColor Red
    Write-Host '  La extracción automatizada puede provocar bloqueos o baneos de la cuenta.' -ForegroundColor Red
    Write-Host ('!' * 78) -ForegroundColor Red
    Write-Host ''
}

function Complete-Setup {
    Write-Section 'Configuración del enrutador de modelos'
    Invoke-Step 'claude-code-router: config.json y API Key' { Write-CcrConfig }

    Write-Section "RESUMEN - Perfil $PerfilId ($PerfilNombre)"
    $Script:Results | Format-Table -AutoSize -Wrap | Out-Host
    $fallos = @($Script:Results | Where-Object { $_.Estado -eq 'FALLO' }).Count
    if ($fallos -gt 0) {
        Write-Host "$fallos paso(s) fallaron. Puedes relanzar el script: es idempotente." -ForegroundColor Yellow
    }
    else {
        Write-Host 'Todo instalado correctamente.' -ForegroundColor Green
    }
    Write-Host ''
    Write-Host 'Siguientes pasos:' -ForegroundColor Cyan
    foreach ($s in $NextSteps) { Write-Host "  - $s" }
    Write-Host "  - Log completo: $LogFile"

    try { Stop-Transcript | Out-Null } catch { }
    if (Test-Path $TempRoot) { Remove-Item -Path $TempRoot -Recurse -Force -ErrorAction SilentlyContinue }
    Read-Host 'Pulsa Enter para cerrar'
}

# =============================================================================
# EJECUCIÓN - PERFIL 4
# =============================================================================
Install-Level0

Write-Section 'PERFIL 4 - Documentos, sistemas, redes y auditoría'
Invoke-Step 'Limpieza de hola-ai, ponytail, Osmani y graphify' { Remove-ForbiddenSkills -Patterns $ForbiddenSkills -Plugins $ForbiddenPlugins }

Invoke-Step 'Paquetes Python: python-docx, pypdf, openpyxl, pillow' {
    Install-PipPackages -Packages @('python-docx', 'pypdf', 'openpyxl', 'pillow')
}
foreach ($docSkill in @('docx', 'pdf', 'xlsx')) {
    $ds = $docSkill
    Invoke-Step "Document Skill oficial: $ds (anthropics/skills)" {
        Install-SkillFromRepo -Repo 'anthropics/skills' -SkillName $ds
    }
}
Invoke-Step 'CLI agent-browser + navegador' {
    $msg = Install-NpmGlobal 'agent-browser'
    Invoke-Native -FilePath (Get-Cli agent-browser) -Arguments @('install')
    "$msg; navegador descargado"
}
Invoke-Step 'Skill agent-browser (vercel-labs/agent-browser)' {
    Install-SkillFromRepo -Repo 'vercel-labs/agent-browser' -SkillName 'agent-browser' -AllowRoot
}
Invoke-Step 'Skill interna asistente-operativo-it' {
    Copy-CustomSkill -Source 'asistente-operativo-it' -SkillName 'asistente-operativo-it'
}

Complete-Setup
