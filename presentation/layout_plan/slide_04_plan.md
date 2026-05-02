### Slide 4 — Technology Stack

**Objective:** Give the audience an instant visual inventory of all technologies used in the project.

---

## Layout Composition

The slide is a `flex-col` with header (auto), body (grows), footer (auto).

The body is a `grid` with 4 columns (`1fr 1fr 1fr 1fr`) and 2 rows (`1fr 1fr`), creating 8 tech cards. Each card is centered and equally sized.

---

## Content Breakdown

- **Block 1 — Header:**
  - Block Type: Text
  - Placement: Top header bar
  - Component Schema: Slide Header
  - Content:
    - Title: "Технологический стек"
    - Icon: "Layers"
  - Creative Brief: Standard header style.

- **Block 2 — Tech Cards Grid:**
  - Block Type: Text
  - Placement: Body — 4×2 grid, each cell a tech card
  - Component Schema: Technology Card Grid
  - Content:
    - Cards:
      - {Icon: "Code2", Name: "Python / Flask", Role: "Web Application", Color: "Accent1"}
      - {Icon: "Box", Name: "Docker", Role: "Containerization", Color: "Accent1"}
      - {Icon: "Cloud", Name: "Kubernetes", Role: "Orchestration", Color: "Accent1"}
      - {Icon: "ServerCog", Name: "Terraform", Role: "Infrastructure as Code", Color: "Accent1"}
      - {Icon: "Terminal", Name: "Ansible", Role: "Automation", Color: "Accent1"}
      - {Icon: "Activity", Name: "Prometheus", Role: "Metrics", Color: "Accent2"}
      - {Icon: "BarChart2", Name: "Grafana", Role: "Dashboards", Color: "Accent2"}
      - {Icon: "GitBranch", Name: "GitHub Actions", Role: "CI/CD Pipeline", Color: "Accent2"}
  - Creative Brief: Each card is `bg-[#161B22]` with `border border-[#30363D]` rounded-xl. Icon large (`text-5xl` equivalent, 48px) in designated accent color centered at top. Name in `text-4xl font-bold` primary. Role in `text-3xl` secondary below. Slight hover-style border top in accent color to differentiate infra (Accent1) vs monitoring/CI (Accent2). Grid evenly padded.

- **Block 3 — Footer:**
  - Block Type: Text
  - Placement: Bottom footer bar
  - Component Schema: Slide Footer
  - Content:
    - Left: "DevOpsUA6"
    - Center: "Vitalii Zaburdaiev"
    - Right: "github.com/zaburdaev/my-devops-project"
  - Creative Brief: Standard footer style.
