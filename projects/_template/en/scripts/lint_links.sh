#!/usr/bin/env bash
#
# Lint [[links]] in the wiki or the task wiki, no Python.
# Run from the project data dir (<DataRoot>/projects/<Project>):
#   scripts/lint_links.sh wiki    # wiki/*.md and wiki/pages/*.md against wiki/pages/
#   scripts/lint_links.sh tasks   # tasks/{index,log}.md and tasks/pages/*.md against tasks/pages/ and wiki/pages/
#
set -uo pipefail

case "${1:-}" in
  wiki) dirs=(wiki/pages); files=(wiki/*.md wiki/pages/*.md); index=wiki/index.md ;;
  tasks) dirs=(tasks/pages wiki/pages); files=(tasks/index.md tasks/log.md tasks/pages/*.md); index=tasks/index.md ;;
  *) echo "Usage: lint_links.sh wiki|tasks" >&2; exit 1 ;;
esac

slugs() { for d in "$@"; do ls "$d"/*.md 2>/dev/null; done | sed 's|.*/||; s|\.md$||'; }
own="$(slugs "${dirs[0]}")"
valid="$(slugs "${dirs[@]}")"

echo "pages: $(printf '%s\n' "$own" | grep -c .)"
echo "broken links:"
for f in "${files[@]}"; do
  [ -f "$f" ] || continue
  grep -o '\[\[[^]]*\]\]' "$f" | sed 's/^\[\[//; s/\]\]$//' | while IFS= read -r l; do
    printf '%s\n' "$valid" | grep -qxF -- "$l" || echo "  $f: $l"
  done
done
echo "not in index:"
printf '%s\n' "$own" | while IFS= read -r p; do
  [ -n "$p" ] && ! grep -qF -- "[[$p]]" "$index" && echo "  $p"
done
exit 0
