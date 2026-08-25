---
name: SplitBill
description: A calm, filed-and-fair ledger for shared money.
colors:
  primary: "#246B58"
  primary-dark: "#174C3E"
  canvas: "#F3F0E8"
  paper: "#FFFDF7"
  paper-muted: "#E8E8DE"
  ink: "#1C2821"
  ink-muted: "#667168"
  line: "#D3D5C9"
  accent-coral: "#D9664B"
  accent-coral-soft: "#F5D9D1"
  accent-gold: "#D5A940"
  accent-gold-soft: "#F5EBCB"
  nav: "#1C2821"
typography:
  display:
    fontFamily: "System"
    fontSize: "32sp"
    fontWeight: 800
    letterSpacing: "-0.8"
  headline:
    fontFamily: "System"
    fontSize: "24sp"
    fontWeight: 800
    letterSpacing: "-0.4"
  title:
    fontFamily: "System"
    fontSize: "18sp"
    fontWeight: 800
  body:
    fontFamily: "System"
    fontSize: "15sp"
    lineHeight: "22sp"
  label:
    fontFamily: "System"
    fontSize: "11sp"
    fontWeight: 800
    letterSpacing: "1.2"
rounded:
  sm: "10dp"
  md: "16dp"
  lg: "24dp"
spacing:
  sm: "8dp"
  md: "16dp"
  lg: "24dp"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "#FFFDF7"
    rounded: "{rounded.sm}"
    height: "52dp"
    padding: "14dp 18dp"
  surface-paper:
    backgroundColor: "{colors.paper}"
    rounded: "{rounded.md}"
    padding: "18dp"
  field:
    backgroundColor: "{colors.paper}"
    rounded: "{rounded.sm}"
    height: "52dp"
    padding: "12dp 14dp"
---

# Design System: SplitBill

## Overview

**Creative North Star: “Filed & Fair.”**

SplitBill is built like a well-kept library card: every entry has a place, every number has a source, and the whole record can be understood by the next person who opens it. The visual world uses warm paper, deep evergreen ink, archive labels, thin rules, and restrained coral or gold marks for state. It is practical without looking generic and expressive without making money feel playful.

The interface refuses the default finance dashboard: no chart-first hero, no glossy gradient, no anonymous gray card stack. Instead, the first viewport establishes the ledger metaphor immediately and each workflow reads like a small, legible record. The product remains calm under uncertainty, with clear copy and visible validation before anything is filed.

**Key Characteristics:**

- Warm paper canvas with deep ink and evergreen action color.
- Ruled dividers and compact uppercase archive labels.
- Tonal surfaces instead of decorative shadows.
- Coral for destructive or unsettled states; gold for ownership and review.
- Material 3 structure adapted to a document-like visual language.

## Colors

The palette is intentionally low-glare and high-contrast: paper carries reading, evergreen carries action, and accents are reserved for state.

### Primary

- **Archive Evergreen** (#246B58): primary actions, active navigation, selected split controls, and the main balance surface.
- **Deep Evergreen** (#174C3E): darkened primary treatment and high-emphasis ink.

### Secondary

- **Ledger Coral** (#D9664B): destructive actions, warnings, and unsettled or attention-needed states.
- **Registry Gold** (#D5A940): ownership, review, and small status marks.

### Neutral

- **Warm Canvas** (#F3F0E8): screen background and the visual field around records.
- **Paper** (#FFFDF7): cards, fields, and reading surfaces.
- **Paper Muted** (#E8E8DE): inactive fields, selected-state contrast, and low-level tonal grouping.
- **Ink** (#1C2821): primary text.
- **Ink Muted** (#667168): supporting copy, labels, and metadata.
- **Rule Line** (#D3D5C9): dividers and low-emphasis borders.

### Named Rules

**The Source-of-Truth Rule.** Every amount should sit beside the context that explains it: payer, participant, date, currency, or status.

**The Rare Accent Rule.** Coral and gold are state signals, not decoration; keep them scarce enough to be meaningful.

## Typography

**Display Font:** Android System (Roboto)

**Body Font:** Android System (Roboto)

**Character:** Strong, compact headings give the ledger authority while the body stays open and readable at Android system font scales. Labels are uppercase with tracking to feel like catalog metadata, never like code.

### Hierarchy

- **Display** (800, 32sp): page titles and the home greeting.
- **Headline** (800, 24sp): major record titles and empty-state statements.
- **Title** (800, 18sp): section headings, group names, and expense names.
- **Body** (400, 15sp / 22sp): explanations, metadata, and input copy.
- **Label** (800, 11sp, 1.2 tracking, uppercase): archive labels, statuses, and small navigation copy.

## Layout

Screens use an edge-to-edge-safe, single-column reading field with 20dp horizontal insets and 16dp paper surfaces. The primary action is placed directly after the context it affects. Dense lists use ruled rows rather than nested cards. On compact Android widths, the bottom navigation stays to four text destinations; the stack uses system Back and custom screen titles rather than a second native header.

The spacing rhythm is 8 / 16 / 24dp. Headings get more space above than below, and long forms group fields under short uppercase section labels. All controls are at least 48dp tall and remain usable under larger Android font scales.

## Elevation & Depth

The system is flat by default. Depth comes from tonal separation between canvas, paper, muted paper, and the evergreen record surface, with a 1dp line used only when a boundary clarifies structure. Decorative shadows and glass effects are not part of this world.

## Shapes

The shape language is rounded but disciplined: 10dp for controls and fields, 16dp for paper surfaces, and 24dp only for large feature surfaces. Borders are quiet, never thick accent rails. Pills are reserved for short status marks and selected states.

## Components

### Buttons

- **Primary:** evergreen filled button, 52dp minimum height, 10dp radius, bold on-primary label.
- **Secondary:** paper or transparent background with a 1dp evergreen outline.
- **Destructive:** transparent or paper background with a coral outline and coral label.
- **State:** pressed and disabled states reduce opacity; loading replaces the label with an activity indicator.

### Chips

- **Style:** compact outlined controls for categories, members, and split methods.
- **Selected:** evergreen fill with on-primary text and a small selected-state label where useful.
- **Unselected:** paper fill, rule line, muted label.

### Cards / Containers

- **Corner style:** 16dp for paper, 24dp for hero surfaces.
- **Background:** paper on canvas; primary surfaces for high-emphasis summaries.
- **Border:** 1dp rule line on paper; no border needed on primary surfaces.
- **Internal padding:** 14–20dp depending on density.

### Inputs / Fields

- **Style:** paper or muted-paper fill, 1dp rule line, 10dp radius, 52dp minimum height.
- **Focus:** preserve the field silhouette while shifting emphasis to the evergreen border.
- **Error:** plain-language coral message beneath the relevant field or review block.

### Navigation

- **Style:** dark evergreen navigation bar with four labeled destinations and no icon placeholders.
- **Active:** primary evergreen or mint-on-dark label; inactive labels use muted sage.
- **Stack:** screens own their title block so content respects safe areas and avoids duplicate chrome.

### Signature Record Surface

The home position card and expense detail total use a large evergreen field with archive labels, one explanatory line, a rule, and a two-part status footer. This is the app’s memorable shared-money moment.

## Do's and Don'ts

### Do:

- **Do** use labels that explain what a number means before showing the number.
- **Do** keep the strongest accent for the primary action or the record that needs attention.
- **Do** use rules and spacing to separate ledger entries instead of nested containers.
- **Do** test light mode, dark mode, and larger Android system font sizes.
- **Do** let native Back, safe-area, keyboard, and touch-target behavior win over visual novelty.

### Don't:

- **Don't** add gradients, glass blur, or dashboard charts that do not explain shared money.
- **Don't** use emoji or placeholder glyphs as icons.
- **Don't** rely on color alone to communicate who owes or receives money.
- **Don't** put a second native header above a screen that already has a contextual title.
- **Don't** turn every row into a floating rounded card; use the ruled ledger rhythm.
