# Epic 2: Unit Converter Feature

## Overview
Build a comprehensive unit converter supporting 8 categories with 40+ units, enabling instant conversion between different measurement systems.

**Priority:** High - Part of MVP for App Store resubmission
**Estimated Effort:** 2 days
**Dependencies:** Epic 1 (Foundation) must be complete

## User Stories
- As a user, I want to convert between different units of measurement
- As a student, I want to convert metric to imperial units for homework
- As a traveler, I want to convert between different measurement systems
- As a user, I want instant conversion as I type numbers

## Acceptance Criteria
- [ ] 8 unit categories implemented (length, weight, temperature, volume, area, speed, time, data)
- [ ] 40+ units supported across all categories
- [ ] Instant bidirectional conversion
- [ ] Category selector to switch between unit types
- [ ] Clean UI matching purple gradient theme
- [ ] Input validation and error handling
- [ ] Conversion accuracy verified

---

## Tickets

### Ticket 2.1: Define Unit Models and Types
**Type:** New Feature
**Priority:** High
**Effort:** 1.5 hours

**Description:**
Create data models for unit categories and conversion logic.

**Tasks:**
- [ ] Create `lib/features/unit_converter/models/unit_category.dart`
- [ ] Define `UnitCategory` enum:
  ```dart
  enum UnitCategory {
    length,
    weight,
    temperature,
    volume,
    area,
    speed,
    time,
    data,
  }

  extension UnitCategoryExtension on UnitCategory {
    String get displayName {
      switch (this) {
        case UnitCategory.length: return 'Length';
        case UnitCategory.weight: return 'Weight';
        // ... etc
      }
    }
  }
  ```
- [ ] Create `lib/features/unit_converter/models/unit_type.dart`
- [ ] Define `UnitType` class:
  ```dart
  class UnitType {
    final String name;
    final String symbol;
    final UnitCategory category;
    final double toBaseRatio; // Conversion ratio to base unit

    const UnitType({
      required this.name,
      required this.symbol,
      required this.category,
      required this.toBaseRatio,
    });
  }
  ```
- [ ] Create unit constants for each category
- [ ] Add temperature special case handling (needs offset, not just ratio)

**Files:**
- Create: `lib/features/unit_converter/models/unit_category.dart`
- Create: `lib/features/unit_converter/models/unit_type.dart`

**Acceptance:**
- All unit categories defined
- Unit type model complete
- Ready for conversion logic

---

### Ticket 2.2: Implement Conversion Logic
**Type:** New Feature
**Priority:** High
**Effort:** 2 hours

**Description:**
Implement the conversion engine with support for all unit types including temperature special cases.

**Tasks:**
- [ ] Create `lib/features/unit_converter/models/unit_definitions.dart`
- [ ] Define all length units (meter as base):
  ```dart
  static const lengthUnits = [
    UnitType(name: 'Meter', symbol: 'm', category: UnitCategory.length, toBaseRatio: 1.0),
    UnitType(name: 'Kilometer', symbol: 'km', category: UnitCategory.length, toBaseRatio: 0.001),
    UnitType(name: 'Centimeter', symbol: 'cm', category: UnitCategory.length, toBaseRatio: 100.0),
    UnitType(name: 'Millimeter', symbol: 'mm', category: UnitCategory.length, toBaseRatio: 1000.0),
    UnitType(name: 'Mile', symbol: 'mi', category: UnitCategory.length, toBaseRatio: 0.000621371),
    UnitType(name: 'Yard', symbol: 'yd', category: UnitCategory.length, toBaseRatio: 1.09361),
    UnitType(name: 'Foot', symbol: 'ft', category: UnitCategory.length, toBaseRatio: 3.28084),
    UnitType(name: 'Inch', symbol: 'in', category: UnitCategory.length, toBaseRatio: 39.3701),
  ];
  ```
- [ ] Define weight units (kilogram as base)
- [ ] Define temperature units (Celsius as base, with special formulas)
- [ ] Define volume units (liter as base)
- [ ] Define area units (square meter as base)
- [ ] Define speed units (meter/second as base)
- [ ] Define time units (second as base)
- [ ] Define data units (byte as base)
- [ ] Create conversion utility class:
  ```dart
  class UnitConverter {
    static double convert({
      required double value,
      required UnitType from,
      required UnitType to,
    }) {
      if (from.category != to.category) {
        throw ArgumentError('Cannot convert between different categories');
      }

      // Special case for temperature
      if (from.category == UnitCategory.temperature) {
        return _convertTemperature(value, from, to);
      }

      // Standard conversion: value -> base unit -> target unit
      final inBaseUnit = value / from.toBaseRatio;
      return inBaseUnit * to.toBaseRatio;
    }

    static double _convertTemperature(double value, UnitType from, UnitType to) {
      // Convert to Celsius first
      double celsius = value;
      if (from.name == 'Fahrenheit') {
        celsius = (value - 32) * 5 / 9;
      } else if (from.name == 'Kelvin') {
        celsius = value - 273.15;
      }

      // Convert from Celsius to target
      if (to.name == 'Fahrenheit') {
        return celsius * 9 / 5 + 32;
      } else if (to.name == 'Kelvin') {
        return celsius + 273.15;
      }
      return celsius;
    }

    static List<UnitType> getUnitsForCategory(UnitCategory category) {
      // Return appropriate unit list based on category
    }
  }
  ```

**Files:**
- Create: `lib/features/unit_converter/models/unit_definitions.dart`

**Acceptance:**
- All 8 categories with 40+ units defined
- Conversion logic works correctly
- Temperature conversion handles offsets
- No conversion errors

**Test Cases:**
- Length: 1 meter = 3.28084 feet ✓
- Weight: 1 kg = 2.20462 pounds ✓
- Temperature: 32°F = 0°C = 273.15K ✓
- Volume: 1 liter = 0.264172 gallons ✓

---

### Ticket 2.3: Create Unit Converter State
**Type:** New Feature
**Priority:** High
**Effort:** 1 hour

**Description:**
Create state management for the unit converter using Riverpod.

**Tasks:**
- [ ] Create `lib/features/unit_converter/models/converter_state.dart`
- [ ] Define immutable state class:
  ```dart
  @immutable
  class UnitConverterState {
    final UnitCategory currentCategory;
    final UnitType fromUnit;
    final UnitType toUnit;
    final String fromValue;
    final String toValue;
    final String? error;

    const UnitConverterState({
      required this.currentCategory,
      required this.fromUnit,
      required this.toUnit,
      this.fromValue = '0',
      this.toValue = '0',
      this.error,
    });

    UnitConverterState copyWith({
      UnitCategory? currentCategory,
      UnitType? fromUnit,
      UnitType? toUnit,
      String? fromValue,
      String? toValue,
      String? error,
    }) => UnitConverterState(
      currentCategory: currentCategory ?? this.currentCategory,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      fromValue: fromValue ?? this.fromValue,
      toValue: toValue ?? this.toValue,
      error: error ?? this.error,
    );
  }
  ```
- [ ] Create `lib/features/unit_converter/providers/unit_converter_provider.dart`
- [ ] Implement `UnitConverterNotifier extends StateNotifier<UnitConverterState>`:
  ```dart
  class UnitConverterNotifier extends StateNotifier<UnitConverterState> {
    UnitConverterNotifier() : super(UnitConverterState(
      currentCategory: UnitCategory.length,
      fromUnit: UnitDefinitions.lengthUnits[0], // Meter
      toUnit: UnitDefinitions.lengthUnits[4],   // Mile
    ));

    void changeCategory(UnitCategory category) {
      final units = UnitConverter.getUnitsForCategory(category);
      state = state.copyWith(
        currentCategory: category,
        fromUnit: units[0],
        toUnit: units[1],
        fromValue: '0',
        toValue: '0',
        error: null,
      );
    }

    void setFromUnit(UnitType unit) {
      state = state.copyWith(fromUnit: unit);
      _performConversion();
    }

    void setToUnit(UnitType unit) {
      state = state.copyWith(toUnit: unit);
      _performConversion();
    }

    void updateFromValue(String value) {
      state = state.copyWith(fromValue: value, error: null);
      _performConversion();
    }

    void _performConversion() {
      try {
        final fromVal = double.tryParse(state.fromValue);
        if (fromVal == null || state.fromValue.isEmpty) {
          state = state.copyWith(toValue: '');
          return;
        }

        final result = UnitConverter.convert(
          value: fromVal,
          from: state.fromUnit,
          to: state.toUnit,
        );

        state = state.copyWith(
          toValue: _formatResult(result),
          error: null,
        );
      } catch (e) {
        state = state.copyWith(error: e.toString());
      }
    }

    String _formatResult(double value) {
      if (value.abs() < 0.01 || value.abs() > 1000000) {
        return value.toStringAsExponential(4);
      }
      // Round to 6 decimal places, remove trailing zeros
      return value.toStringAsFixed(6).replaceAll(RegExp(r'\.?0+$'), '');
    }
  }
  ```
- [ ] Create provider:
  ```dart
  final unitConverterProvider =
      StateNotifierProvider<UnitConverterNotifier, UnitConverterState>(
    (_) => UnitConverterNotifier(),
  );
  ```

**Files:**
- Create: `lib/features/unit_converter/models/converter_state.dart`
- Create: `lib/features/unit_converter/providers/unit_converter_provider.dart`

**Acceptance:**
- State management working
- Instant conversion on value change
- Error handling implemented
- Result formatting looks clean

---

### Ticket 2.4: Build Unit Converter UI
**Type:** New Feature
**Priority:** High
**Effort:** 3 hours

**Description:**
Create the user interface for the unit converter screen.

**Tasks:**
- [ ] Create `lib/features/unit_converter/presentation/unit_converter_screen.dart`
- [ ] Implement screen structure:
  ```dart
  class UnitConverterScreen extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final state = ref.watch(unitConverterProvider);

      return Container(
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Category selector dropdown
                _buildCategorySelector(ref, state),
                SizedBox(height: 24),
                // From conversion card
                _buildConversionCard(
                  context: context,
                  ref: ref,
                  label: 'From',
                  value: state.fromValue,
                  selectedUnit: state.fromUnit,
                  onValueChanged: (value) => ref.read(unitConverterProvider.notifier).updateFromValue(value),
                  onUnitChanged: (unit) => ref.read(unitConverterProvider.notifier).setFromUnit(unit),
                  units: UnitConverter.getUnitsForCategory(state.currentCategory),
                ),
                SizedBox(height: 16),
                // Swap button
                _buildSwapButton(ref),
                SizedBox(height: 16),
                // To conversion card
                _buildConversionCard(
                  context: context,
                  ref: ref,
                  label: 'To',
                  value: state.toValue,
                  selectedUnit: state.toUnit,
                  onValueChanged: null, // Read-only
                  onUnitChanged: (unit) => ref.read(unitConverterProvider.notifier).setToUnit(unit),
                  units: UnitConverter.getUnitsForCategory(state.currentCategory),
                ),
                if (state.error != null)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      state.error!,
                      style: TextStyle(color: AppTheme.errorTextColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }
  ```
- [ ] Implement category selector dropdown
- [ ] Implement conversion card widget with TextField and unit dropdown
- [ ] Implement swap button (IconButton with swap_vert icon)
- [ ] Add number keyboard type for input
- [ ] Add validation for numeric input
- [ ] Style to match calculator theme

**Files:**
- Create: `lib/features/unit_converter/presentation/unit_converter_screen.dart`

**Acceptance:**
- UI matches design (purple gradient, clean layout)
- Category selector changes unit options
- From field accepts numeric input
- To field displays result (read-only)
- Unit dropdowns work
- Swap button exchanges from/to units
- Responsive on different screen sizes

---

### Ticket 2.5: Create Conversion Card Widget
**Type:** New Feature
**Priority:** Medium
**Effort:** 1.5 hours

**Description:**
Create a reusable widget for displaying conversion input/output.

**Tasks:**
- [ ] Create `lib/features/unit_converter/presentation/widgets/conversion_card.dart`
- [ ] Implement card design:
  ```dart
  class ConversionCard extends StatelessWidget {
    final String label;
    final String value;
    final UnitType selectedUnit;
    final List<UnitType> units;
    final ValueChanged<String>? onValueChanged;
    final ValueChanged<UnitType> onUnitChanged;

    @override
    Widget build(BuildContext context) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.displaySecondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: TextEditingController(text: value),
                      readOnly: onValueChanged == null,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                      ),
                      onChanged: onValueChanged,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<UnitType>(
                      value: selectedUnit,
                      isExpanded: true,
                      items: units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text('${unit.name}\n(${unit.symbol})', style: TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (unit) {
                        if (unit != null) onUnitChanged(unit);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
  ```

**Files:**
- Create: `lib/features/unit_converter/presentation/widgets/conversion_card.dart`

**Acceptance:**
- Card displays value and unit selector
- TextField works for input
- Dropdown shows all units for category
- Styling consistent with app theme

---

### Ticket 2.6: Update Main Navigation
**Type:** Integration
**Priority:** High
**Effort:** 15 minutes

**Description:**
Replace placeholder screen with actual unit converter.

**Tasks:**
- [ ] Update `lib/main.dart`
- [ ] Import `UnitConverterScreen`:
  ```dart
  import 'features/unit_converter/presentation/unit_converter_screen.dart';
  ```
- [ ] Replace second tab placeholder with `UnitConverterScreen()`:
  ```dart
  IndexedStack(
    index: _currentIndex,
    children: [
      BasicCalculatorScreen(),
      UnitConverterScreen(), // ← Replace placeholder
      PlaceholderScreen(title: 'Currency Converter'),
      PlaceholderScreen(title: 'Take Home Pay'),
      PlaceholderScreen(title: 'A/B Testing'),
    ],
  )
  ```

**Files:**
- Modify: `lib/main.dart`

**Acceptance:**
- Unit tab shows unit converter
- Navigation works
- No compilation errors

---

### Ticket 2.7: Testing & Validation
**Type:** Testing
**Priority:** High
**Effort:** 2 hours

**Description:**
Comprehensive testing of unit converter functionality.

**Test Cases:**

**Length Conversions:**
- [ ] 1 meter = 3.28084 feet
- [ ] 1 kilometer = 0.621371 miles
- [ ] 1 inch = 2.54 centimeters
- [ ] 100 cm = 1 meter

**Weight Conversions:**
- [ ] 1 kilogram = 2.20462 pounds
- [ ] 1 pound = 16 ounces
- [ ] 1 ton = 1000 kilograms

**Temperature Conversions:**
- [ ] 0°C = 32°F = 273.15K
- [ ] 100°C = 212°F = 373.15K
- [ ] -40°C = -40°F = 233.15K

**Volume Conversions:**
- [ ] 1 liter = 0.264172 gallons
- [ ] 1 gallon = 3.78541 liters

**Area Conversions:**
- [ ] 1 sq meter = 10.7639 sq feet
- [ ] 1 acre = 4046.86 sq meters

**Speed Conversions:**
- [ ] 1 m/s = 3.6 km/h = 2.23694 mph
- [ ] 100 km/h = 27.7778 m/s

**Time Conversions:**
- [ ] 1 hour = 60 minutes = 3600 seconds
- [ ] 1 day = 24 hours

**Data Conversions:**
- [ ] 1 KB = 1024 bytes
- [ ] 1 MB = 1024 KB = 1,048,576 bytes
- [ ] 1 GB = 1024 MB

**UI Testing:**
- [ ] Category selector changes available units
- [ ] Typing in "From" field updates "To" field instantly
- [ ] Swap button exchanges from/to units
- [ ] Unit dropdown shows correct units for category
- [ ] Empty input shows empty result
- [ ] Invalid input handled gracefully
- [ ] Large numbers formatted correctly (scientific notation)
- [ ] Small numbers formatted correctly

**Edge Cases:**
- [ ] Zero values
- [ ] Negative values (where applicable)
- [ ] Very large numbers (1e100)
- [ ] Very small numbers (0.000001)
- [ ] Switching categories resets values
- [ ] State preserved when navigating away and back

**Acceptance:**
- All conversions accurate (within rounding tolerance)
- No crashes or errors
- UI responsive and intuitive
- Performance acceptable (instant conversion)

---

### Ticket 2.8: Documentation
**Type:** Documentation
**Priority:** Low
**Effort:** 30 minutes

**Description:**
Add code comments and documentation.

**Tasks:**
- [ ] Add class-level documentation to all widgets
- [ ] Add method documentation for conversion logic
- [ ] Document conversion formulas (especially temperature)
- [ ] Add inline comments for complex code

**Acceptance:**
- Code well-documented
- Conversion logic explained
- Future maintainers can understand code

---

### Ticket 2.9: Git Commit
**Type:** Documentation
**Priority:** Medium
**Effort:** 10 minutes

**Description:**
Commit unit converter feature.

**Tasks:**
- [ ] Stage changes:
  ```bash
  git add lib/features/unit_converter/
  git add lib/main.dart
  ```
- [ ] Commit:
  ```bash
  git commit -m "Epic 2: Add unit converter feature

  - Implemented 8 unit categories (length, weight, temp, volume, area, speed, time, data)
  - 40+ units with accurate conversion logic
  - Instant bidirectional conversion
  - Clean UI matching app theme
  - Comprehensive testing completed

  Resolves Epic 2 tickets 2.1-2.8"
  ```

**Acceptance:**
- Code committed to git
- Clean commit message

---

## Definition of Done

- [ ] All 9 tickets completed
- [ ] 8 unit categories implemented
- [ ] 40+ units supported
- [ ] Conversion logic accurate
- [ ] UI implemented and styled
- [ ] Instant conversion working
- [ ] All test cases passing
- [ ] No bugs or crashes
- [ ] Integrated into navigation
- [ ] Code documented
- [ ] Code committed to git
- [ ] Ready for Epic 3 (Currency Converter)

---

## Files Created

**New Files (8):**
1. `lib/features/unit_converter/models/unit_category.dart`
2. `lib/features/unit_converter/models/unit_type.dart`
3. `lib/features/unit_converter/models/unit_definitions.dart`
4. `lib/features/unit_converter/models/converter_state.dart`
5. `lib/features/unit_converter/providers/unit_converter_provider.dart`
6. `lib/features/unit_converter/presentation/unit_converter_screen.dart`
7. `lib/features/unit_converter/presentation/widgets/conversion_card.dart`
8. `docs/tasks/epic-2-unit-converter.md` (this file)

**Modified Files (1):**
1. `lib/main.dart` - Replace placeholder with UnitConverterScreen

---

## Next Steps

After completing Epic 2:
1. Proceed to **Epic 3: Currency Converter**
2. Test unit converter thoroughly
3. Consider user feedback for additional units if needed
