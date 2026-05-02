### Slide 8 — CI/CD Pipeline (GitHub Actions)

**Objective:** Illustrate the automated pipeline from code commit to production deployment.

---

## Layout Composition

The slide is a `flex-col` with header (auto), body (grows), footer (auto).

The body is a `flex-col`:
- **Top row (auto):** A horizontal pipeline diagram showing the stages as connected cards.
- **Bottom row (grows):** A `grid` with three equal columns (`1fr 1fr 1fr`) — detail cards for each major pipeline phase.

---

## Content Breakdown

- **Block 1 — Header:**
  - Block Type: Text
  - Placement: Top header bar
  - Component Schema: Slide Header
  - Content:
    - Title: "CI/CD Pipeline (GitHub Actions)"
    - Icon: "GitBranch"
  - Creative Brief: Standard header style.

- **Block 2 — Pipeline Flow Diagram:**
  - Block Type: Text
  - Placement: Body top row (auto height)
  - Component Schema: Horizontal Pipeline Flow
  - Content:
    - Stages:
      - {Name: "Code Push", Icon: "GitCommit", Color: "secondary"}
      - {Name: "Run Tests", Icon: "FlaskConical", Color: "Accent1"}
      - {Name: "Build Image", Icon: "Box", Color: "Accent1"}
      - {Name: "Push to Hub", Icon: "Upload", Color: "Accent1"}
      - {Name: "Deploy", Icon: "Rocket", Color: "Accent2"}
    - Arrow: "→"
  - Creative Brief: Five stage pills connected by Accent 1 arrows in a flex-row. Each pill: icon above + name below in `text-3xl`. Active stages (Run Tests → Deploy) in Accent 1 border. Deploy stage in Accent 2 border to signify final outcome.

- **Block 3 — Test Phase Detail:**
  - Block Type: Text
  - Placement: Bottom grid, column 1
  - Component Schema: Phase Detail Card
  - Content:
    - Phase: "Test"
    - Icon: "FlaskConical"
    - Items:
      - "pytest — 12 unit тестов"
      - "Coverage report"
      - "Автоматический запуск на push"
  - Creative Brief: Dark card with Accent 1 top border. Phase title `text-4xl font-bold`. Items as `text-3xl` bullet list with small Accent 1 dot. Icon in header.

- **Block 4 — Build Phase Detail:**
  - Block Type: Text
  - Placement: Bottom grid, column 2
  - Component Schema: Phase Detail Card
  - Content:
    - Phase: "Build"
    - Icon: "Box"
    - Items:
      - "docker build (multi-stage)"
      - "Тег: latest + git SHA"
      - "Push → Docker Hub"
  - Creative Brief: Same card style as Block 3.

- **Block 5 — Deploy Phase Detail:**
  - Block Type: Text
  - Placement: Bottom grid, column 3
  - Component Schema: Phase Detail Card
  - Content:
    - Phase: "Deploy"
    - Icon: "Rocket"
    - Items:
      - "SSH deploy на EC2"
      - "docker compose up -d"
      - "Автоматический health check"
  - Creative Brief: Same card style but with Accent 2 (green) top border to indicate final success stage.

- **Block 6 — Footer:**
  - Block Type: Text
  - Placement: Bottom footer bar
  - Component Schema: Slide Footer
  - Content:
    - Left: "DevOpsUA6"
    - Center: "Vitalii Zaburdaiev"
    - Right: "github.com/zaburdaev/my-devops-project"
  - Creative Brief: Standard footer style.
