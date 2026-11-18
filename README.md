# claude-tooling

Обвязка Claude Code: глобальные правила, стек-нейтральный шаблон проекта (скиллы, агенты,
хук-скрипты), общие feedback-памяти и `link.sh`, который раскладывает всё это симлинками.

Тулинг (этот репозиторий, git) отделён от **данных** — обвязки и вики конкретных проектов,
памяти, журнала решений по проектам. Данные лежат в `$CLAUDE_DATA` (по умолчанию
`~/Documents/claude-config`) и в git не попадают. Как синкать данные между машинами (iCloud,
Syncthing, никак) — решает владелец данных, тулинг этого не обещает.

## Установка

```bash
git clone https://github.com/krotghar/claude-tooling
cd claude-tooling
claude "Install the tooling following INSTALL.md"
```

По команде на строку — так они работают и в bash, и в PowerShell 5.1, где нет `&&`.

[`INSTALL.md`](INSTALL.md) — промпт-инсталлятор: спросит язык шаблонов (`ru`/`en`) и где
держать данные, перенесёт существующий `~/.claude/CLAUDE.md` в личные правила, пропишет
`additionalDirectories`, слинкует и подключит первый проект. Следующие проекты —
`/onboard-project` в новой сессии. `/tooling-review` разбирает историю сессий проекта и
предлагает правки обвязки (сам ничего не применяет).

Windows: нужен Developer Mode (Параметры → Система → Для разработчиков). `link.sh` и скрипты
шаблона — на bash и работают в Git Bash, который и так ставится с Claude Code; Python и jq не
нужны. Без Developer Mode `link.sh` падает на создании симлинка, а не копирует файлы молча.

## Языки

`home/`, `projects/_template/`, `memory/_template/` — в двух деревьях, `ru/` и `en/`. RU —
источник, EN — перевод: меняешь RU — обнови EN. Язык выбирается при установке
(`CLAUDE_TOOLING_LANG`, по умолчанию `ru`).

## Раскладка

Из тулинга:

- `home/<язык>/CLAUDE.md` → `~/.claude/CLAUDE.md`
- `home/<язык>/skills/<скилл>/` → `~/.claude/skills/<скилл>` — `onboard-project`, `tooling-review`
- `home/settings.json` — шаблон `~/.claude/settings.json` (не линкуется, сверять руками)
- `projects/_template/<язык>/`, `memory/_template/<язык>/` — заготовки нового проекта, никуда не линкуются

Из данных (`$CLAUDE_DATA`):

- `home/skills/<скилл>/` → `~/.claude/skills/<скилл>` — личные скиллы
- `fish/*.fish` → `~/.config/fish/functions/`
- `home/CLAUDE.md` → `~/.claude/CLAUDE.personal.md` — личные правила, глобальный `CLAUDE.md` импортирует их
- `memory/<Проект>/` → `~/.claude/projects/<ключ-проекта>/memory/`
- `projects/<Проект>/CLAUDE.md` → `<worktree>/CLAUDE.md` и `<worktree>/AGENTS.md` ([agents.md](https://agents.md/) — для остальных агентов)
- `projects/<Проект>/skills/` → `<worktree>/.claude/skills`
- `projects/<Проект>/agents/` → `<worktree>/.claude/agents`
- `projects/<Проект>/scripts/` → `<worktree>/.claude/scripts`
- `projects/<Проект>/settings.json` → `<worktree>/.claude/settings.json`

Ключ памяти считается от реального пути главного воркtree при `link.sh <воркtree>`;
`--home` перелинковывает память только проектов, лежащих в `$CLAUDE_PROJECTS` (по умолчанию
`~/StudioProjects`). Настройки `link.sh` — переменные окружения или `local.env` рядом со
скриптом (`CLAUDE_DATA`, `CLAUDE_TOOLING_LANG`, `CLAUDE_PROJECTS`; окружение главнее). Имена в данных без ведущей точки — так их видно в Finder; точку
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

Проще — `/onboard-project`. Вручную: `./link.sh --init <воркtree>` — если
`$CLAUDE_DATA/projects/<имя главного воркtree>/` нет, копирует туда
`projects/_template/<язык>` (копию, не симлинк), раскладывает `wiki/` и `tasks/`,
подставляет `<Project>`, `<DataRoot>` и `<ToolingRoot>`, пишет дату копии в
`.template-origin` и линкует. Дальше:

1. Заполнить `CLAUDE.md` проекта — особенно Commands: сборку, тесты, линт и запуск агенты
   берут оттуда.
2. Специализировать скиллы и агентов в данных проекта под стек.
3. Память — по желанию: скопировать нужные файлы из `memory/_template/<язык>/` в
   `$CLAUDE_DATA/memory/<проект>/` с `MEMORY.md`, затем `./link.sh <воркtree>`.

## Новая машина

1. `git clone` этого репо, дождаться данных в `$CLAUDE_DATA`.
2. `./link.sh --home`, затем `./link.sh` на каждый воркtree проекта.
3. Сверить `~/.claude/settings.json` с `home/settings.json`: `additionalDirectories`
   должен покрывать оба корня.

## Защита от утечек

`.gitignore` — allowlist: новый файл в индекс не попадёт, пока его не разрешили явно.
pre-commit-хук (`git config core.hooksPath hooks`) сканирует индекс по общим паттернам
`hooks/leak-patterns` и личным `$CLAUDE_DATA/.leak-patterns` (в репо не входят).
