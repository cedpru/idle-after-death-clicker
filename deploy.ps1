# Automated build and deploy script for Idle After Death Clicker on GitHub Pages
$ErrorActionPreference = "Stop"

Write-Host "=== Starting Godot Web Export ===" -ForegroundColor Cyan
& "C:\Users\CedPru\Desktop\Godot_v4.6.2-stable_win64_console.exe" --headless --export-release "Web" build/web/index.html

Write-Host "=== Patching index.html for Web Audio & COOP/COEP ===" -ForegroundColor Cyan
$htmlPath = "build/web/index.html"
$htmlContent = Get-Content -Raw -Path $htmlPath

# Download coi-serviceworker if it doesn't exist
$coiPath = "build/web/coi-serviceworker.js"
if (-not (Test-Path $coiPath)) {
    Write-Host "Downloading coi-serviceworker.js..."
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gzuidhof/coi-serviceworker/master/coi-serviceworker.js" -OutFile $coiPath -UseBasicParsing
}

# The scripts we want to inject into <head>
$injectBlock = @"
<script src="coi-serviceworker.js"></script>
		<script>
			// Web Audio API auto-resume workaround for iOS Safari and other mobile browsers
			(function() {
				const contexts = [];
				const OriginalAudioContext = window.AudioContext || window.webkitAudioContext;
				if (OriginalAudioContext) {
					const CustomAudioContext = function() {
						const ctx = new OriginalAudioContext(...arguments);
						contexts.push(ctx);
						return ctx;
					};
					CustomAudioContext.prototype = OriginalAudioContext.prototype;
					if (window.AudioContext) window.AudioContext = CustomAudioContext;
					if (window.webkitAudioContext) window.webkitAudioContext = CustomAudioContext;
				}
				function resumeAll() {
					contexts.forEach(ctx => {
						if (ctx && ctx.state === 'suspended') {
							ctx.resume().then(() => {
								console.log("AudioContext successfully resumed via user interaction.");
							}).catch(err => {
								console.warn("Failed to resume AudioContext:", err);
							});
						}
					});
				}
				window.addEventListener('click', resumeAll, { passive: true });
				window.addEventListener('touchstart', resumeAll, { passive: true });
				window.addEventListener('touchend', resumeAll, { passive: true });
				window.addEventListener('mousedown', resumeAll, { passive: true });
			})();
		</script>
	</head>
"@

# Replace the closing </head> with our injected block + </head>
if ($htmlContent -match "</head>") {
    $htmlContent = $htmlContent -replace "</head>", $injectBlock
    Set-Content -Path $htmlPath -Value $htmlContent -NoNewline
    Write-Host "index.html successfully patched with Web Audio fixes!" -ForegroundColor Green
} else {
    Write-Error "Could not find </head> tag in index.html to inject scripts."
}

Write-Host "=== Preparing gh-pages branch ===" -ForegroundColor Cyan
# Save current branch name
$currentBranch = (git branch --show-current).Trim()

# Delete local gh-pages if it exists
git branch -D gh-pages 2>$null

# Checkout orphan branch
git checkout --orphan gh-pages
git rm -rf . --quiet

Write-Host "=== Copying build files to root ===" -ForegroundColor Cyan
Copy-Item -Path "build\web\*" -Destination "." -Recurse -Force

Write-Host "=== Committing and pushing to GitHub ===" -ForegroundColor Cyan
# Only add the exact 10 web files we want, to keep the gh-pages branch clean
git add index.html index.js index.wasm index.pck index.png index.icon.png index.apple-touch-icon.png coi-serviceworker.js index.audio.worklet.js index.audio.position.worklet.js
git commit -m "deploy: update game build with audio worklets and iOS Safari autoplay patches"
git push origin gh-pages --force

Write-Host "=== Switching back to main ===" -ForegroundColor Cyan
git checkout $currentBranch

Write-Host "🎉 DEPLOYMENT COMPLETE! The updated build with sound fixes is online." -ForegroundColor Green
