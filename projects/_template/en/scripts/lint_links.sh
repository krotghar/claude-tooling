#!/usr/bin/env bash
#
# Lint [[links]] in the wiki or the task wiki, no Python.
# Run from the project data dir (<DataRoot>/projects/<Project>):
#   scripts/lint_links.sh wiki    # wiki/*.md and wiki/pages/*.md against wiki/pages/
#   scripts/lint_links.sh tasks   # tasks/{index,log}.md and tasks/<dir>/<dir>.md against the ticket folders and wiki/pages/
#
set -uo pipefail

slugs() { for d in "$@"; do ls "$d"/*.md 2>/dev/null; done | sed 's|.*/||; s|\.md$||'; }

case "${1:-}" in
  wiki)
    own="$(slugs wiki/pages)"
    files=(wiki/*.md wiki/pages/*.md)
    index=wiki/index.md ;;
  tasks)
    # A ticket's slug is its folder name; the document is tasks/<dir>/<dir>.md.
    # Other .md files in the ticket folder (plans, reviews, reports) don't count
    # as slugs and aren't checked as targets.
    own=""
    files=(tasks/index.md tasks/log.md)
    for d in tasks/*; do
      [ -d "$d" ] || continue
      b="${d#tasks/}"
      [ -f "tasks/$b/$b.md" ] || continue
      own+="$b
"
      files+=("$d/$b.md")
    done
    index=tasks/index.md ;;
  *) echo "Usage: lint_links.sh wiki|tasks" >&2; exit 1 ;;
esac

# Drop the trailing newline: the two lists are joined with a single newline of our own.
own="${own%$'\n'}"
wiki="$(slugs wiki/pages)"
valid="$own
$wiki"

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
