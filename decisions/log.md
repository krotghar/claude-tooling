# Журнал решений тулинга — хронология

Полная история до 2026-10-28 — в журнале данных (`$CLAUDE_DATA/decisions/log.md`).

## [2026-10-28] tooling-data-layout | тулинг выделен из каталога данных в git-репозиторий
Нейтральное перенесено копией: `link.sh` (два корня, `CLAUDE_DATA`/`CLAUDE_PROJECTS`), `home/CLAUDE.md`, шаблон `home/settings.json`, `projects/_template` (плейсхолдеры `<DataRoot>`/`<ToolingRoot>`), `memory/_template`, схема `decisions/`. Allowlist-`.gitignore`, pre-commit-хук с общими и личными паттернами.

## [2026-10-29] tooling-data-layout | leak guard: авторство не скрывается (решение 6)
Убрана проверка автора на noreply, свой `user.email` в содержимом разрешён; `CLAUDE.md` — «не проектозависимый», а не «обезличенный».
