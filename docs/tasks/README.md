# Calculator Suite - Project Tasks

## Overview
Transform simplistic calculator into a multi-purpose utility app to address Apple's 4.3(a) spam rejection.

**Repository:** `/Users/morriswong/Documents/xcode/simplistic-calculator`
**Goal:** Create "Calculator Suite" with 5 specialized calculators showing genuine differentiation.

## Apple Rejection Context

**Guideline:** 4.3(a) - Design - Spam
**Issue:** App shares similar binary, metadata, and/or concept as other apps with only minor differences.
**Solution:** Add 4 unique calculator features to create genuine differentiation.

## Project Structure

### Epics (High-Level Features)
1. **Epic 1:** Project Restructuring & Foundation
2. **Epic 2:** Unit Converter Feature
3. **Epic 3:** Currency Converter Feature
4. **Epic 4:** Take Home Pay Calculator Feature
5. **Epic 5:** A/B Testing Calculator Feature
6. **Epic 6:** Polish & App Store Submission

### Task Files
- `epic-1-foundation.md` - Project restructuring and navigation
- `epic-2-unit-converter.md` - Unit converter implementation
- `epic-3-currency-converter.md` - Currency converter with API
- `epic-4-take-home-pay.md` - Salary/tax calculator
- `epic-5-ab-testing.md` - Statistical calculator
- `epic-6-polish-submission.md` - Testing and App Store

## Implementation Priority

### Phase 1: MVP for Resubmission (Week 1)
- ✅ Epic 1: Foundation
- ✅ Epic 2: Unit Converter
- ✅ Epic 3: Currency Converter

**Deliverable:** Resubmit to App Store with 3 calculators

### Phase 2: Complete Feature Set (Week 2)
- ✅ Epic 4: Take Home Pay
- ✅ Epic 5: A/B Testing

**Deliverable:** Full-featured app with 5 calculators

### Phase 3: Polish & Launch (Week 3)
- ✅ Epic 6: Polish & Submission

**Deliverable:** App Store approved

## Current File Structure

```
simplistic-calculator/
├── lib/
│   └── main.dart (555 lines - single file calculator)
├── ios/
├── macos/
├── docs/
│   └── tasks/          # ← You are here
│       ├── README.md
│       ├── epic-1-foundation.md
│       ├── epic-2-unit-converter.md
│       ├── epic-3-currency-converter.md
│       ├── epic-4-take-home-pay.md
│       ├── epic-5-ab-testing.md
│       └── epic-6-polish-submission.md
└── pubspec.yaml
```

## Target File Structure (After Epic 1)

```
simplistic-calculator/
├── lib/
│   ├── main.dart                    # Navigation shell
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   ├── widgets/
│   │   │   └── calculator_button.dart
│   │   └── utils/
│   │       └── formatters.dart
│   └── features/
│       ├── basic_calculator/
│       │   ├── presentation/
│       │   │   └── basic_calculator_screen.dart
│       │   ├── providers/
│       │   │   └── calculator_provider.dart
│       │   └── models/
│       │       ├── calculator_state.dart
│       │       └── button_definition.dart
│       ├── unit_converter/
│       ├── currency_converter/
│       ├── take_home_pay/
│       └── ab_testing/
└── docs/
    └── tasks/
```

## Quick Start

1. Review all epic files in `docs/tasks/`
2. Start with Epic 1 to set up foundation
3. Complete Epics 2-3 for minimum viable product
4. Test thoroughly before resubmission
5. Add Epics 4-5 while waiting for review
6. Complete Epic 6 for final release

## Key Metrics

- **Current State:** Single calculator app (rejected)
- **Target State:** 5-in-1 utility app
- **Differentiation:** Professional features (tax, statistics, live currency)
- **Timeline:** 2-3 weeks to full implementation
- **Resubmission:** After 1 week with 3 calculators

## Git Workflow

Suggested commit strategy:
- Commit after each completed ticket
- Use descriptive commit messages referencing ticket numbers
- Example: `git commit -m "Epic 1.2: Extract shared theme constants"`

## Contact

- **Developer:** Morris Wong
- **Email:** morriswch@gmail.com
- **App:** Simplistic Calculator → Calculator Suite
