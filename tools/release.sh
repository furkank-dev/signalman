#!/usr/bin/env bash
# release.sh — package.json'daki surumu GitHub'a yayinlar.
#
#   tools/release.sh            # repo kokunden, degisiklikler commit'lendikten sonra
#
# Ne yapar: calisma agaci temiz mi bakar, main'i push eder, v<surum> etiketini
# atar ve push eder, .vsix paketler (npx @vscode/vsce), gh ile release
# olusturur. Notlar CHANGELOG.md'deki "## <surum>" bolumunden alinir.
#
# Gerekenler: node/npx, gh (gh auth login yapilmis), SSH ile push.

set -euo pipefail
cd "$(dirname "$0")/.."

VER=$(python3 -c "import json; print(json.load(open('package.json'))['version'])")
TAG="v$VER"
echo "Surum: $VER"

[ -z "$(git status --porcelain)" ] || { echo "Commit edilmemis degisiklik var:"; git status --short; exit 1; }
grep -q "^## $VER" CHANGELOG.md || { echo "CHANGELOG.md'de '## $VER' bolumu yok."; exit 1; }

git push -q origin main && echo "  main push edildi"
if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
  echo "  $TAG zaten var"
else
  git tag -a "$TAG" -m "$VER"; echo "  $TAG olusturuldu"
fi
git push -q origin "$TAG" && echo "  $TAG push edildi"

VSIX="signalman-$VER.vsix"
npx --yes @vscode/vsce package --allow-missing-repository -o "$VSIX" >/dev/null
echo "  $VSIX paketlendi"

NOTES=$(awk -v v="$VER" '$0 ~ "^## "v {f=1;next} /^## /{f=0} f' CHANGELOG.md)
TITLE=$(grep -m1 "^## $VER" CHANGELOG.md | sed 's/^## //')
if gh release view "$TAG" >/dev/null 2>&1; then
  gh release upload "$TAG" "$VSIX" --clobber >/dev/null && echo "  release vardi, vsix guncellendi"
else
  gh release create "$TAG" "$VSIX" --title "$TITLE" --notes "$NOTES" --latest >/dev/null && echo "  release olusturuldu"
fi
echo "Bitti: $(gh release view "$TAG" --json url --jq .url 2>/dev/null || echo "$TAG")"
