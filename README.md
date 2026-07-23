# EasyRide

Crowd-sourced карта ям: телефон в машине ловит удары акселерометра, привязывает их к GPS и собирает общую карту дефектов дороги.

## Боль

- Водитель не знает, где на маршруте жёсткие ямы, пока не въедет.
- У города и сервисов нет «живой» карты дефектов покрытия — только разовые обходы и жалобы.
- Навигаторы оптимизируют время и пробки, но почти не учитывают качество асфальта.

## Решение (MVP)

1. **App (Flutter)** в foreground-службе слушает `userAccelerometer`, при силе удара выше порога берёт GPS и скорость, шлёт телеметрию на backend.
2. **Backend (FastAPI + PostGIS)** нормализует силу удара по скорости, «прищёлкивает» точку к дороге через OSRM Nearest, сохраняет `POINT` в PostGIS.
3. **Кластеризация** (`ST_ClusterDBSCAN`) объединяет близкие удары; кластер считается подтверждённым, если ≥2 уникальных пользователя **или** ≥3 попаданий.
4. **Карта** показывает подтверждённые ямы цветом по силе, неподтверждённые — серыми маркерами.

## Стек

| Слой | Технологии |
|------|------------|
| Клиент | Flutter (Dart 3), geolocator, sensors_plus, flutter_foreground_task, flutter_map, latlong2, http |
| API | FastAPI, Pydantic, Uvicorn |
| Данные | PostgreSQL + PostGIS (Docker), SQLAlchemy, GeoAlchemy2 |
| Внешнее | OSRM public `nearest` (`router.project-osrm.org`) |

## Структура репозитория

```
projects/
├── README.md                 # этот файл
├── ARCHITECTURE.md           # дерево модулей и публичные сущности
├── AGENTS.md                 # правила для ИИ и стиль кода
├── easyride_app/             # Flutter-клиент
└── easyride_backend/         # FastAPI + PostGIS
```

Подробная карта файлов и функций: **[ARCHITECTURE.md](./ARCHITECTURE.md)**.  
Правила написания кода (для людей и агентов): **[AGENTS.md](./AGENTS.md)**.

## Запуск backend

Требования: Docker, Python 3.11+.

```bash
cd easyride_backend

# PostGIS
docker compose up -d

# Зависимости (один раз)
python -m venv venv
# Windows:
venv\Scripts\activate
# Linux/macOS:
# source venv/bin/activate
pip install -r requirements.txt

# API
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Проверка:

```bash
curl http://localhost:8000/health
```

Ожидается JSON со `"status": "ok"` и версией PostGIS.

Строка подключения к БД сейчас в `easyride_backend/database.py`:

`postgresql://admin:password123@localhost:5432/easyride_db`

## Запуск app

Требования: Flutter SDK, устройство/эмулятор с GPS и акселерометром (реальный телефон предпочтительнее).

```bash
cd easyride_app
flutter pub get
flutter run
```

### Важно про API URL

Базовый URL захардкожен в `easyride_app/lib/api_service.dart`:

```dart
static const String apiUrl = 'http://64.188.74.72:8000/api/v1/telemetry';
```

Для локальной разработки замените хост на IP машины в той же сети, что и телефон (не `localhost` с физического устройства). Android cleartext HTTP может потребовать network security config.

## API (кратко)

| Метод | Путь | Назначение |
|-------|------|------------|
| `GET` | `/health` | Живость API и БД, версия PostGIS |
| `POST` | `/api/v1/telemetry` | Принять удар (яму) |
| `GET` | `/api/v1/telemetry` | Список кластеров ям |

### `POST /api/v1/telemetry`

Тело (JSON):

```json
{
  "user_id": "test_user_01",
  "latitude": 55.75,
  "longitude": 37.61,
  "speed_kmh": 40.0,
  "bump_force": 12.5
}
```

Ответ (успех): `status`, `snapped_lat`, `snapped_lon`, нормализованный `bump_force`.

### `GET /api/v1/telemetry`

Массив кластеров: `cluster_id`, `lat`, `lon`, `max_force`, `unique_users`, `total_hits`, `is_confirmed`.

## Экраны приложения (обзор)

| Вкладка | Экран | Статус |
|---------|--------|--------|
| Карта | `MapScreen` | Живые данные с API |
| Список | `ListScreen` | UI-заглушки карточек |
| Детекция | `DetectScreen` + `Dashboard` | UI + реальный foreground-скан |
| Профиль | `ProfileScreen` | UI-заглушка |
| Детали | `PotholeDetailsScreen` | UI-заглушка |

## Tech debt (осознанно)

- Хардкод URL API и `user_id` в клиенте.
- Учётные данные БД в исходниках (только для MVP/dev).
- Часть экранов на мок-данных, не на API.
- `Dashboard` (логи + старт службы) живёт в `main.dart`, home приложения — `MainScaffold`.

## Для ИИ и контрибьюторов

1. Прочитай **[AGENTS.md](./AGENTS.md)** — чеклист перед каждой новой функцией.
2. Сверься с **[ARCHITECTURE.md](./ARCHITECTURE.md)**, чтобы не дублировать модули.
3. Не меняй контракт API без синхронного обновления клиента и этих документов.
