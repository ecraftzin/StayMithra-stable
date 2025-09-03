# PowerShell script to optimize images for smaller APK size
Write-Host "🖼️ Optimizing images for smaller APK size..." -ForegroundColor Green

# Check if ImageMagick is available (optional optimization)
$imageMagickAvailable = $false
try {
    magick -version | Out-Null
    $imageMagickAvailable = $true
    Write-Host "✅ ImageMagick found - will use for optimization" -ForegroundColor Green
} catch {
    Write-Host "⚠️ ImageMagick not found - will use basic optimization" -ForegroundColor Yellow
}

# Function to optimize PNG files
function Optimize-PngFile {
    param(
        [string]$inputPath,
        [string]$outputPath,
        [int]$quality = 85,
        [int]$maxWidth = 1024
    )
    
    if ($imageMagickAvailable) {
        Write-Host "Optimizing: $inputPath" -ForegroundColor Cyan
        
        # Get original size
        $originalSize = (Get-Item $inputPath).Length
        
        # Optimize with ImageMagick
        magick "$inputPath" -resize "${maxWidth}x${maxWidth}>" -quality $quality -strip "$outputPath"
        
        # Get new size
        $newSize = (Get-Item $outputPath).Length
        $savings = [math]::Round((($originalSize - $newSize) / $originalSize) * 100, 1)
        
        Write-Host "  Original: $([math]::Round($originalSize/1KB, 1)) KB" -ForegroundColor Gray
        Write-Host "  Optimized: $([math]::Round($newSize/1KB, 1)) KB" -ForegroundColor Gray
        Write-Host "  Savings: $savings%" -ForegroundColor Green
    } else {
        # Just copy the file if ImageMagick is not available
        Copy-Item $inputPath $outputPath -Force
        Write-Host "Copied: $inputPath (no optimization available)" -ForegroundColor Yellow
    }
}

# Create backup directory
$backupDir = "assets_backup"
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Write-Host "📁 Created backup directory: $backupDir" -ForegroundColor Blue
}

# Backup original assets
Write-Host "📦 Backing up original assets..." -ForegroundColor Blue
Copy-Item -Path "assets" -Destination "$backupDir/assets_original" -Recurse -Force

# Optimize large images
Write-Host "🔧 Optimizing images..." -ForegroundColor Blue

# Optimize getstarted.png (largest file)
Optimize-PngFile -inputPath "assets/images/getstarted.png" -outputPath "assets/images/getstarted.png" -quality 75 -maxWidth 800

# Optimize signinup.png
Optimize-PngFile -inputPath "assets/images/signinup.png" -outputPath "assets/images/signinup.png" -quality 80 -maxWidth 600

# Optimize launcher icon (keep high quality for app icon)
Optimize-PngFile -inputPath "assets/logo/staymithraluncher.png" -outputPath "assets/logo/staymithraluncher.png" -quality 90 -maxWidth 512

# Keep logo and social icons as-is (they're already small)

Write-Host "✅ Image optimization complete!" -ForegroundColor Green
Write-Host "📊 Check the new file sizes:" -ForegroundColor Cyan

Get-ChildItem -Path "assets" -Recurse -File | Select-Object Name, @{Name="Size(KB)";Expression={[math]::Round($_.Length/1KB,2)}} | Format-Table -AutoSize
