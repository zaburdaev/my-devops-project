### Slide 9 — Kubernetes + Ansible

**Objective:** Present the orchestration and automation layers side-by-side for a complete infrastructure picture.

---

## Layout Composition

The slide is a `flex-col` with header (auto), body (grows), footer (auto).

The body is a `grid` with two columns in a `1fr 1fr` ratio, divided by a thin vertical Accent 1 separator.
- **Left column:** Kubernetes section — `flex-col` with a section label (auto) and cards below (grows).
- **Right column:** Ansible section — `flex-col` with a section label (auto) and cards below (grows).

---

## Content Breakdown

- **Block 1 — Header:**
  - Block Type: Text
  - Placement: Top header bar
  - Component Schema: Slide Header
  - Content:
    - Title: "Kubernetes + Ansible"
    - Icon: "Cloud"
  - Creative Brief: Standard header style.

- **Block 2 — Kubernetes Section Label:**
  - Block Type: Text
  - Placement: Left column, top (auto)
  - Component Schema: Section Label
  - Content:
    - Icon: "Cloud"
    - Title: "Kubernetes"
    - Subtitle: "Оркестрация контейнеров"
  - Creative Brief: Icon + Title in `text-5xl font-bold` Accent 1. Subtitle in `text-3xl` secondary. Left-aligned.

- **Block 3 — Kubernetes Manifests:**
  - Block Type: Text
  - Placement: Left column, grows
  - Component Schema: Feature Card Stack
  - Content:
    - Cards:
      - {Icon: "Layers", Title: "Deployment", Detail: "2 реплики, rolling update стратегия, liveness/readiness probes"}
      - {Icon: "Globe", Title: "Service", Detail: "ClusterIP для внутренней маршрутизации"}
      - {Icon: "Package", Title: "Helm Chart", Detail: "Параметризованный chart, values.yaml для конфигурации", Badge: "Bonus"}
  - Creative Brief: Three stacked dark cards. Icon (Accent 1) + Title `text-4xl font-bold` primary + Detail `text-3xl` secondary. Helm card has a small Accent 2 "Bonus" badge.

- **Block 4 — Ansible Section Label:**
  - Block Type: Text
  - Placement: Right column, top (auto)
  - Component Schema: Section Label
  - Content:
    - Icon: "Terminal"
    - Title: "Ansible"
    - Subtitle: "Автоматизация настройки"
  - Creative Brief: Same style as Kubernetes section label.

- **Block 5 — Ansible Playbook Details:**
  - Block Type: Text
  - Placement: Right column, grows
  - Component Schema: Feature Card Stack
  - Content:
    - Cards:
      - {Icon: "Settings", Title: "Playbook", Detail: "Установка Docker, настройка окружения, деплой приложения"}
      - {Icon: "Users", Title: "Inventory", Detail: "Динамический инвентарь для AWS EC2"}
      - {Icon: "ShieldCheck", Title: "Idempotency", Detail: "Безопасный повторный запуск без побочных эффектов"}
  - Creative Brief: Same card style as Kubernetes cards.

- **Block 6 — Footer:**
  - Block Type: Text
  - Placement: Bottom footer bar
  - Component Schema: Slide Footer
  - Content:
    - Left: "DevOpsUA6"
    - Center: "Vitalii Zaburdaiev"
    - Right: "github.com/zaburdaev/my-devops-project"
  - Creative Brief: Standard footer style.
