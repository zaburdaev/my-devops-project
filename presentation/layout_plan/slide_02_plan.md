### Slide 2 — Project Overview

**Objective:** Quickly communicate what the project is, why it was built, and where to find it.

---

## Layout Composition

The slide is a `flex-col` with an auto-sized header, a main body that grows, and an auto-sized footer.

The body is a `grid` with two columns in a `1fr 1fr` ratio.
- **Left column:** `flex-col` with a large summary text block (grows) and a goal/purpose card below (auto).
- **Right column:** `flex-col` with three stacked info cards (equal grow ratios 1:1:1): GitHub card, Docker Hub card, and a quick-stats card.

---

## Content Breakdown

- **Block 1 — Header:**
  - Block Type: Text
  - Placement: Top header bar
  - Component Schema: Slide Header
  - Content:
    - Title: "Обзор проекта"
    - Icon: "LayoutDashboard"
  - Creative Brief: Left-aligned, Accent 1 vertical left border bar, `text-6xl font-bold font-lato`.

- **Block 2 — Project Summary:**
  - Block Type: Text
  - Placement: Left column, top, grows
  - Component Schema: Feature Highlight
  - Content:
    - Headline: "Flask-приложение для мониторинга здоровья системы"
    - Description: "Демонстрирует полный цикл DevOps: от кода до production-ready инфраструктуры."
    - Badges: ["CPU / RAM / Disk", "REST API", "Metrics & Logs"]
  - Creative Brief: Headline in `text-5xl font-bold` Accent 1. Description in `text-3xl` secondary. Badges as small pill tags in Accent 1 border. Clean, minimal.

- **Block 3 — Goal Card:**
  - Block Type: Text
  - Placement: Left column, bottom (auto height)
  - Component Schema: Goal Card
  - Content:
    - Icon: "Target"
    - Label: "Цель проекта"
    - Value: "Демонстрация DevOps практик на реальном приложении"
  - Creative Brief: Dark card `bg-[#161B22]`, Accent 1 icon, bold label, secondary value text.

- **Block 4 — GitHub Link Card:**
  - Block Type: Text
  - Placement: Right column, first card (1/3 height)
  - Component Schema: Link Card
  - Content:
    - Icon: "Github"
    - Label: "GitHub Repository"
    - Value: "github.com/zaburdaev/my-devops-project"
  - Creative Brief: Card with Accent 1 left border, icon + label + URL. `text-3xl`.

- **Block 5 — Docker Hub Card:**
  - Block Type: Text
  - Placement: Right column, second card (1/3 height)
  - Component Schema: Link Card
  - Content:
    - Icon: "Box"
    - Label: "Docker Hub"
    - Value: "oskalibriya/health-dashboard"
  - Creative Brief: Same style as GitHub card. Accent 1 border.

- **Block 6 — Quick Stats Card:**
  - Block Type: Text
  - Placement: Right column, third card (1/3 height)
  - Component Schema: Stat Row
  - Content:
    - Stats: [{"value": "7", "label": "Services"}, {"value": "12", "label": "Unit Tests"}, {"value": "3", "label": "API Endpoints"}]
  - Creative Brief: Three mini-stats side by side. Value in `text-5xl font-bold` Accent 1. Label in `text-3xl` secondary. Dark card background.

- **Block 7 — Footer:**
  - Block Type: Text
  - Placement: Bottom footer bar
  - Component Schema: Slide Footer
  - Content:
    - Left: "DevOpsUA6"
    - Center: "Vitalii Zaburdaiev"
    - Right: "github.com/zaburdaev/my-devops-project"
  - Creative Brief: `text-3xl` tertiary color. Thin top border Accent 1 at 20% opacity.
