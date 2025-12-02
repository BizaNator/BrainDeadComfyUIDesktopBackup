# Create mock ComfyUI installation for testing
$mockPath = Join-Path $env:LOCALAPPDATA "Programs\@comfyorgcomfyui-electron"

Write-Host "Creating mock ComfyUI installation at: $mockPath" -ForegroundColor Cyan

# Create directories
New-Item -ItemType Directory -Path $mockPath -Force | Out-Null
New-Item -ItemType Directory -Path "$mockPath\models" -Force | Out-Null
New-Item -ItemType Directory -Path "$mockPath\custom_nodes" -Force | Out-Null
New-Item -ItemType Directory -Path "$mockPath\workflows" -Force | Out-Null

# Create mock files
@{
    "config.json" = @"
{
  "version": "1.0.0",
  "settings": {
    "theme": "dark",
    "autoSave": true
  }
}
"@
    "workflow.json" = @"
{
  "nodes": [],
  "links": [],
  "version": "0.1.0"
}
"@
    "custom_nodes\test_node.py" = @"
# Test custom node
class TestNode:
    def __init__(self):
        pass
"@
    "workflows\example.json" = '{"workflow": "example"}'
    "models\test_model.safetensors" = "MOCK MODEL DATA " * 1000
    "README.txt" = "This is a mock ComfyUI installation for testing the backup script."
} | ForEach-Object {
    $filePath = Join-Path $mockPath $_.Key
    $_.Value | Out-File -FilePath $filePath -Encoding UTF8
}

Write-Host "✓ Mock installation created successfully!" -ForegroundColor Green
Write-Host "  Location: $mockPath" -ForegroundColor Yellow
Write-Host "  Files created:" -ForegroundColor Yellow
Get-ChildItem -Path $mockPath -Recurse -File | ForEach-Object {
    $relativePath = $_.FullName.Replace($mockPath, '')
    Write-Host "    - $relativePath" -ForegroundColor Gray
}
