#!/bin/bash
# Downloads the assets wget missed (videos, a few images, the trailers)
cd "$(dirname "$0")"
OLD=https://thorneprotocol.com
FILES="brand/keyart-16x9.jpg
kit/closing/renaissance-ghent-altarpiece.jpg
kit/p06-sheet-3.jpg
kit/p06-sheet-6.jpg
media/anim/bench-tubes.mp4
media/anim/circuit-spine.mp4
media/anim/cube-desk.mp4
media/anim/sparks-street.mp4
media/anim/the-question.mp4
media/anim/trailer-loop-01b-0829v2-640.mp4
media/anim/trailer-loop-01b-0829v2.mp4
media/brochure/mer-quiet-square-0914.jpg
media/dew-lens-1280.mp4
media/dew-lens.mp4
media/dragonfly-ignition-edited.mp4
media/dragonfly.mp4
media/jar-garden.mp4
media/transitions/cables.mp4
media/transitions/canopy.mp4
media/transitions/canopy.jpg
media/transitions/chip.mp4
media/transitions/leaf.mp4
media/transitions/spore.mp4
media/transitions/stump-jar.mp4
stills/br2-anchor-dragonfly.jpg
stills/elias-thorne.jpg
stills/greenhouse-night-aerial.jpg"
fail=0
for p in $FILES; do
  [ -s "$p" ] && continue
  mkdir -p "$(dirname "$p")"
  echo "Downloading $p"
  curl -sfL "$OLD/$p" -o "$p" || { echo "  FAILED: $p"; rm -f "$p"; fail=1; }
done

# Trailers live on Vercel Blob storage, not on the site itself
mkdir -p media/trailer
B1=https://xprsllq53dllraaa.public.blob.vercel-storage.com/trailer
B2=https://jn7smf6dtb65c3pc.public.blob.vercel-storage.com/trailer
tfail=0
for u in $B1/thorne-trailer-submitted.mp4 $B1/thorne-trailer-submitted-poster.jpg \
         $B2/thorne-trailer-final-0829-v2.mp4 $B2/thorne-trailer-final-0829-v2-poster.jpg; do
  f=media/trailer/$(basename "$u")
  [ -s "$f" ] && continue
  echo "Downloading $f"
  curl -fL --progress-bar "$u" -o "$f" || { echo "  FAILED: $u"; rm -f "$f"; tfail=1; }
done

# Point the trailer player at the local copies (only if all four downloaded)
if [ $tfail -eq 0 ]; then
  sed -i '' -e "s#$B1/#/media/trailer/#g" -e "s#$B2/#/media/trailer/#g" index.html
  echo "Trailer links now point to /media/trailer/"
else
  echo "Trailer links left pointing at Vercel because a download failed"
fi

echo
echo "Files over 95 MB (GitHub won't accept files over 100 MB):"
find . -path ./.git -prune -o -type f -size +95M -print
[ $fail -eq 0 ] && echo "All site assets downloaded." || echo "Some site assets failed; see above."
