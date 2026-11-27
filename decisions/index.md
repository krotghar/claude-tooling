# Журнал решений тулинга — каталог

Схема и правила — `CLAUDE.md` рядом. Хронология — `log.md`. Полная история до выделения
тулинга в git и общие решения — в журнале данных (`$CLAUDE_DATA/decisions/`), решения по
обвязке конкретного проекта — в `$CLAUDE_DATA/projects/<проект>/decisions/`.

## Сквозные темы
- [[tooling-data-layout]] — тулинг в git, данные без git; `CLAUDE_DATA`, плейсхолдеры, `link.sh --home` из двух корней, защита от утечек
- [[knowledge-routing]] — что куда пишется: auto memory, `CLAUDE.md`, `wiki/`, `tasks/`, `decisions/`

## Шаблон проекта
- [[project-template]] — `projects/_template/<язык>`, `memory/_template/<язык>`, `link.sh --init`
- [[orchestrate]] — скилл оркестрации: планировщик `general-purpose` с Write пишет `plan.md` сам

## Установка
- [[installer]] — `INSTALL.md`, `UPDATE.md`, скиллы `onboard-project` и `tooling-review`

## Машинные скрипты
- [[statusline]] — статус-бар Claude Code: fish-префикс + git-ветка + имя сессии + занятость контекста (`home/scripts/statusline.sh` → `~/.claude/scripts/`)
- [[name-session-hook]] — хук `UserPromptSubmit`: имя сессии по номеру задачи из первого промпта (`home/scripts/name-session-hook.sh` → `~/.claude/scripts/`)
