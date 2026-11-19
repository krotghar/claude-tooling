#!/usr/bin/env bash
#
# Линт [[ссылок]] вики или вики задач, без Python.
# Запуск из каталога проекта в данных (<DataRoot>/projects/<Project>):
#   scripts/lint_links.sh wiki    # wiki/*.md и wiki/pages/*.md против wiki/pages/
#   scripts/lint_links.sh tasks   # tasks/{index,log}.md и tasks/<dir>/<dir>.md против папок тикетов и wiki/pages/
#
set -uo pipefail

slugs() { for d in "$@"; do ls "$d"/*.md 2>/dev/null; done | sed 's|.*/||; s|\.md$||'; }

case "${1:-}" in
  wiki)
    own="$(slugs wiki/pages)"
    files=(wiki/*.md wiki/pages/*.md)
    index=wiki/index.md ;;
  tasks)
    # Слац тикета = имя его каталога; документ — tasks/<dir>/<dir>.md.
    # Прочие .md в папке тикета (планы, ревью, отчёты) слацами не считаются
    # и не проверяются как цели.
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
  *) echo "Использование: lint_links.sh wiki|tasks" >&2; exit 1 ;;
esac

# Хвостовой перевод строки снимаем: сшиваем списки одним своим переводом строки.
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
