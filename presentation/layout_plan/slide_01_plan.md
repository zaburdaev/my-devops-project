### Slide 1 — Title / Cover

**Objective:** Make a strong first impression by introducing the project, author, and course with a bold, professional cover.

---

## Layout Composition

The slide is a `flex-col` container centered both vertically and horizontally (full 1920×1080). Content is stacked top-to-bottom with generous vertical spacing. No header/footer on this cover slide.

A subtle full-bleed background texture (dark grid lines) is implied by the background color. A thin horizontal Accent 1 line separates the title block from the metadata block.

Structure (top → bottom):
1. **Tag line row** — small badge: `text-3xl` — centered
2. **Main Title block** — two-line title, centered
3. **Accent divider line** — thin `border-t border-[#58A6FF]` horizontal rule, width ~40%
4. **Metadata row** — flex-row, three centered columns: Author | Course | Date
5. **Links row** — flex-row, two centered pill badges: GitHub + Docker Hub

---

## Content Breakdown

- **Block 1:**
  - Block Type: Text
  - Placement: Top center — small badge above the title
  - Component Schema: Badge / Tag
  - Content:
    - Label: "Final Project Defense"
  - Creative Brief: Small pill badge with Accent 1 border, uppercase, `text-3xl`, letter-spacing wide. Accent 1 text color.

- **Block 2:**
  - Block Type: Text
  - Placement: Center — main title block
  - Component Schema: Cover Headline
  - Content:
    - Line1: "DevOps Health Monitoring"
    - Line2: "Dashboard"
    - Subtitle: "my-devops-project"
  - Creative Brief: Line1+Line2 in `text-9xl font-bold font-lato` primary text color. Subtitle in `text-5xl font-normal font-merriweather` secondary color. All centered.

- **Block 3:**
  - Block Type: Text
  - Placement: Below title, after accent divider
  - Component Schema: Metadata Row
  - Content:
    - Author_Label: "Author"
    - Author_Value: "Vitalii Zaburdaiev"
    - Course_Label: "Course"
    - Course_Value: "DevOpsUA6"
    - Date_Label: "Date"
    - Date_Value: "April 2026"
  - Creative Brief: Three cards in a flex-row, each with a small tertiary label above a bold primary value (`text-4xl`). Subtle `bg-[#161B22]` card background with Accent 1 top border. Centered.

- **Block 4:**
  - Block Type: Text
  - Placement: Bottom center — links row
  - Component Schema: Link Badges Row
  - Content:
    - Link1_Icon: "Github"
    - Link1_Label: "github.com/zaburdaev/my-devops-project"
    - Link2_Icon: "Container" (use `Box` icon)
    - Link2_Label: "oskalibriya/health-dashboard"
  - Creative Brief: Two pill-shaped badges side by side. Icon + text in `text-3xl`. Accent 1 border. Secondary text color. Centered.
