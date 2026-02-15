# Multitool.infra.GitHub — CI-инфраструктура для 1С конфигураций

Репозиторий содержит **инфраструктуру CI** для сборки и тестирования репозиториев с конфигурациями 1С. Он отделён от репозитория приложения и может переиспользоваться для разных проектов 1С.

**Репозиторий приложения (1С конфигурация):** [Ndochp/multitool](https://github.com/Ndochp/multitool)

Архитектура разделения описана в [DOC/Architecture.md](DOC/Architecture.md).

## Роль репозитория

- Workflow'ы GitHub Actions для сборки, тестов и релизов
- Скрипты настройки self-hosted runner (локальный исполнитель)
- Документация по настройке и контракту с репо приложения

Репозиторий приложения содержит только код 1С, тесты и описание архитектуры — без привязки к конкретному CI. Разработчик форкает оба репо, настраивает секреты и получает CI/MR-тесты и релизные артефакты.

## Структура проекта

```
Multitool.infra.GitHub
├── .github
│   └── workflows
│       ├── build-pipeline.yml   # Сборка и тесты
│       └── release.yml          # Создание релиза и артефактов
├── DOC
│   └── Architecture.md         # Архитектура изоляции репо
├── scripts
│   ├── run-local-runner.sh      # Установка runner (Linux/macOS)
│   └── run-local-runner.ps1     # Установка runner (Windows)
└── README.md
```

## Настройка (fork)

### 1. Форк репозиториев

- Сделайте fork [Multitool.infra.GitHub](https://github.com/Ndochp/Multitool.infra.GitHub) (этот репо).
- Сделайте fork [Ndochp/multitool](https://github.com/Ndochp/multitool) (репо приложения), если собираетесь собирать его.

### 2. Секреты и переменные

В вашем fork **Multitool.infra.GitHub**: Settings → Secrets and variables → Actions.

| Имя               | Описание |
| ----------------- | -------- |
| `GITHUB_PAT`      | Personal Access Token (repo) для checkout репо приложения |
| `APP_REPOSITORY`  | Переменная (или в workflow): `owner/repo` целевого репо приложения |

### 3. Self-hosted runner

На машине, где будет выполняться сборка^

- **Windows:** из корня репо выполните `.\scripts\run-local-runner.ps1` (при необходимости передайте URL репо и задайте `GITHUB_PAT` в окружении).
- **Linux/macOS:** `./scripts/run-local-runner.sh <repository-url>` (например `https://github.com/your-org/Multitool.infra.GitHub`). Требуется `GITHUB_PAT` в окружении для получения токена регистрации.

Кроме того, должна быть уставновлена платформа 1С, oscript пакеты add, vanessa runner. Команды oscript должны запускаться без указания пути (прописаны в PATH)

Подробнее см. комментарии в скриптах и [DOC/Architecture.md](DOC/Architecture.md).

### 4. Запуск

- Вкладка **Actions** → выберите workflow **Build Pipeline** (или **Release**) → **Run workflow**. Укажите репозиторий приложения, если запрашивается.
- Workflow выполняется на self-hosted runner, клонирует репо приложения и запускает сборку/тесты по контракту (EDT или Designer batch, скрипты из репо приложения).

## Контракт с репозиторием приложения

Репо приложения должен иметь ожидаемую структуру (пока согласно vanessa bootstrap, потом возможно будут предусмотрены конфигурационные файлы) и при необходимости скрипты/конфигурации для тестов. Подробнее — в [DOC/Architecture.md](DOC/Architecture.md), раздел «Контракт между репозиториями».

## Лицензия

MIT.
