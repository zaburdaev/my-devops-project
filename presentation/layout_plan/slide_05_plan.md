### Slide 5 — Flask Application

**Objective:** Showcase the application's core features, API endpoints, and test coverage.

---

## Layout Composition

The slide is a `flex-col` with header (auto), body (grows), footer (auto).

The body is a `grid` with two columns in a `3fr 2fr` ratio.
- **Left column:** `flex-col` with an API endpoints list card (grows) and a storage layer row (auto) stacked.
- **Right column:** `flex-col` with a monitoring metrics card (grows) and a tests badge card (auto) stacked.

---

## Content Breakdown

- **Block 1 — Header:**
  - Block Type: Text
  - Placement: Top header bar
  - Component Schema: Slide Header
  - Content:
    - Title: "Приложение (Flask)"
    - Icon: "Code2"
  - Creative Brief: Standard header style.

- **Block 2 — API Endpoints:**
  - Block Type: Text
  - Placement: Left column, top, grows
  - Component Schema: Endpoint List
  - Content:
    - Section_Title: "API Endpoints"
    - Endpoints:
      - {Method: "GET", Path: "/health", Description: "Статус сервисов приложения"}
      - {Method: "GET", Path: "/metrics", Description: "Prometheus-совместимые метрики"}
      - {Method: "GET", Path: "/api/system-info", Description: "CPU, RAM, Disk — JSON ответ"}
  - Creative Brief: Dark card. Each endpoint is a row: method badge (Accent 1, `text-3xl`, monospace-style) + path in `text-3xl font-bold` primary + description in secondary. Clean REST API documentation aesthetic.

- **Block 3 — Storage Layer:**
  - Block Type: Text
  - Placement: Left column, bottom (auto)
  - Component Schema: Storage Row
  - Content:
    - Items:
      - {Icon: "Database", Name: "PostgreSQL", Role: "Хранение метрик"}
      - {Icon: "Zap", Name: "Redis", Role: "Кэширование"}
  - Creative Brief: Flex-row, two mini cards side by side. Icon + Name bold + Role secondary. Accent 1 icon.

- **Block 4 — Monitoring Metrics:**
  - Block Type: Text
  - Placement: Right column, top, grows
  - Component Schema: Metric Feature List
  - Content:
    - Section_Title: "Мониторинг системы"
    - Metrics:
      - {Icon: "Cpu", Label: "CPU Usage"}
      - {Icon: "MemoryStick", Label: "Memory Usage"}
      - {Icon: "HardDrive", Label: "Disk Usage"}
      - {Icon: "FileJson", Label: "JSON Logging → docker compose logs"}
  - Creative Brief: Dark card. Each metric is an icon + label row. Icon in Accent 1. Simple, clean list.

- **Block 5 — Tests Badge:**
  - Block Type: Text
  - Placement: Right column, bottom (auto)
  - Component Schema: Achievement Badge
  - Content:
    - Icon: "CheckCircle2"
    - Value: "12"
    - Label: "unit тестов (pytest)"
    - Status: "All Passing"
  - Creative Brief: Accent 2 (green) icon and value number in `text-5xl font-bold`. Label in secondary. Status badge in Accent 2. Dark card background. Visually celebratory but restrained.

- **Block 6 — Footer:**
  - Block Type: Text
  - Placement: Bottom footer bar
  - Component Schema: Slide Footer
  - Content:
    - Left: "DevOpsUA6"
    - Center: "Vitalii Zaburdaiev"
    - Right: "github.com/zaburdaev/my-devops-project"
  - Creative Brief: Standard footer style.
