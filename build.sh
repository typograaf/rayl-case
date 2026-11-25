#!/bin/bash
# Makes the page's images from the Figma exports in src/ (not kept in git:
# 130 MB of PNG), and takes the generator from the Rayl Stack try-out build.
set -euo pipefail
cd "$(dirname "$0")"

wide() { magick "src/$1.png" -resize "${2}x>" -quality 84 "assets/$1.webp"; }
for name in billboard stand-hall screens car; do wide "$name" 2880; done
for name in tablet jacket label; do wide "$name" 1752; done
for name in stand-front stand-left stand-right stand-top; do wide "$name" 1024; done

# The four tiles that move, from the finals in Dropbox: 60 frames a second
# as delivered, a size down from their 4K, no sound, and ready to start
# before the whole file is in. A first frame of each as its poster.
FINALS="${RAYL_FINALS:-$HOME/Library/CloudStorage/Dropbox/AboutContact/Clients/Current/WeWantMore/Rayl/Design/Case/Final Images}"
film() {
  ffmpeg -v error -y -i "$FINALS/$1" -an -vf "scale=$3:-2:flags=lanczos" \
    -c:v libx264 -preset slow -crf 21 -pix_fmt yuv420p -movflags +faststart \
    "assets/$2.mp4"
  ffmpeg -v error -y -i "assets/$2.mp4" -frames:v 1 -q:v 3 "assets/$2.jpg"
}
if [ -d "$FINALS" ]; then
  film "horizontal baskets main visual 2xres.mp4" hero 2560
  film "logo loop.mp4" mark 1752
  film "tool bento.mp4" process 2560
  film "full motion bento 2x res.mp4" variants 2560
  rm -f assets/hero.webp assets/mark.webp assets/process.webp assets/variants.webp
fi

STACK="${RAYL_STACK:-$HOME/Documents/rayl-stack}"
(cd "$STACK" && npm run web >/dev/null)
rm -rf generator
cp -R "$STACK/dist/web" generator
rm -f generator/case.html generator/card.glb generator/circle.glb
rm -rf generator/cards
du -sh assets generator
