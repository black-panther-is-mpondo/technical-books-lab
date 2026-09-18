param(
    [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$rawDir = Join-Path $RepoRoot "books\pandas\data\raw"

if (-not (Test-Path (Join-Path $RepoRoot "pyproject.toml"))) {
    Write-Warning "pyproject.toml was not found in: $RepoRoot"
    Write-Warning "Run this script from the technical-books-lab repository root, or pass -RepoRoot."
}

New-Item -ItemType Directory -Force -Path $rawDir | Out-Null

$datasets = @(
    @{
        File = "vehicles.csv.zip"
        Url  = "https://raw.githubusercontent.com/mattharrison/datasets/master/data/vehicles.csv.zip"
    },
    @{
        File = "alta-noaa-1980-2019.csv"
        Url  = "https://raw.githubusercontent.com/mattharrison/datasets/master/data/alta-noaa-1980-2019.csv"
    },
    @{
        File = "siena2018-pres.csv"
        Url  = "https://raw.githubusercontent.com/mattharrison/datasets/master/data/siena2018-pres.csv"
    },
    @{
        File = "2020-jetbrains-python-survey.csv"
        Url  = "https://raw.githubusercontent.com/mattharrison/datasets/master/data/2020-jetbrains-python-survey.csv"
    },
    @{
        File = "dirtydevil.txt"
        Url  = "https://raw.githubusercontent.com/mattharrison/datasets/master/data/dirtydevil.txt"
    },
    @{
        File = "hanksville.csv"
        Url  = "https://raw.githubusercontent.com/mattharrison/datasets/master/data/hanksville.csv"
    }
)

Write-Host ""
Write-Host "Effective Pandas offline dataset download"
Write-Host "Destination: $rawDir"
Write-Host ""

foreach ($dataset in $datasets) {
    $destination = Join-Path $rawDir $dataset.File

    if (Test-Path $destination) {
        $existing = Get-Item $destination
        if ($existing.Length -gt 0) {
            Write-Host "[SKIP] $($dataset.File) already exists ($([math]::Round($existing.Length / 1MB, 2)) MB)"
            continue
        }
    }

    Write-Host "[DOWNLOADING] $($dataset.File)"
    Invoke-WebRequest -Uri $dataset.Url -OutFile $destination

    $downloaded = Get-Item $destination
    if ($downloaded.Length -le 0) {
        throw "Downloaded file is empty: $destination"
    }

    Write-Host "[OK] $($dataset.File) - $([math]::Round($downloaded.Length / 1MB, 2)) MB"
}

Write-Host ""
Write-Host "Verifying downloaded files..."
Write-Host ""

$missing = @()

foreach ($dataset in $datasets) {
    $path = Join-Path $rawDir $dataset.File

    if (-not (Test-Path $path)) {
        $missing += $dataset.File
        Write-Host "[MISSING] $($dataset.File)"
        continue
    }

    $file = Get-Item $path
    if ($file.Length -le 0) {
        $missing += $dataset.File
        Write-Host "[EMPTY] $($dataset.File)"
        continue
    }

    Write-Host "[READY] $($dataset.File) - $([math]::Round($file.Length / 1MB, 2)) MB"
}

if ($missing.Count -gt 0) {
    Write-Host ""
    Write-Error "Some datasets did not download correctly: $($missing -join ', ')"
}

Write-Host ""
Write-Host "All Effective Pandas datasets are ready for offline use."
Write-Host "Raw data folder: $rawDir"
Write-Host ""
