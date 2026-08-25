# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Students, traveling friends, roommates, couples, families, and small groups who need to record shared expenses and understand who owes whom.

## Product Purpose

SplitBill helps a group record shared expenses, split each expense among members, calculate balances and debts, and record settlements in one transparent mobile workspace.

## Positioning

The app turns a messy group ledger into an explainable flow: every balance is grounded in the expenses, participants, payers, and settlements that produced it.

## Operating Context

People use the app on Android phones during trips, meals, household routines, and group events. The core workflow is register or log in, create or join a group, add an expense, choose the payer and participants, review the split, inspect balances, and settle debts.

## Capabilities and Constraints

- Email and password authentication with Supabase Auth.
- Group creation, invite codes, membership, owner/member roles, and member management.
- Expense fields: title, amount, date, category, payer, participants, split method, notes, and a future receipt image.
- Split methods: equal, exact amount, and percentage.
- Group currency is fixed per group in the MVP; currency conversion, bank integrations, payment gateways, OCR, and web dashboards are out of scope.
- Supabase PostgreSQL, Row Level Security, Realtime, and Storage are the backend foundation.
- The app ships as a React Native Expo Android app and must respect Android back navigation, safe areas, keyboard insets, system font scaling, and reduced motion.

## Brand Commitments

- Product name: SplitBill.
- The interface should feel transparent, calm, practical, and trustworthy around shared money.
- Product language is concise and action-oriented; avoid financial jargon when plain language works.

## Evidence on Hand

- Product requirements: `PRD.md`.
- Supabase project and schema are configured in `supabase/`.
- Current working authentication, group, invite, expense, and split flows are in `src/`.
- No approved logo, illustration, photography, or external brand assets are available; do not fabricate claims or testimonials.

## Product Principles

- Make the next group action obvious.
- Show the reasoning behind every number.
- Reduce ambiguity before saving money data.
- Keep group activity visible without making the interface noisy.
- Treat errors, empty states, and slow network as part of the product.

## Accessibility & Inclusion

- Preserve native Android touch targets and system Back behavior.
- Support large system font scales without clipped or hidden actions.
- Maintain readable contrast and clear text labels for all controls; never rely on color alone to communicate debt or status.
