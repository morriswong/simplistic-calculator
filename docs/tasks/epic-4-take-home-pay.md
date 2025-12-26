# Epic 4: Take Home Pay Calculator

## Overview
Build a salary calculator that computes take-home pay after federal and state taxes, FICA, and Medicare deductions.

**Priority:** Medium - Advanced feature for full differentiation
**Estimated Effort:** 3 days
**Dependencies:** Epic 1 (Foundation) must be complete

## User Stories
- As an employee, I want to calculate my take-home pay after taxes
- As a job seeker, I want to compare salary offers in different states
- As a freelancer, I want to estimate my tax burden
- As a user, I want to see a breakdown of all deductions

## Acceptance Criteria
- [ ] US federal tax calculation (2025 brackets)
- [ ] State tax support (at least 10 major states initially)
- [ ] FICA and Medicare calculations
- [ ] Visual breakdown chart using fl_chart
- [ ] Annual, monthly, weekly, biweekly views
- [ ] Filing status selector (Single, Married, Head of Household)
- [ ] Standard/Itemized deduction toggle
- [ ] Disclaimer about estimates

---

## Tickets

### Ticket 4.1: Add Chart Dependency
**Type:** Setup
**Priority:** High
**Effort:** 10 minutes

**Tasks:**
- [ ] Update `pubspec.yaml`:
  ```yaml
  dependencies:
    fl_chart: ^0.66.0  # For salary breakdown chart
  ```
- [ ] Run `flutter pub get`

**Files:**
- Modify: `pubspec.yaml`

---

### Ticket 4.2: Create Tax Models
**Type:** New Feature
**Priority:** High
**Effort:** 2 hours

**Description:**
Define tax bracket data models and 2025 IRS tax tables.

**Tasks:**
- [ ] Create `lib/features/take_home_pay/models/tax_bracket.dart`
- [ ] Define models:
  ```dart
  enum FilingStatus { single, married, headOfHousehold }

  class TaxBracket {
    final double lowerLimit;
    final double upperLimit;
    final double rate;

    const TaxBracket({
      required this.lowerLimit,
      required this.upperLimit,
      required this.rate,
    });
  }

  class TaxRegion {
    final String name;
    final String code;
    final List<TaxBracket> getBrackets(FilingStatus status);
    final double getStandardDeduction(FilingStatus status);
  }
  ```
- [ ] Create `lib/features/take_home_pay/models/tax_tables.dart`
- [ ] Define 2025 federal tax brackets:
  - Single: $0-$11,600 (10%), $11,601-$47,150 (12%), $47,151-$100,525 (22%), etc.
  - Married: Different brackets
  - Head of Household: Different brackets
- [ ] Define standard deductions:
  - Single: $14,600
  - Married: $29,200
  - Head of Household: $21,900
- [ ] Define state tax data for 10 states:
  - California, New York, Texas, Florida, Illinois, Pennsylvania, Ohio, Georgia, North Carolina, Michigan
- [ ] Create FICA/Medicare constants:
  - Social Security: 6.2% up to $168,600
  - Medicare: 1.45% on all income
  - Additional Medicare: 0.9% over $200k (single) / $250k (married)

**Files:**
- Create: `lib/features/take_home_pay/models/tax_bracket.dart`
- Create: `lib/features/take_home_pay/models/tax_tables.dart`

**Acceptance:**
- Accurate 2025 tax data
- Federal and 10 state tax tables
- FICA/Medicare constants defined

**Reference:**
- IRS Publication 15-T (2025)
- State tax websites

---

### Ticket 4.3: Implement Tax Calculation Logic
**Type:** New Feature
**Priority:** Critical
**Effort:** 3 hours

**Description:**
Build the tax calculation engine.

**Tasks:**
- [ ] Create `lib/features/take_home_pay/models/tax_calculation.dart`
- [ ] Define TaxCalculation result class:
  ```dart
  class TaxCalculation {
    final double grossAnnual;
    final double federalTax;
    final double stateTax;
    final double socialSecurity;
    final double medicare;
    final double additionalMedicare;
    final double totalTax;
    final double netAnnual;

    double get netMonthly => netAnnual / 12;
    double get netWeekly => netAnnual / 52;
    double get netBiweekly => netAnnual / 26;

    const TaxCalculation({
      required this.grossAnnual,
      required this.federalTax,
      required this.stateTax,
      required this.socialSecurity,
      required this.medicare,
      required this.additionalMedicare,
      required this.totalTax,
      required this.netAnnual,
    });
  }
  ```
- [ ] Create `lib/features/take_home_pay/services/tax_calculator_service.dart`
- [ ] Implement calculation methods:
  ```dart
  class TaxCalculatorService {
    static TaxCalculation calculate({
      required double grossAnnual,
      required FilingStatus filingStatus,
      required TaxRegion federalRegion,
      required TaxRegion? stateRegion,
      required double standardDeduction,
    }) {
      // Calculate taxable income
      final taxableIncome = grossAnnual - standardDeduction;

      // Calculate federal tax (progressive brackets)
      final federalTax = _calculateProgressiveTax(
        taxableIncome,
        federalRegion.getBrackets(filingStatus),
      );

      // Calculate state tax
      final stateTax = stateRegion != null
          ? _calculateProgressiveTax(
              taxableIncome,
              stateRegion.getBrackets(filingStatus),
            )
          : 0.0;

      // Calculate FICA (Social Security)
      const ssRate = 0.062;
      const ssWageBase = 168600.0; // 2025 limit
      final socialSecurity = min(grossAnnual, ssWageBase) * ssRate;

      // Calculate Medicare
      const medicareRate = 0.0145;
      final medicare = grossAnnual * medicareRate;

      // Calculate Additional Medicare
      final additionalMedicareThreshold = filingStatus == FilingStatus.married ? 250000.0 : 200000.0;
      final additionalMedicare = grossAnnual > additionalMedicareThreshold
          ? (grossAnnual - additionalMedicareThreshold) * 0.009
          : 0.0;

      final totalTax = federalTax + stateTax + socialSecurity + medicare + additionalMedicare;
      final netAnnual = grossAnnual - totalTax;

      return TaxCalculation(
        grossAnnual: grossAnnual,
        federalTax: federalTax,
        stateTax: stateTax,
        socialSecurity: socialSecurity,
        medicare: medicare,
        additionalMedicare: additionalMedicare,
        totalTax: totalTax,
        netAnnual: netAnnual,
      );
    }

    static double _calculateProgressiveTax(double income, List<TaxBracket> brackets) {
      double tax = 0.0;
      double remaining = income;

      for (final bracket in brackets) {
        if (remaining <= 0) break;

        final bracketWidth = bracket.upperLimit - bracket.lowerLimit;
        final taxableInBracket = min(remaining, bracketWidth);
        tax += taxableInBracket * bracket.rate;
        remaining -= taxableInBracket;
      }

      return tax;
    }
  }
  ```

**Files:**
- Create: `lib/features/take_home_pay/models/tax_calculation.dart`
- Create: `lib/features/take_home_pay/services/tax_calculator_service.dart`

**Acceptance:**
- Tax calculation accurate
- Progressive brackets handled correctly
- FICA cap enforced
- Additional Medicare threshold correct

**Test Cases:**
- $50,000 single, no state tax: ~$38,000 net ✓
- $100,000 married, California: ~$72,000 net ✓
- $200,000 single, New York: ~$140,000 net ✓

---

### Ticket 4.4: Create State Management
**Type:** New Feature
**Priority:** High
**Effort:** 1 hour

**Tasks:**
- [ ] Create state class with form inputs
- [ ] Create provider with calculation trigger
- [ ] Handle pay frequency conversion (annual/monthly/weekly/biweekly)

**Files:**
- Create: `lib/features/take_home_pay/providers/tax_calculator_provider.dart`

---

### Ticket 4.5: Build UI with Breakdown Chart
**Type:** New Feature
**Priority:** High
**Effort:** 4 hours

**Description:**
Create the take-home pay calculator screen with visual breakdown.

**Tasks:**
- [ ] Create `lib/features/take_home_pay/presentation/take_home_pay_screen.dart`
- [ ] Implement form with inputs:
  - Gross salary (TextField with number keyboard)
  - Filing status (Dropdown)
  - State selector (Dropdown)
  - Pay frequency toggle (Annual/Monthly/Weekly/Biweekly)
  - Standard deduction checkbox
- [ ] Implement results display:
  - Large net pay amount
  - Pay frequency label
  - Breakdown list (Federal, State, FICA, Medicare, Total)
- [ ] Implement pie chart using fl_chart:
  ```dart
  PieChart(
    PieChartData(
      sections: [
        PieChartSectionData(
          value: calculation.netAnnual,
          title: 'Take Home',
          color: AppTheme.equalsButtonColor,
          radius: 100,
        ),
        PieChartSectionData(
          value: calculation.federalTax,
          title: 'Federal',
          color: Colors.red,
          radius: 100,
        ),
        PieChartSectionData(
          value: calculation.stateTax,
          title: 'State',
          color: Colors.orange,
          radius: 100,
        ),
        PieChartSectionData(
          value: calculation.socialSecurity + calculation.medicare,
          title: 'FICA/Medicare',
          color: Colors.blue,
          radius: 100,
        ),
      ],
    ),
  )
  ```
- [ ] Add disclaimer text: "Estimates only. Consult a tax professional for accurate calculations."
- [ ] Format currency with intl package
- [ ] Style to match app theme

**Files:**
- Create: `lib/features/take_home_pay/presentation/take_home_pay_screen.dart`

**Acceptance:**
- Form inputs work
- Calculation triggers on change
- Chart displays breakdown
- Currency formatted
- Disclaimer visible

---

### Ticket 4.6: Update Navigation
**Type:** Integration
**Priority:** High
**Effort:** 10 minutes

**Tasks:**
- [ ] Replace placeholder in `lib/main.dart`
- [ ] Import TakeHomePayScreen

**Files:**
- Modify: `lib/main.dart`

---

### Ticket 4.7: Testing & Validation
**Type:** Testing
**Priority:** High
**Effort:** 2 hours

**Test Cases:**
- [ ] Verify tax calculations against IRS examples
- [ ] Test all filing statuses
- [ ] Test all 10 states
- [ ] Test FICA cap enforcement ($168,600)
- [ ] Test Additional Medicare threshold
- [ ] Test pay frequency conversions
- [ ] Test edge cases (very low/high salaries)
- [ ] Test chart renders correctly
- [ ] Test state switching updates tax
- [ ] Verify disclaimer displayed

**Acceptance:**
- All calculations within 1% of IRS examples
- No crashes
- Chart displays correctly

---

### Ticket 4.8: Git Commit
**Type:** Documentation
**Priority:** Medium
**Effort:** 10 minutes

**Tasks:**
- [ ] Commit:
  ```bash
  git commit -m "Epic 4: Add take-home pay calculator

  - 2025 US federal tax brackets
  - 10 state tax implementations
  - FICA and Medicare calculations
  - Visual breakdown chart
  - Multiple pay frequency views

  Resolves Epic 4 tickets 4.1-4.7"
  ```

---

## Definition of Done

- [ ] All 8 tickets completed
- [ ] Tax calculation accurate
- [ ] 10 states supported
- [ ] Chart visualization working
- [ ] All tests passing
- [ ] Integrated into navigation
- [ ] Code committed

## Files Created
1. `lib/features/take_home_pay/models/tax_bracket.dart`
2. `lib/features/take_home_pay/models/tax_tables.dart`
3. `lib/features/take_home_pay/models/tax_calculation.dart`
4. `lib/features/take_home_pay/services/tax_calculator_service.dart`
5. `lib/features/take_home_pay/providers/tax_calculator_provider.dart`
6. `lib/features/take_home_pay/presentation/take_home_pay_screen.dart`

## Next Steps
Proceed to **Epic 5: A/B Testing Calculator**
