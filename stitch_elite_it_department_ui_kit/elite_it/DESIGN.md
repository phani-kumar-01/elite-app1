---
name: ELITE IT
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#45464c'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#575e70'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#141b2b'
  on-primary-container: '#7d8497'
  inverse-primary: '#c0c6db'
  secondary: '#b02d29'
  on-secondary: '#ffffff'
  secondary-container: '#ff665c'
  on-secondary-container: '#690007'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#121c28'
  on-tertiary-container: '#7a8594'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce2f7'
  primary-fixed-dim: '#c0c6db'
  on-primary-fixed: '#141b2b'
  on-primary-fixed-variant: '#404758'
  secondary-fixed: '#ffdad6'
  secondary-fixed-dim: '#ffb4ac'
  on-secondary-fixed: '#410002'
  on-secondary-fixed-variant: '#8e1214'
  tertiary-fixed: '#d9e3f4'
  tertiary-fixed-dim: '#bdc7d8'
  on-tertiary-fixed: '#121c28'
  on-tertiary-fixed-variant: '#3e4755'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1.5rem
  margin: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style
This design system is engineered for an elite college IT department application, blending academic rigor with cutting-edge technological prowess. The personality is authoritative, sophisticated, and relentlessly precise. It evokes a sense of absolute reliability, prestige, and forward-thinking innovation. 

The chosen aesthetic is a refined evolution of **Minimalism** meeting **Corporate / Modern**, characterized by pristine white spatial fields, deep charcoal typography for maximum legibility, and a restrained, sophisticated crimson red accent that commands attention only where vital. The UI relies on generous whitespace, razor-sharp alignment, and whisper-thin structural dividers to organize complex administrative and academic data streams effortlessly.

## Colors
The color palette is deliberately restrained, establishing a clinical yet inviting academic environment. 

- **Primary:** Deep charcoal (`#111827`) anchors the interface, utilized for primary headers, high-priority text, and dominant structural elements.
- **Secondary:** Crimson red (`#991B1B`) serves as the precise accent for critical actions, system alerts, active states, and prestige branding markers.
- **Tertiary:** Slate gray (`#4B5563`) provides mid-tone support for secondary labels, inactive states, and structural metadata.
- **Neutral:** Pure white (`#FFFFFF`) and ultra-light gray (`#F9FAFB`) form the expansive canvases and card surfaces, ensuring peerless contrast and readability.

## Typography
Typography is treated as the primary structural element of the system. Utilizing Inter throughout creates a systematic, utilitarian, yet exceptionally refined voice. Tracking is subtly tightened on large display headers to project modern authority, while body scales are optimized for high-density academic and technical reading. 

Ensure line heights remain strictly adhered to, preventing vertical rhythm drift across complex data tables and applicant dashboards.

## Layout & Spacing
The layout relies on a strict **fluid grid system** tailored for modern mobile app styling and responsive web portals. Content flows gracefully within responsive container boundaries, utilizing a foundational 8px spacing rhythm. 

- **Breakpoints:** Mobile (< 640px) uses single-column stacking with 16px lateral margins; Tablet (640px – 1024px) transitions to a structured 2-column modular grid; Desktop (> 1024px) expands to a max-width container with robust multi-column dashboard layouts.
- **Margins & Gutters:** Generous outer margins isolate the application workspace, while consistent gutters prevent visual crowding of dense technical logs and student records.

## Elevation & Depth
Elevation is handled through **low-contrast outlines** and pristine **tonal layers** rather than heavy drop shadows, reinforcing the clean, digital-first academic aesthetic. 

- **Surfaces:** Utilize pure white cards (`#FFFFFF`) layered over the ultra-light neutral background (`#F9FAFB`).
- **Borders:** Define component boundaries using ultra-thin, low-contrast neutral borders (`#E5E7EB`). 
- **Active States:** Elevate interactive elements and modals with hyper-subtle, diffuse ambient shadows (`0 4px 20px -2px rgba(17, 24, 39, 0.05)`) paired with a crimson red border highlight for focused or active items.

## Shapes
The shape language employs a **rounded** approach (Level 2), striking the ideal balance between clinical precision and approachable modern mobile app styling. 

- **Containers & Cards:** Standard cards utilize `0.5rem` border radius, expanding to `1rem` (`rounded-lg`) for prominent feature modules and modal dialogs.
- **Interactive Elements:** Buttons, input fields, and chips maintain smooth, consistent curves that soften the authoritative dark charcoal typography without sacrificing structural integrity.

## Components
Consistent execution of core interface elements guarantees a cohesive experience for student applicants and IT administrators alike.

- **Buttons:** Primary actions feature solid deep charcoal backgrounds with crisp white text, shifting to the crimson red accent upon hover or active states. Secondary actions utilize ghost styles with thin neutral borders.
- **Input Fields:** Designed with generous touch targets, subtle inner borders, clear floating or top-aligned labels, and crimson red focus rings. Error states instantly swap borders to crimson red with clear helper text.
- **Cards:** White surfaces elevated on light backgrounds, featuring rounded corners and subtle structural padding. Ideal for displaying course modules, applicant status trackers, and system metrics.
- **Chips & Badges:** Pill-shaped status indicators (e.g., "Application Received", "System Operational") utilizing ultra-light tinted backgrounds with matching text for rapid categorization.
- **Lists & Tables:** Clean, high-density data presentation utilizing horizontal hairline dividers and alternating row highlights for scanning complex academic records.
- **Checkboxes & Radios:** Minimalist square and circular selectors featuring deep charcoal borders, filling solidly with crimson red upon selection.