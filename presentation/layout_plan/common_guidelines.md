# Common Guidelines

## Color Scheme
- **Background:** #0D1117 (deep dark navy)
- **Primary Text:** #E6EDF3 (near-white)
- **Secondary Text:** #8B949E (muted gray-blue)
- **Tertiary Text / Captions:** #6E7681 (dim gray)
- **Accent 1 (dominant):** #58A6FF (bright blue)
- **Accent 2 (sparingly):** #3FB950 (green — for success/positive states)

## Font Pairing
- **Primary Font (headings):** `.font-lato` — Lato (Google) / Corbel (PowerPoint fallback)
- **Secondary Font (body):** `.font-merriweather` — Merriweather (Google) / Constantia (PowerPoint fallback)

## Typography Scale
| Usage | Tailwind Class |
|---|---|
| Cover title | `text-9xl` |
| Section headline | `text-7xl` |
| Slide title | `text-6xl` |
| Main headers | `text-5xl` |
| Sub-headers | `text-4xl` |
| Body / lists | `text-3xl` |

Font weight: `font-bold` for titles/headers, `font-normal` for body, `italic` for captions.

## Slide Dimensions
Each slide is a `1920px × 1080px` div. No scrolling. All content must fit.

## Layout Rules
- Every non-cover slide must have a **header**, **body**, and **footer**.
- Header: slide title in `text-6xl font-bold font-lato` with a left-side Accent 1 vertical bar.
- Footer: course name `DevOpsUA6` on the left | author `Vitalii Zaburdaiev` centered | GitHub URL on the right — all in `text-3xl` tertiary color.
- Use `bg-[#0D1117]` as the base slide background.
- Cards/panels: `bg-[#161B22]` with `border border-[#30363D]` rounded corners.
- Accent dividers: `border-[#58A6FF]`.

## Icons
- Use **lucide-react** icons throughout.
- Place icons inline with text or centered above metric values.
- Icon color: Accent 1 `#58A6FF` by default; Accent 2 `#3FB950` for success/positive.

## No animations, no page numbers, no navigation arrows.
