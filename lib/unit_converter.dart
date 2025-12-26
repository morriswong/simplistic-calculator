
enum UnitCategory { length, area, weight, volume }

enum Unit {
  // Length (Base: Meter)
  meters(UnitCategory.length, 'm', 1.0),
  centimeters(UnitCategory.length, 'cm', 0.01),
  millimeters(UnitCategory.length, 'mm', 0.001),
  kilometers(UnitCategory.length, 'km', 1000.0),
  feet(UnitCategory.length, 'ft', 0.3048),
  inches(UnitCategory.length, 'in', 0.0254),
  yards(UnitCategory.length, 'yd', 0.9144),
  miles(UnitCategory.length, 'mi', 1609.34),

  // Area (Base: Square Meter)
  squareMeters(UnitCategory.area, 'm²', 1.0),
  squareFeet(UnitCategory.area, 'ft²', 10.7639),
  squareCentimeters(UnitCategory.area, 'cm²', 10000),
  acres(UnitCategory.area, 'ac', 0.000247105),
  hectares(UnitCategory.area, 'ha', 0.0001),
  squareKilometers(UnitCategory.area, 'km²', 0.000001),

  // Weight (Base: Kilogram)
  kilograms(UnitCategory.weight, 'kg', 1.0),
  grams(UnitCategory.weight, 'g', 0.001),
  pounds(UnitCategory.weight, 'lb', 0.453592),
  ounces(UnitCategory.weight, 'oz', 0.0283495),
  metricTons(UnitCategory.weight, 't', 1000.0),

  // Volume (Base: Liter)
  liters(UnitCategory.volume, 'L', 1.0),
  milliliters(UnitCategory.volume, 'mL', 1000),
  gallons(UnitCategory.volume, 'gal', 0.264172),
  cups(UnitCategory.volume, 'cup', 4.22675),
  cubicMeters(UnitCategory.volume, 'm³', 0.001),
  cubicFeet(UnitCategory.volume, 'ft³', 0.0353147);

  const Unit(this.category, this.symbol, this.factorToModel);

  final UnitCategory category;
  final String symbol;
  final double factorToModel;
}

class UnitConverter {
  static double convert(double value, Unit from, Unit to) {
    if (from.category != to.category) {
      throw ArgumentError('Cannot convert between different unit categories');
    }
    // Convert to base unit
    final baseValue = value * from.factorToModel;
    // Convert from base unit to target
    return baseValue / to.factorToModel;
  }

  static List<Unit> getUnitsForCategory(UnitCategory category) {
    return Unit.values.where((u) => u.category == category).toList();
  }
}
