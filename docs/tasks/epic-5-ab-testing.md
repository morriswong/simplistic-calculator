# Epic 5: A/B Testing Sample Size Calculator

## Overview
Build a statistical calculator to determine required sample sizes for A/B tests based on baseline conversion rate, minimum detectable effect, confidence level, and statistical power.

**Priority:** Medium - Advanced feature for professional users
**Estimated Effort:** 2 days
**Dependencies:** Epic 1 (Foundation) must be complete

## User Stories
- As a marketer, I want to know how many users I need for an A/B test
- As a product manager, I want to calculate sample sizes for experiments
- As a data analyst, I want to understand statistical power requirements
- As a user, I want educational explanations of statistical terms

## Acceptance Criteria
- [ ] Sample size calculation based on statistical formula
- [ ] Input fields for baseline rate, MDE, confidence, power
- [ ] Presets for common scenarios
- [ ] Educational tooltips explaining terms
- [ ] Result display with per-variant sample size
- [ ] Validation of input ranges
- [ ] Clean UI matching app theme

---

## Tickets

### Ticket 5.1: Create Statistical Models
**Type:** New Feature
**Priority:** High
**Effort:** 1 hour

**Description:**
Define models for A/B test parameters and results.

**Tasks:**
- [ ] Create `lib/features/ab_testing/models/ab_test_parameters.dart`
- [ ] Define models:
  ```dart
  class ABTestParameters {
    final double baselineRate;        // 0.0 to 1.0 (e.g., 0.05 = 5%)
    final double minDetectableEffect; // 0.0 to 1.0 (e.g., 0.10 = 10% relative lift)
    final double confidenceLevel;     // 0.0 to 1.0 (e.g., 0.95 = 95%)
    final double statisticalPower;    // 0.0 to 1.0 (e.g., 0.80 = 80%)

    const ABTestParameters({
      required this.baselineRate,
      required this.minDetectableEffect,
      required this.confidenceLevel,
      required this.statisticalPower,
    });

    // Validation
    bool get isValid =>
        baselineRate > 0 && baselineRate < 1 &&
        minDetectableEffect > 0 && minDetectableEffect < 1 &&
        confidenceLevel > 0.5 && confidenceLevel < 1 &&
        statisticalPower > 0.5 && statisticalPower < 1;
  }

  class ABTestResult {
    final int sampleSizePerVariant;
    final int totalSampleSize;
    final double expectedConversionRate;
    final ABTestParameters parameters;

    const ABTestResult({
      required this.sampleSizePerVariant,
      required this.totalSampleSize,
      required this.expectedConversionRate,
      required this.parameters,
    });
  }

  // Presets
  class ABTestPresets {
    static const lowBaseline = ABTestParameters(
      baselineRate: 0.02,
      minDetectableEffect: 0.20,  // 20% relative lift
      confidenceLevel: 0.95,
      statisticalPower: 0.80,
    );

    static const mediumBaseline = ABTestParameters(
      baselineRate: 0.05,
      minDetectableEffect: 0.10,
      confidenceLevel: 0.95,
      statisticalPower: 0.80,
    );

    static const highBaseline = ABTestParameters(
      baselineRate: 0.15,
      minDetectableEffect: 0.10,
      confidenceLevel: 0.95,
      statisticalPower: 0.80,
    );
  }
  ```

**Files:**
- Create: `lib/features/ab_testing/models/ab_test_parameters.dart`

**Acceptance:**
- Models defined
- Validation logic included
- Presets available

---

### Ticket 5.2: Implement Sample Size Calculation
**Type:** New Feature
**Priority:** Critical
**Effort:** 2.5 hours

**Description:**
Implement the statistical formula for calculating sample size.

**Tasks:**
- [ ] Create `lib/features/ab_testing/services/ab_test_calculator.dart`
- [ ] Implement calculation:
  ```dart
  import 'dart:math';

  class ABTestCalculator {
    /// Calculates required sample size per variant for A/B test
    ///
    /// Formula: n = (Z_α/2 + Z_β)² × (p₁(1-p₁) + p₂(1-p₂)) / (p₁ - p₂)²
    ///
    /// Where:
    /// - Z_α/2: Z-score for confidence level (two-tailed)
    /// - Z_β: Z-score for power (one-tailed)
    /// - p₁: Baseline conversion rate
    /// - p₂: Expected conversion rate (p₁ × (1 + MDE))
    /// - n: Sample size per variant
    static ABTestResult calculateSampleSize(ABTestParameters params) {
      // Get Z-scores
      final zAlpha = _getZScore(params.confidenceLevel, twoTailed: true);
      final zBeta = _getZScore(params.statisticalPower, twoTailed: false);

      // Calculate expected rates
      final p1 = params.baselineRate;
      final p2 = p1 * (1 + params.minDetectableEffect);

      // Calculate pooled standard deviation
      final sd1 = sqrt(p1 * (1 - p1));
      final sd2 = sqrt(p2 * (1 - p2));

      // Calculate sample size
      final numerator = pow(zAlpha + zBeta, 2) * (pow(sd1, 2) + pow(sd2, 2));
      final denominator = pow(p1 - p2, 2);

      final sampleSizePerVariant = (numerator / denominator).ceil();
      final totalSampleSize = sampleSizePerVariant * 2; // Control + Variant

      return ABTestResult(
        sampleSizePerVariant: sampleSizePerVariant,
        totalSampleSize: totalSampleSize,
        expectedConversionRate: p2,
        parameters: params,
      );
    }

    /// Get Z-score for given confidence level
    ///
    /// Common values:
    /// - 90% confidence (two-tailed): 1.645
    /// - 95% confidence (two-tailed): 1.960
    /// - 99% confidence (two-tailed): 2.576
    /// - 80% power (one-tailed): 0.842
    /// - 90% power (one-tailed): 1.282
    static double _getZScore(double probability, {required bool twoTailed}) {
      // For two-tailed, use (1 + confidence) / 2
      final p = twoTailed ? (1 + probability) / 2 : probability;

      // Approximate inverse normal CDF (good for common values)
      // More accurate: use statistics package or lookup table
      if (p >= 0.9999) return 3.891;
      if (p >= 0.999) return 3.291;
      if (p >= 0.995) return 2.807;
      if (p >= 0.99) return 2.576;
      if (p >= 0.975) return 1.960;
      if (p >= 0.95) return 1.645;
      if (p >= 0.90) return 1.282;
      if (p >= 0.85) return 1.036;
      if (p >= 0.80) return 0.842;

      // Fallback approximation (Beasley-Springer-Moro algorithm simplified)
      return _approximateInverseNormalCDF(p);
    }

    static double _approximateInverseNormalCDF(double p) {
      // Simple approximation for demonstration
      // For production, use statistics package
      final c0 = 2.515517;
      final c1 = 0.802853;
      final c2 = 0.010328;
      final d1 = 1.432788;
      final d2 = 0.189269;
      final d3 = 0.001308;

      final t = sqrt(-2 * log(1 - p));
      return t - (c0 + c1 * t + c2 * t * t) /
          (1 + d1 * t + d2 * t * t + d3 * t * t * t);
    }
  }
  ```
- [ ] Add comprehensive documentation
- [ ] Add formula reference comments

**Files:**
- Create: `lib/features/ab_testing/services/ab_test_calculator.dart`

**Acceptance:**
- Sample size calculation accurate
- Z-score lookup correct for common values
- Formula documented

**Test Cases:**
- Baseline 5%, MDE 10%, 95% conf, 80% power: ~15,600 per variant ✓
- Baseline 10%, MDE 20%, 95% conf, 80% power: ~3,800 per variant ✓
- Baseline 2%, MDE 25%, 90% conf, 80% power: ~4,200 per variant ✓

**References:**
- Evan Miller's sample size calculator
- "Statistical Power Analysis" by Jacob Cohen

---

### Ticket 5.3: Create State Management
**Type:** New Feature
**Priority:** High
**Effort:** 1 hour

**Tasks:**
- [ ] Create state class
- [ ] Create provider with calculation trigger
- [ ] Handle preset loading
- [ ] Validate inputs

**Files:**
- Create: `lib/features/ab_testing/providers/ab_test_provider.dart`

**Acceptance:**
- State management working
- Presets loadable
- Input validation functional

---

### Ticket 5.4: Build A/B Testing UI
**Type:** New Feature
**Priority:** High
**Effort:** 3 hours

**Description:**
Create the A/B testing calculator screen with educational elements.

**Tasks:**
- [ ] Create `lib/features/ab_testing/presentation/ab_testing_screen.dart`
- [ ] Implement form inputs:
  - Baseline conversion rate (TextField with % symbol, 0-100)
  - Minimum detectable effect (Slider, 5%-50%)
  - Confidence level (Dropdown: 90%, 95%, 99%)
  - Statistical power (Dropdown: 70%, 80%, 90%)
- [ ] Add preset buttons (Low/Medium/High baseline scenarios)
- [ ] Implement result display:
  - Large sample size number
  - "per variant" label
  - Total sample size
  - Expected conversion rate
- [ ] Add educational info cards:
  - Baseline Rate: "Current conversion rate of your control"
  - MDE: "Smallest improvement worth detecting"
  - Confidence: "Probability results aren't due to chance"
  - Power: "Probability of detecting a true effect"
- [ ] Add tooltips with IconButton info icons
- [ ] Add example interpretation:
  - "You need X users in control and X users in variant (Y total)"
  - "This will detect a lift from A% to B% with 95% confidence"
- [ ] Style to match app theme

**Files:**
- Create: `lib/features/ab_testing/presentation/ab_testing_screen.dart`

**Acceptance:**
- Form inputs work
- Sliders and dropdowns functional
- Presets load parameters
- Result displays clearly
- Educational content helpful
- Example interpretation clear

---

### Ticket 5.5: Add Validation & Error Handling
**Type:** Enhancement
**Priority:** Medium
**Effort:** 1 hour

**Tasks:**
- [ ] Validate baseline rate (0.1% - 99%)
- [ ] Validate MDE (must be achievable given baseline)
- [ ] Show warnings for unrealistic inputs:
  - Very low baseline + small MDE = huge sample size
  - Very high confidence + high power = huge sample size
- [ ] Show "Sample size too large (>1M)" warning if needed
- [ ] Disable calculate button if inputs invalid

**Acceptance:**
- Input validation working
- Helpful warnings displayed
- Edge cases handled

---

### Ticket 5.6: Update Navigation
**Type:** Integration
**Priority:** High
**Effort:** 10 minutes

**Tasks:**
- [ ] Replace placeholder in `lib/main.dart`
- [ ] Import ABTestingScreen

**Files:**
- Modify: `lib/main.dart`

**Acceptance:**
- A/B Testing tab shows calculator
- Navigation works

---

### Ticket 5.7: Testing & Validation
**Type:** Testing
**Priority:** High
**Effort:** 1.5 hours

**Test Cases:**
- [ ] Verify calculations against online calculators (Evan Miller, Optimizely)
- [ ] Test all presets
- [ ] Test confidence level changes
- [ ] Test power level changes
- [ ] Test extreme values (very low/high baseline)
- [ ] Test input validation
- [ ] Test tooltips display
- [ ] Test sliders work smoothly

**Acceptance:**
- Calculations match reference calculators (±5%)
- All inputs validated
- UI smooth and responsive

---

### Ticket 5.8: Git Commit
**Type:** Documentation
**Priority:** Medium
**Effort:** 10 minutes

**Tasks:**
- [ ] Commit:
  ```bash
  git commit -m "Epic 5: Add A/B testing sample size calculator

  - Statistical sample size calculation
  - Confidence and power level settings
  - Educational tooltips
  - Preset scenarios
  - Input validation

  Resolves Epic 5 tickets 5.1-5.7"
  ```

---

## Definition of Done

- [ ] All 8 tickets completed
- [ ] Statistical formula implemented correctly
- [ ] UI with educational content complete
- [ ] Presets working
- [ ] Validation implemented
- [ ] All tests passing
- [ ] Integrated into navigation
- [ ] Code committed

## Files Created
1. `lib/features/ab_testing/models/ab_test_parameters.dart`
2. `lib/features/ab_testing/services/ab_test_calculator.dart`
3. `lib/features/ab_testing/providers/ab_test_provider.dart`
4. `lib/features/ab_testing/presentation/ab_testing_screen.dart`

## Next Steps
Proceed to **Epic 6: Polish & App Store Submission** for final testing and release preparation.
