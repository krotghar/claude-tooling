# Журнал решений тулинга — хронология

Полная история до 2026-10-28 — в журнале данных (`$CLAUDE_DATA/decisions/log.md`).

## [2026-10-28] tooling-data-layout | тулинг выделен из каталога данных в git-репозиторий
Нейтральное перенесено копией: `link.sh` (два корня, `CLAUDE_DATA`/`CLAUDE_PROJECTS`), `home/CLAUDE.md`, шаблон `home/settings.json`, `projects/_template` (плейсхолдеры `<DataRoot>`/`<ToolingRoot>`), `memory/_template`, схема `decisions/`. Allowlist-`.gitignore`, pre-commit-хук с общими и личными паттернами.

## [2026-10-29] tooling-data-layout | leak guard: авторство не скрывается (решение 6)
Убрана проверка автора на noreply, свой `user.email` в содержимом разрешён; `CLAUDE.md` — «не проектозависимый», а не «обезличенный».

## [2026-10-31] tooling-data-layout | репозиторий публичный, MIT (решение 7)
Перед `--visibility public` — скан утечек по всей истории и PR-рефам. В истории нашлись следы приватного проекта — репо пересоздан с историей без них, старый — private `claude-tooling-old`. Добавлены `LICENSE` (MIT) и строка в allowlist `.gitignore`.

## [2026-11-17] tooling-data-layout | убраны AGENTS.md-симлинки из link.sh (решение 8)
Других агентов, кроме Claude Code, больше нет. Из `link.sh` удалены глобальный `~/.agents/AGENTS.md` (`--home`) и `AGENTS.md` в воркtree. Подробно — в журнале данных.


## [2026-11-17] tooling-data-layout | личные правила — импортом из данных (решение 9)
Глобальный `CLAUDE.md` в конце импортирует `~/.claude/CLAUDE.personal.md`; `link.sh --home` линкует туда `$CLAUDE_DATA/home/CLAUDE.md`, если он есть.

## [2026-11-18] tooling-data-layout | ворктри-линк AGENTS.md возвращён (решение 10)
Глобальный `~/.agents/AGENTS.md` остаётся снятым (Cline выпилен вместе с `rec`, `pi`); `<worktree>/AGENTS.md` в `link.sh` и README возвращён — пересматривает решение 8 в части ворктри.

## [2026-11-18] installer | ИИ-инсталлятор: INSTALL.md, onboard-project, tooling-review
Промпт-инсталлятор поверх `link.sh`, скилл подключения проекта (минимальный `CLAUDE.md` по файлам), скилл разбора истории с предложениями без автоприменения.

## [2026-11-18] project-template | RU/EN деревья, нейтральные памяти (решения 9–11)
`home/`, `projects/_template/`, `memory/_template/` разбиты на `ru/` и `en/`; из памятей убраны личные даты и вкусы, две коммитные памяти удалены. Сверку проекта с шаблоном решили не заводить.

## [2026-11-18] tooling-data-layout | local.env, ключ памяти, Windows (решения 11–13)
`link.sh` читает `local.env`, линкует память по реальному пути воркtree, под Git Bash делает нативные симлинки; `sed -i` убран.

## [2026-11-18] tooling-data-layout | скрипты шаблона без Python, пробелы в путях (решение 14)
`research_edit_guard.sh` на bash, линт ссылок — `scripts/lint_links.sh`; `awk` в хуках не режет путь воркtree на пробеле. Найдено тестом на Windows.

## [2026-11-18] tooling-data-layout | отслеживаемые пути и пути Windows (решения 15–16)
`link.sh` не линкует поверх файлов из git проекта (`CLAUDE.local.md`, `settings.local.json` или пропуск), `onboard-project` это учитывает; guard research-агента сравнивает пути в форме `C:/x/y`. Найдено прогоном `INSTALL.md` на клоне самого тулинга.
