# Epic 1: Project Restructuring & Foundation

## Overview
Refactor the single-file calculator app (555 lines in `lib/main.dart`) into a modular, feature-based architecture with bottom navigation to support multiple calculators.

**Priority:** Critical - Must complete first
**Estimated Effort:** 2-3 days
**Dependencies:** None

## User Stories
- As a developer, I want a modular codebase so that I can easily add new calculator features
- As a user, I want to navigate between different calculators via bottom navigation
- As a user, I want the basic calculator to continue working exactly as before

## Acceptance Criteria
- [ ] Existing basic calculator functionality preserved (no regressions)
- [ ] Feature-based folder structure created
- [ ] Shared components extracted to `core/` directory
- [ ] Bottom navigation with 5 tabs implemented
- [ ] App compiles without errors
- [ ] Purple gradient theme maintained

---

## Tickets

### Ticket 1.1: Create Feature-Based Folder Structure
**Type:** Setup
**Priority:** High
**Effort:** 1 hour

**Description:**
Create the new directory structure to support feature-based organization.

**Tasks:**
- [ ] Create `lib/core/` directory with subdirectories:
  - `lib/core/theme/`
  - `lib/core/widgets/`
  - `lib/core/utils/`
- [ ] Create `lib/features/` directory
- [ ] Create `lib/features/basic_calculator/` with subdirectories:
  - `lib/features/basic_calculator/presentation/`
  - `lib/features/basic_calculator/providers/`
  - `lib/features/basic_calculator/models/`
- [ ] Create placeholder directories for other features:
  - `lib/features/unit_converter/presentation/`
  - `lib/features/currency_converter/presentation/`
  - `lib/features/take_home_pay/presentation/`
  - `lib/features/ab_testing/presentation/`

**Acceptance:**
- All directories created successfully
- Directory structure matches specification
- No files yet, just structure

**Commands:**
```bash
cd lib
mkdir -p core/{theme,widgets,utils}
mkdir -p features/basic_calculator/{presentation,providers,models}
mkdir -p features/unit_converter/presentation
mkdir -p features/currency_converter/presentation
mkdir -p features/take_home_pay/presentation
mkdir -p features/ab_testing/presentation
```

---

### Ticket 1.2: Extract Shared Theme Constants
**Type:** Refactor
**Priority:** High
**Effort:** 1 hour

**Description:**
Centralize all color and theme constants to enable consistent theming across all calculators.

**Current State:**
Colors hardcoded in `lib/main.dart`:
- Line 356: `Color(0xFFF5F7FA)`, `Color(0xFFE8EAF6)` (gradient)
- Line 569-580: Button colors (white, orange, gray, green)

**Tasks:**
- [ ] Create `lib/core/theme/app_theme.dart`
- [ ] Define `AppTheme` class with static constants:
  ```dart
  class AppTheme {
    // Background gradient
    static const primaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF5F7FA), Color(0xFFE8EAF6)],
    );

    // Primary colors
    static const primaryColor = Color(0xFF673AB7);  // Purple
    static const accentColor = Color(0xFF512DA8);   // Deeper purple

    // Button colors
    static const numberButtonColor = Color(0xFFFFFFFF);
    static const numberButtonTextColor = Color(0xFF2C3E50);
    static const operatorButtonColor = Color(0xFFFF9500);
    static const operatorButtonTextColor = Color(0xFFFFFFFF);
    static const functionButtonColor = Color(0xFFD4D4D2);
    static const functionButtonTextColor = Color(0xFF2C3E50);
    static const equalsButtonColor = Color(0xFF34C759);
    static const equalsButtonTextColor = Color(0xFFFFFFFF);

    // Display colors
    static const displayTextColor = Color(0xFF2C3E50);
    static const displaySecondaryTextColor = Color(0xFF95A5A6);
    static const errorTextColor = Color(0xFFE74C3C);
  }
  ```
- [ ] Add documentation comments

**Files:**
- Create: `lib/core/theme/app_theme.dart`

**Acceptance:**
- All color constants centralized
- Theme file properly exports constants
- Documentation added

---

### Ticket 1.3: Extract Number Formatting Utility
**Type:** Refactor
**Priority:** Medium
**Effort:** 30 minutes

**Description:**
Move the `formatNumberWithCommas()` function (lines 59-96 in main.dart) to a shared utility file.

**Tasks:**
- [ ] Create `lib/core/utils/formatters.dart`
- [ ] Copy `formatNumberWithCommas()` function from main.dart
- [ ] Add documentation:
  ```dart
  /// Formats a number string with comma thousand separators.
  ///
  /// Handles both simple numbers and expressions with operators.
  /// Examples:
  ///   "1000" -> "1,000"
  ///   "1000.50" -> "1,000.50"
  ///   "1000+2000" -> "1,000+2,000"
  String formatNumberWithCommas(String value) { ... }
  ```
- [ ] Update `lib/main.dart` to import and use from utils

**Files:**
- Create: `lib/core/utils/formatters.dart`
- Modify: `lib/main.dart` (remove lines 59-96, add import)

**Acceptance:**
- Function extracted successfully
- Function works identically to original
- Proper documentation added
- App still compiles

---

### Ticket 1.4: Extract Calculator Button Widget
**Type:** Refactor
**Priority:** High
**Effort:** 1.5 hours

**Description:**
Extract the `CalcButton` widget (lines 550-611 in main.dart) to a shared component that uses theme constants.

**Tasks:**
- [ ] Create `lib/core/widgets/calculator_button.dart`
- [ ] Copy `CalcButton` widget class
- [ ] Import Riverpod, AutoSizeText dependencies
- [ ] Import `AppTheme` from `core/theme/app_theme.dart`
- [ ] Update button colors to use theme constants:
  ```dart
  switch (type) {
    case CalcButtonType.number:
      backgroundColor = AppTheme.numberButtonColor;
      textColor = AppTheme.numberButtonTextColor;
    case CalcButtonType.operator:
      backgroundColor = AppTheme.operatorButtonColor;
      textColor = AppTheme.operatorButtonTextColor;
    // ... etc
  }
  ```
- [ ] Add widget documentation
- [ ] Export widget

**Files:**
- Create: `lib/core/widgets/calculator_button.dart`
- Modify: `lib/main.dart` (remove widget, add import)

**Acceptance:**
- Button widget extracted to shared component
- Button uses theme constants (no hardcoded colors)
- Visual appearance unchanged
- Button works with Riverpod providers
- Proper imports and exports

---

### Ticket 1.5: Extract Calculator State & Engine
**Type:** Refactor
**Priority:** High
**Effort:** 2 hours

**Description:**
Move calculator state management and business logic to the feature folder.

**Current State:**
- Lines 27-55: `CalculatorState` class
- Line 57: `CalculatorEngineMode` enum
- Lines 98-188: `CalculatorEngine` class
- Lines 190-193: `calculatorStateProvider`

**Tasks:**
- [ ] Create `lib/features/basic_calculator/models/calculator_state.dart`
- [ ] Move `CalculatorState` class (with `@immutable` annotation)
- [ ] Move `CalculatorEngineMode` enum
- [ ] Add imports: `package:flutter/foundation.dart` for `@immutable`
- [ ] Create `lib/features/basic_calculator/providers/calculator_provider.dart`
- [ ] Move `CalculatorEngine` class
- [ ] Move `calculatorStateProvider`
- [ ] Add imports:
  - `package:flutter_riverpod/flutter_riverpod.dart`
  - `package:math_expressions/math_expressions.dart`
  - `../models/calculator_state.dart`
  - `package:flutter/material.dart` (for `Characters`)
- [ ] Import formatter: `package:simplistic_calculator/core/utils/formatters.dart`
- [ ] Update `lib/main.dart` to import from new locations
- [ ] Test calculator still works

**Files:**
- Create: `lib/features/basic_calculator/models/calculator_state.dart`
- Create: `lib/features/basic_calculator/providers/calculator_provider.dart`
- Modify: `lib/main.dart` (remove classes, add imports)

**Acceptance:**
- State and engine properly separated into feature folder
- Calculator functionality unchanged
- All imports working correctly
- App compiles successfully
- No runtime errors

---

### Ticket 1.6: Extract Button Definitions
**Type:** Refactor
**Priority:** Medium
**Effort:** 1 hour

**Description:**
Move button-related models to the feature's model directory.

**Current State:**
- Lines 201-213: `ButtonDefinition` class
- Line 215: `CalcButtonType` enum
- Lines 217-326: `buttonDefinitions` list
- Line 548: `CalculatorEngineCallback` typedef

**Tasks:**
- [ ] Create `lib/features/basic_calculator/models/button_definition.dart`
- [ ] Move `ButtonDefinition` class
- [ ] Move `CalcButtonType` enum
- [ ] Move `buttonDefinitions` list
- [ ] Move `CalculatorEngineCallback` typedef
- [ ] Import `calculator_provider.dart` for `CalculatorEngine` type
- [ ] Update `lib/main.dart` to import from new location
- [ ] Test buttons still work

**Files:**
- Create: `lib/features/basic_calculator/models/button_definition.dart`
- Modify: `lib/main.dart` (remove definitions, add import)

**Acceptance:**
- Button definitions in feature-specific model file
- All 17 button definitions preserved
- Button functionality unchanged
- No compilation errors

---

### Ticket 1.7: Extract Calculator Mode Provider
**Type:** Refactor
**Priority:** Low
**Effort:** 30 minutes

**Description:**
Move the calculator mode (standard/scientific) state to the provider file.

**Current State:**
- Line 195: `CalculatorMode` enum
- Line 197: `calculatorModeProvider`

**Tasks:**
- [ ] Move `CalculatorMode` enum to `calculator_provider.dart`
- [ ] Move `calculatorModeProvider` to `calculator_provider.dart`
- [ ] Update import in main.dart

**Files:**
- Modify: `lib/features/basic_calculator/providers/calculator_provider.dart`
- Modify: `lib/main.dart`

**Acceptance:**
- Mode provider in feature folder
- Standard/Scientific toggle still works

---

### Ticket 1.8: Create Basic Calculator Screen
**Type:** Refactor
**Priority:** High
**Effort:** 2.5 hours

**Description:**
Extract the entire calculator UI into its own screen component.

**Current State:**
Lines 328-546 in main.dart contain the calculator UI

**Tasks:**
- [ ] Create `lib/features/basic_calculator/presentation/basic_calculator_screen.dart`
- [ ] Create `BasicCalculatorScreen` as `ConsumerWidget`
- [ ] Move calculator UI code:
  - Mode selector popup menu (lines 362-418)
  - LayoutGrid with areas (lines 420-541)
  - Display area (lines 433-492)
  - Button placements (lines 493-502)
  - History display (lines 503-537)
- [ ] Import required packages:
  - `package:flutter/material.dart`
  - `package:flutter_riverpod/flutter_riverpod.dart`
  - `package:auto_size_text/auto_size_text.dart`
  - `package:flutter_layout_grid/flutter_layout_grid.dart`
- [ ] Import from project:
  - `core/theme/app_theme.dart`
  - `core/widgets/calculator_button.dart`
  - `core/utils/formatters.dart`
  - `../providers/calculator_provider.dart`
  - `../models/button_definition.dart`
- [ ] Wrap in `Scaffold` with gradient background:
  ```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        child: Column(
          children: [
            // Mode selector
            // Calculator grid
          ],
        ),
      ),
    );
  }
  ```
- [ ] Test calculator screen in isolation

**Files:**
- Create: `lib/features/basic_calculator/presentation/basic_calculator_screen.dart`
- Modify: `lib/main.dart` (will use in next ticket)

**Acceptance:**
- Calculator screen in its own file
- All calculator UI preserved
- Display, buttons, history all functional
- Scientific/Standard mode toggle working
- Purple gradient background maintained

---

### Ticket 1.9: Implement Bottom Navigation Shell
**Type:** New Feature
**Priority:** Critical
**Effort:** 3 hours

**Description:**
Transform main.dart into a navigation shell with bottom navigation bar and tab switching.

**Tasks:**
- [ ] Simplify `lib/main.dart` to be navigation shell only
- [ ] Keep `main()` function with window sizing
- [ ] Create `CalculatorApp` as StatefulWidget to manage navigation
- [ ] Implement `Scaffold` with `BottomNavigationBar`:
  ```dart
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: _currentIndex,
    onTap: (index) => setState(() => _currentIndex = index),
    type: BottomNavigationBarType.fixed,
    selectedItemColor: AppTheme.primaryColor,
    unselectedItemColor: Colors.grey,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.calculate),
        label: 'Calculator',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.swap_horiz),
        label: 'Unit',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.attach_money),
        label: 'Currency',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_balance),
        label: 'Salary',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.science),
        label: 'A/B Test',
      ),
    ],
  )
  ```
- [ ] Implement tab switching with `IndexedStack`:
  ```dart
  body: IndexedStack(
    index: _currentIndex,
    children: [
      BasicCalculatorScreen(),
      PlaceholderScreen(title: 'Unit Converter'),
      PlaceholderScreen(title: 'Currency Converter'),
      PlaceholderScreen(title: 'Take Home Pay'),
      PlaceholderScreen(title: 'A/B Testing'),
    ],
  )
  ```
- [ ] Create simple `PlaceholderScreen` widget for tabs 2-5:
  ```dart
  class PlaceholderScreen extends StatelessWidget {
    final String title;
    const PlaceholderScreen({required this.title});

    @override
    Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: Text(
            '$title\nComing Soon',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, color: AppTheme.displayTextColor),
          ),
        ),
      );
    }
  }
  ```
- [ ] Import `BasicCalculatorScreen`
- [ ] Test navigation between all 5 tabs
- [ ] Verify state is preserved when switching tabs

**Files:**
- Modify: `lib/main.dart` (major refactor to ~100 lines)

**Acceptance:**
- Bottom navigation bar visible with 5 tabs
- Icons and labels correct
- Tapping tabs switches screens
- Active tab highlighted in purple
- Calculator tab shows full functionality
- Other tabs show "Coming Soon" placeholders
- Purple gradient background on all screens
- Smooth transitions
- Calculator state preserved when switching away and back

---

### Ticket 1.10: Update App Theme to Use ThemeData
**Type:** Enhancement
**Priority:** Low
**Effort:** 30 minutes

**Description:**
Update MaterialApp to use a proper ThemeData that incorporates our color scheme.

**Tasks:**
- [ ] Add `AppTheme.buildThemeData()` method in `app_theme.dart`:
  ```dart
  static ThemeData buildThemeData() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
    );
  }
  ```
- [ ] Update `MaterialApp` in main.dart:
  ```dart
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.buildThemeData(),
    home: // navigation scaffold
  )
  ```

**Files:**
- Modify: `lib/core/theme/app_theme.dart`
- Modify: `lib/main.dart`

**Acceptance:**
- Consistent theming across app
- Bottom navigation uses theme colors
- Purple accent maintained

---

### Ticket 1.11: Clean Up and Verify
**Type:** Testing
**Priority:** High
**Effort:** 1 hour

**Description:**
Final cleanup, remove unused code, verify everything works.

**Tasks:**
- [ ] Remove any unused imports in all files
- [ ] Verify no duplicate code exists
- [ ] Check all files have proper copyright/license headers if needed
- [ ] Run `flutter analyze` and fix any issues
- [ ] Run `flutter pub get`
- [ ] Verify app builds: `flutter build ios --debug`

**Acceptance:**
- No analyzer warnings
- No unused imports
- App builds successfully

---

### Ticket 1.12: Integration Testing
**Type:** Testing
**Priority:** Critical
**Effort:** 2 hours

**Description:**
Comprehensive testing of refactored calculator and new navigation.

**Test Cases:**

**Calculator Functionality:**
- [ ] Test number input: 123456
- [ ] Test decimal: 123.456
- [ ] Test basic operations:
  - [ ] Addition: 5+3 = 8
  - [ ] Subtraction: 10-4 = 6
  - [ ] Multiplication: 7×8 = 56
  - [ ] Division: 20÷4 = 5
- [ ] Test scientific functions (Scientific mode):
  - [ ] sin(30) ≈ -0.988
  - [ ] sqrt(16) = 4
  - [ ] 2^3 = 8
- [ ] Test backspace button
- [ ] Test clear (AC) button
- [ ] Test continuing with result (5+3=8, then ×2=16)
- [ ] Test history display (shows last 3 calculations)
- [ ] Test error handling (divide by zero, invalid expression)
- [ ] Test number formatting (1000 displays as 1,000)
- [ ] Test last equation display when in result mode

**Navigation:**
- [ ] Test switching to each tab (1-5)
- [ ] Test returning to calculator tab
- [ ] Verify calculator state preserved after switching tabs
- [ ] Test active tab highlighting
- [ ] Test placeholder screens show correct titles

**Visual:**
- [ ] Purple gradient background on all screens
- [ ] Button colors correct (white, orange, gray, green)
- [ ] Text readable and properly sized
- [ ] Layout responsive on different screen sizes
- [ ] Mode selector (Standard/Scientific) works

**Platforms:**
- [ ] Test on iOS simulator (iPhone 15)
- [ ] Test on different screen sizes (iPhone SE, iPhone 15 Pro Max)
- [ ] Test on iPad (if supporting iPad)

**Acceptance:**
- All calculator features work identically to original
- No regressions in functionality
- Navigation smooth and intuitive
- No crashes or errors
- Performance acceptable (no lag)

---

### Ticket 1.13: Git Commit
**Type:** Documentation
**Priority:** Medium
**Effort:** 15 minutes

**Description:**
Commit the refactored foundation code.

**Tasks:**
- [ ] Review git status
- [ ] Stage all new and modified files:
  ```bash
  git add lib/
  git add docs/tasks/
  ```
- [ ] Commit with descriptive message:
  ```bash
  git commit -m "Epic 1: Refactor to feature-based architecture with bottom navigation

  - Extracted calculator to features/basic_calculator/
  - Created shared components in core/
  - Implemented 5-tab bottom navigation
  - Added placeholder screens for future calculators
  - Preserved all existing calculator functionality

  Resolves Epic 1 tickets 1.1-1.12"
  ```

**Acceptance:**
- Clean commit history
- Meaningful commit message
- Foundation work preserved in git

---

## Definition of Done

- [ ] All 13 tickets completed
- [ ] Feature-based folder structure implemented
- [ ] Shared components extracted (theme, button, formatter)
- [ ] Calculator state and logic in feature folder
- [ ] Bottom navigation working with 5 tabs
- [ ] Basic calculator preserved and fully functional
- [ ] Placeholder screens for 4 future calculators
- [ ] No regressions in calculator functionality
- [ ] Code compiles without errors or warnings
- [ ] Integration tests passing
- [ ] Code committed to git
- [ ] Ready to add new calculator features (Epic 2+)

---

## Files Changed

**New Files (10):**
1. `lib/core/theme/app_theme.dart`
2. `lib/core/widgets/calculator_button.dart`
3. `lib/core/utils/formatters.dart`
4. `lib/features/basic_calculator/models/calculator_state.dart`
5. `lib/features/basic_calculator/models/button_definition.dart`
6. `lib/features/basic_calculator/providers/calculator_provider.dart`
7. `lib/features/basic_calculator/presentation/basic_calculator_screen.dart`
8. `docs/tasks/README.md`
9. `docs/tasks/epic-1-foundation.md` (this file)
10. Additional epic files (2-6)

**Modified Files (1):**
1. `lib/main.dart` - Reduced from 555 lines to ~100 lines (navigation shell only)

**Line Count Change:**
- Before: 555 lines in main.dart
- After: ~800 lines across 10 files (better organization)

---

## Rollback Plan

If critical issues occur:
1. Git revert to last working commit
2. Alternatively, restore from backup: `git stash` changes
3. Review specific ticket that caused issue
4. Fix and retry

**Backup Strategy:**
```bash
# Before starting Epic 1
git checkout -b epic-1-foundation
git commit -am "Backup before Epic 1"
```

---

## Next Steps

After completing Epic 1:
1. Proceed to **Epic 2: Unit Converter**
2. Continue building features sequentially
3. Test each epic thoroughly before moving to next
