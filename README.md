# claude-tooling

Обвязка Claude Code: глобальные правила, стек-нейтральный шаблон проекта (скиллы, агенты,
хук-скрипты), общие feedback-памяти и `link.sh`, который раскладывает всё это симлинками.

Тулинг (этот репозиторий, git) отделён от **данных** — обвязки и вики конкретных проектов,
памяти, журнала решений по проектам. Данные лежат в `$CLAUDE_DATA` (по умолчанию
`~/Documents/claude-config`) и в git не попадают. Как синкать данные между машинами (iCloud,
Syncthing, никак) — решает владелец данных, тулинг этого не обещает.

## Раскладка

Из тулинга:

- `home/CLAUDE.md` → `~/.claude/CLAUDE.md` и `~/.agents/AGENTS.md` (глобальный AGENTS.md — читает Cline)
- `home/settings.json` — шаблон `~/.claude/settings.json` (не линкуется, сверять руками)
- `projects/_template/`, `memory/_template/` — заготовки нового проекта, никуда не линкуются

Из данных (`$CLAUDE_DATA`):

- `home/skills/<скилл>/` → `~/.claude/skills/<скилл>` — личные скиллы
- `fish/*.fish` → `~/.config/fish/functions/`
- `memory/<Проект>/` → `~/.claude/projects/<ключ-проекта>/memory/`
- `projects/<Проект>/CLAUDE.md` → `<worktree>/CLAUDE.md` и `<worktree>/AGENTS.md` ([agents.md](https://agents.md/) — для остальных агентов)
- `projects/<Проект>/skills/` → `<worktree>/.claude/skills`
- `projects/<Проект>/agents/` → `<worktree>/.claude/agents`
- `projects/<Проект>/scripts/` → `<worktree>/.claude/scripts`
- `projects/<Проект>/settings.json` → `<worktree>/.claude/settings.json`

Ключ памяти считается от главного воркtree `$CLAUDE_PROJECTS/<Проект>` (по умолчанию
`~/StudioProjects`). Имена в данных без ведущей точки — так их видно в Finder; точку
добавляет симлинк на стороне воркtree.

## Разметка

```bash
./link.sh --home                              # домашние симлинки
./link.sh ~/StudioProjects/<проект-worktree>   # симлинки в конкретный воркtree
./link.sh --init ~/StudioProjects/<проект>     # новый проект: копия шаблона + симлинки
```

Идемпотентно, безопасно гонять повторно. Реальный файл на месте симлинка не затирается —
переименовывается в `<имя>.bak`. Слинкованные пути дописываются в `.git/info/exclude`
проекта.

## Новый проект

`./link.sh --init <воркtree>` — если `$CLAUDE_DATA/projects/<имя главного воркtree>/` нет,
копирует туда `projects/_template` (копию, не симлинк), раскладывает `wiki/` и `tasks/`,
подставляет `<Project>`, `<DataRoot>` и `<ToolingRoot>`, пишет дату копии в
`.template-origin` и линкует. Дальше:

1. Заполнить `CLAUDE.md` проекта — особенно Commands: сборку, тесты, линт и запуск агенты
   берут оттуда.
2. Специализировать скиллы и агентов в данных проекта под стек.
3. Память — по желанию: `cp -R memory/_template "$CLAUDE_DATA/memory/<проект>"`, затем
   `./link.sh --home`.

## Новая машина

1. `git clone` этого репо, дождаться данных в `$CLAUDE_DATA`.
2. `./link.sh --home`, затем `./link.sh` на каждый воркtree проекта.
3. Сверить `~/.claude/settings.json` с `home/settings.json`: `additionalDirectories`
   должен покрывать оба корня.

## Защита от утечек

`.gitignore` — allowlist: новый файл в индекс не попадёт, пока его не разрешили явно.
pre-commit-хук (`git config core.hooksPath hooks`) сканирует индекс по общим паттернам
`hooks/leak-patterns` и личным `$CLAUDE_DATA/.leak-patterns` (в репо не входят).
