### Slide 7 — Infrastructure as Code (Terraform)

**Objective:** Show how AWS infrastructure is fully automated and reproducible via Terraform.

---

## Layout Composition

The slide is a `flex-col` with header (auto), body (grows), footer (auto).

The body is a `grid` with two columns in a `2fr 3fr` ratio.
- **Left column:** `flex-col` — Terraform workflow steps card (grows).
- **Right column:** `flex-col` — AWS resources diagram card (grows).

---

## Content Breakdown

- **Block 1 — Header:**
  - Block Type: Text
  - Placement: Top header bar
  - Component Schema: Slide Header
  - Content:
    - Title: "Infrastructure as Code (Terraform)"
    - Icon: "ServerCog"
  - Creative Brief: Standard header style.

- **Block 2 — Terraform Workflow:**
  - Block Type: Text
  - Placement: Left column, grows
  - Component Schema: Process Flow (vertical)
  - Content:
    - Title: "Terraform Workflow"
    - Steps:
      - {Step: "terraform init", Icon: "Play", Detail: "Инициализация провайдера AWS"}
      - {Step: "terraform plan", Icon: "FileSearch", Detail: "Предпросмотр изменений"}
      - {Step: "terraform apply", Icon: "Rocket", Detail: "Создание ресурсов в AWS"}
      - {Step: "terraform destroy", Icon: "Trash2", Detail: "Удаление инфраструктуры"}
  - Creative Brief: Vertical numbered flow. Each step as a card with command in `text-3xl font-bold` Accent 1 monospace. Detail in secondary. Vertical Accent 1 connector line between steps.

- **Block 3 — AWS Resources Diagram:**
  - Block Type: Text
  - Placement: Right column, grows
  - Component Schema: Infrastructure Diagram
  - Content:
    - Title: "AWS Resources"
    - Provider_Badge: "AWS"
    - Resources:
      - {Type: "EC2 Instance", Icon: "Server", Detail: "t2.micro, Ubuntu 22.04", Category: "Compute"}
      - {Type: "Security Group", Icon: "Shield", Detail: "Ports: 22, 80, 443, 3000, 9090", Category: "Network"}
      - {Type: "Key Pair", Icon: "Key", Detail: "SSH доступ", Category: "Security"}
    - Principle: "Идемпотентность: повторный apply не создаёт дубли"
  - Creative Brief: Dark card. Three resource cards in a vertical stack, each with icon (Accent 1) + type (`text-4xl font-bold` primary) + detail (`text-3xl` secondary) + category badge. Principle as italic footer inside the card in tertiary color.

- **Block 4 — Footer:**
  - Block Type: Text
  - Placement: Bottom footer bar
  - Component Schema: Slide Footer
  - Content:
    - Left: "DevOpsUA6"
    - Center: "Vitalii Zaburdaiev"
    - Right: "github.com/zaburdaev/my-devops-project"
  - Creative Brief: Standard footer style.
