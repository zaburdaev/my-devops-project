### Slide 3 — Solution Architecture

**Objective:** Visually explain how the 6 services interconnect, making the architecture immediately scannable.

---

## Layout Composition

The slide is a `flex-col` with header (auto), body (grows), footer (auto).

The body is a `flex-col` with a single architecture diagram block that fills all available space.

The architecture diagram is a hand-crafted text/icon component rendered as a `flex-row` of layered tier columns connected by arrows:
- **Tier 1 (Client):** 1 node
- **Tier 2 (Gateway):** 1 node — Nginx
- **Tier 3 (App):** 1 node — Flask App
- **Tier 4 (Data):** 2 nodes — PostgreSQL + Redis
- **Tier 5 (Monitoring):** 2 nodes — Prometheus + Grafana

Each tier is a `flex-col` with a tier label on top and service cards stacked below. Tiers are connected by horizontal arrows (`→`) between them. The overall layout is a `flex-row` with equal spacing, centered vertically.

---

## Content Breakdown

- **Block 1 — Header:**
  - Block Type: Text
  - Placement: Top header bar
  - Component Schema: Slide Header
  - Content:
    - Title: "Архитектура решения"
    - Icon: "Network"
  - Creative Brief: Standard header style. `text-6xl font-bold font-lato` Accent 1 left bar.

- **Block 2 — Architecture Diagram:**
  - Block Type: Text
  - Placement: Body, grows to fill
  - Component Schema: Architecture Diagram
  - Content:
    - Tiers:
      - Tier1: {Label: "Client", Nodes: [{Name: "Browser / curl", Icon: "Globe"}]}
      - Tier2: {Label: "Gateway", Nodes: [{Name: "Nginx", Icon: "Shield", Badge: ":80/:443"}]}
      - Tier3: {Label: "Application", Nodes: [{Name: "Flask App", Icon: "Code2", Badge: "Python"}]}
      - Tier4: {Label: "Data Layer", Nodes: [{Name: "PostgreSQL", Icon: "Database", Badge: "Metrics DB"}, {Name: "Redis", Icon: "Zap", Badge: "Cache"}]}
      - Tier5: {Label: "Monitoring", Nodes: [{Name: "Prometheus", Icon: "Activity", Badge: "Metrics"}, {Name: "Grafana", Icon: "BarChart2", Badge: "Dashboards"}]}
    - Arrow_Label: "→"
    - Caption: "6 сервисов управляются через Docker Compose"
  - Creative Brief: Each service node is a dark card `bg-[#161B22]` with icon (Accent 1) and name (`text-3xl` primary). Tier label is `text-3xl` secondary, centered above nodes. Arrow connectors in Accent 1. Tiers are evenly spaced in a flex-row. Caption centered below in tertiary italic.

- **Block 3 — Footer:**
  - Block Type: Text
  - Placement: Bottom footer bar
  - Component Schema: Slide Footer
  - Content:
    - Left: "DevOpsUA6"
    - Center: "Vitalii Zaburdaiev"
    - Right: "github.com/zaburdaev/my-devops-project"
  - Creative Brief: Standard footer style.
