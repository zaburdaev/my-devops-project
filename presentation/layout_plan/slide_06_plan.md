### Slide 6 — Containerization (Docker)

**Objective:** Demonstrate mastery of Docker best practices: multi-stage builds, compose orchestration, and security.

---

## Layout Composition

The slide is a `flex-col` with header (auto), body (grows), footer (auto).

The body is a `grid` with two columns in a `1fr 1fr` ratio.
- **Left column:** `flex-col` — Multi-stage Dockerfile breakdown card (grows).
- **Right column:** `flex-col` with two stacked cards: Docker Compose services list (grows) + Best Practices card (auto).

---

## Content Breakdown

- **Block 1 — Header:**
  - Block Type: Text
  - Placement: Top header bar
  - Component Schema: Slide Header
  - Content:
    - Title: "Контейнеризация (Docker)"
    - Icon: "Box"
  - Creative Brief: Standard header style.

- **Block 2 — Multi-Stage Dockerfile:**
  - Block Type: Text
  - Placement: Left column, grows
  - Component Schema: Process Flow (vertical)
  - Content:
    - Title: "Multi-Stage Dockerfile"
    - Stages:
      - {Stage: "Stage 1: Builder", Detail: "python:3.11-slim — install deps", Icon: "Package"}
      - {Stage: "Stage 2: Runtime", Detail: "Копируем только нужные артефакты", Icon: "Layers"}
      - {Stage: "Result", Detail: "Минимальный образ, без build-зависимостей", Icon: "CheckCircle2"}
    - Benefit: "Размер образа уменьшен на ~60%"
  - Creative Brief: Vertical flow with numbered stages connected by vertical arrows. Each stage is a dark card. Stage names in `text-4xl font-bold` Accent 1. Detail in `text-3xl` secondary. Benefit as a green Accent 2 callout at bottom.

- **Block 3 — Docker Compose Services:**
  - Block Type: Text
  - Placement: Right column, top, grows
  - Component Schema: Service List
  - Content:
    - Title: "Docker Compose — 6 сервисов"
    - Services:
      - {Name: "app", Role: "Flask Application"}
      - {Name: "postgres", Role: "Database"}
      - {Name: "redis", Role: "Cache"}
      - {Name: "nginx", Role: "Reverse Proxy"}
      - {Name: "prometheus", Role: "Metrics Collector"}
      - {Name: "grafana", Role: "Visualization"}
  - Creative Brief: Dark card. Services as two-column list: service name in `text-3xl font-bold` Accent 1 monospace style | role in secondary. Compact, scannable.

- **Block 4 — Best Practices:**
  - Block Type: Text
  - Placement: Right column, bottom (auto)
  - Component Schema: Checklist Card
  - Content:
    - Title: "Best Practices"
    - Items:
      - {Icon: "ShieldCheck", Text: "Non-root user"}
      - {Icon: "HeartPulse", Text: "Health checks"}
      - {Icon: "Lock", Text: "Secrets via env vars"}
  - Creative Brief: Three items in a flex-row, each with Accent 2 (green) check icon + `text-3xl` text. Clean horizontal badge row.

- **Block 5 — Footer:**
  - Block Type: Text
  - Placement: Bottom footer bar
  - Component Schema: Slide Footer
  - Content:
    - Left: "DevOpsUA6"
    - Center: "Vitalii Zaburdaiev"
    - Right: "github.com/zaburdaev/my-devops-project"
  - Creative Brief: Standard footer style.
