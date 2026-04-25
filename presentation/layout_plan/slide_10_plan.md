### Slide 10 — Monitoring & Logging

**Objective:** Show how the full observability stack (metrics + dashboards + logs) works together.

---

## Layout Composition

The slide is a `flex-col` with header (auto), body (grows), footer (auto).

The body is a `grid` with two columns in a `2fr 3fr` ratio.
- **Left column:** `flex-col` with two stacked tool cards (Prometheus, Grafana) and one logging note card in equal grow ratios.
- **Right column:** `flex-col` — a mock Grafana dashboard panel rendered as a styled component with a bar chart.

---

## Content Breakdown

- **Block 1 — Header:**
  - Block Type: Text
  - Placement: Top header bar
  - Component Schema: Slide Header
  - Content:
    - Title: "Мониторинг и логирование"
    - Icon: "Activity"
  - Creative Brief: Standard header style.

- **Block 2 — Prometheus Card:**
  - Block Type: Text
  - Placement: Left column, 1/3 (equal grow)
  - Component Schema: Tool Card
  - Content:
    - Icon: "Activity"
    - Name: "Prometheus"
    - Role: "Сбор метрик"
    - Detail: "Scrapes /metrics каждые 60 сек"
  - Creative Brief: Dark card, Accent 1 icon, name `text-4xl font-bold`, detail `text-3xl` secondary.

- **Block 3 — Grafana Card:**
  - Block Type: Text
  - Placement: Left column, 2/3 (equal grow)
  - Component Schema: Tool Card
  - Content:
    - Icon: "BarChart2"
    - Name: "Grafana"
    - Role: "Визуализация"
    - Detail: "Дашборды CPU, Memory, HTTP метрики"
  - Creative Brief: Same style as Prometheus card.

- **Block 4 — Logging Card:**
  - Block Type: Text
  - Placement: Left column, 3/3 (equal grow)
  - Component Schema: Tool Card
  - Content:
    - Icon: "FileText"
    - Name: "Container Logs"
    - Role: "Логирование"
    - Detail: "JSON логи из Flask → docker compose logs"
  - Creative Brief: Same style as Prometheus card.

- **Block 5 — Mock Grafana Dashboard:**
  - Block Type: Chart
  - Chart Type: Bar Chart
  - Placement: Right column, grows to fill
  - Data:
    - X_Axis: ["00:00", "04:00", "08:00", "12:00", "16:00", "20:00", "24:00"]
    - Series:
      - {Name: "CPU Usage (%)", Values: [12, 18, 45, 62, 58, 41, 22], Color: "#58A6FF"}
      - {Name: "Memory Usage (%)", Values: [35, 37, 52, 68, 65, 54, 40], Color: "#3FB950"}
  - Metadata:
    - Title: "System Metrics — Last 24h"
    - Y_Axis_Label: "Usage (%)"
    - Y_Axis_Domain: [0, 100]
    - Legend: true
    - Grid: true
  - Sizing & Behavior: Fills the entire right column. Responsive, expand to fill container.
  - Creative Brief: Styled to look like a Grafana dark dashboard panel. Dark background `bg-[#161B22]`, Accent 1 and Accent 2 bars. Title as panel header. Grid lines subtle gray. Rounded panel border.

- **Block 6 — Footer:**
  - Block Type: Text
  - Placement: Bottom footer bar
  - Component Schema: Slide Footer
  - Content:
    - Left: "DevOpsUA6"
    - Center: "Vitalii Zaburdaiev"
    - Right: "github.com/zaburdaev/my-devops-project"
  - Creative Brief: Standard footer style.
