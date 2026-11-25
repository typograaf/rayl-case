#!/bin/bash
# Makes the page's images from the Figma exports in src/ (not kept in git:
# 130 MB of PNG), and takes the generator from the Rayl Stack try-out build.
set -euo pipefail
cd "$(dirname "$0")"

wide() { magick "src/$1.png" -resize "${2}x>" -quality 84 "assets/$1.webp"; }
for name in billboard stand-hall screens car; do wide "$name" 2880; done
for name in hero process variants; do wide "$name" 1920; done
for name in tablet jacket label; do wide "$name" 1752; done
wide mark 876
for name in stand-front stand-left stand-right stand-top; do wide "$name" 1024; done

STACK="${RAYL_STACK:-$HOME/Documents/rayl-stack}"
(cd "$STACK" && npm run web >/dev/null)
rm -rf generator
cp -R "$STACK/dist/web" generator
rm -f generator/case.html generator/card.glb generator/circle.glb
rm -rf generator/cards
du -sh assets generator
