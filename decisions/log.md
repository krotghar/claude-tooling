# Журнал решений тулинга — хронология

Полная история до 2026-10-28 — в журнале данных (`$CLAUDE_DATA/decisions/log.md`).

## [2026-10-28] tooling-data-layout | тулинг выделен из каталога данных в git-репозиторий
Нейтральное перенесено копией: `link.sh` (два корня, `CLAUDE_DATA`/`CLAUDE_PROJECTS`), `home/CLAUDE.md`, шаблон `home/settings.json`, `projects/_template` (плейсхолдеры `<DataRoot>`/`<ToolingRoot>`), `memory/_template`, схема `decisions/`. Allowlist-`.gitignore`, pre-commit-хук с общими и личными паттернами.
