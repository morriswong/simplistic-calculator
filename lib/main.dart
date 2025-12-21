// Copyright 2022 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:window_size/window_size.dart';

import 'unit_converter.dart';

void main() {
  if (!kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Simplistic Calculator');
    setWindowMinSize(const Size(600, 500));
  }

  runApp(const ProviderScope(child: CalculatorApp()));
}

@immutable
class CalculatorState {
  const CalculatorState({
    required this.buffer,
    required this.calcHistory,
    required this.mode,
    required this.error,
    this.lastEquation = '',
    this.sourceUnit = Unit.meters,
    this.targetUnit = Unit.feet,
  });

  final String buffer;
  final List<String> calcHistory;
  final CalculatorEngineMode mode;
  final String error;
  final String lastEquation;
  final Unit sourceUnit;
  final Unit targetUnit;

  CalculatorState copyWith({
    String? buffer,
    List<String>? calcHistory,
    CalculatorEngineMode? mode,
    String? error,
    String? lastEquation,
    Unit? sourceUnit,
    Unit? targetUnit,
  }) => CalculatorState(
    buffer: buffer ?? this.buffer,
    calcHistory: calcHistory ?? this.calcHistory,
    mode: mode ?? this.mode,
    error: error ?? this.error,
    lastEquation: lastEquation ?? this.lastEquation,
    sourceUnit: sourceUnit ?? this.sourceUnit,
    targetUnit: targetUnit ?? this.targetUnit,
  );
}

enum CalculatorEngineMode { input, result }

String formatNumberWithCommas(String value) {
  // Remove existing commas first
  final cleanValue = value.replaceAll(',', '');

  // Check if it's a simple number
  final number = double.tryParse(cleanValue);
  if (number != null) {
    // Split into integer and decimal parts
    final parts = cleanValue.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Add commas to integer part
    final regex = RegExp(r'\B(?=(\d{3})+(?!\d))');
    final formattedInteger = integerPart.replaceAllMapped(regex, (match) => ',');

    // Combine back
    return decimalPart.isEmpty ? formattedInteger : '$formattedInteger.$decimalPart';
  }

  // If it's an expression with operators, format each number part
  var result = cleanValue.replaceAllMapped(
    RegExp(r'\d+\.?\d*'),
    (match) {
      final num = match.group(0)!;
      final parts = num.split('.');
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '';

      final regex = RegExp(r'\B(?=(\d{3})+(?!\d))');
      final formattedInteger = integerPart.replaceAllMapped(regex, (m) => ',');

      return decimalPart.isEmpty ? formattedInteger : '$formattedInteger.$decimalPart';
    },
  );

  // Replace programming operators with display symbols
  result = result
      .replaceAll('*', '×')
      .replaceAll('/', '÷')
      .replaceAll('-', '−');

  return result;
}

class CalculatorEngine extends StateNotifier<CalculatorState> {
  CalculatorEngine()
    : super(
        const CalculatorState(
          buffer: '0',
          calcHistory: [],
          mode: CalculatorEngineMode.result,
          error: '',
          sourceUnit: Unit.meters,
          targetUnit: Unit.feet,
        ),
      );

  void addToBuffer(String str, {bool continueWithResult = false}) {
    if (state.mode == CalculatorEngineMode.result) {
      state = state.copyWith(
        buffer: (continueWithResult ? state.buffer : '') + str,
        mode: CalculatorEngineMode.input,
        error: '',
      );
    } else {
      state = state.copyWith(buffer: state.buffer + str, error: '');
    }
  }

  void backspace() {
    final charList = Characters(state.buffer).toList();
    if (charList.isNotEmpty) {
      charList.length = charList.length - 1;
    }
    final newBuffer = charList.isEmpty ? '0' : charList.join();
    state = state.copyWith(
      buffer: newBuffer,
      mode: charList.isEmpty ? CalculatorEngineMode.result : state.mode,
    );
  }

  void clear() {
    state = state.copyWith(
      buffer: '0',
      mode: CalculatorEngineMode.result,
      error: '',
      lastEquation: '',
    );
  }

  void toggleSign() {
    if (state.buffer == '0' || state.buffer.isEmpty) return;
    
    // If it's a simple number or already wrapped, toggle the leading minus
    if (state.buffer.startsWith('-')) {
      state = state.copyWith(buffer: state.buffer.substring(1));
    } else {
      // For expressions, we can wrap or just prepend. Prepending is simpler for now.
      // If there are operators, wrapping might be safer: - ( expression )
      if (state.buffer.contains(RegExp(r'[+*/-]'))) {
         state = state.copyWith(buffer: '-(${state.buffer})');
      } else {
         state = state.copyWith(buffer: '-${state.buffer}');
      }
    }
  }

  void evaluate() {
    try {
      final equation = state.buffer.replaceAll(',', '').replaceAll('%', '/100.0');
      final parser = GrammarParser();
      final cm = ContextModel();
      final exp = parser.parse(equation);
      final result = exp.evaluate(EvaluationType.REAL, cm) as double;

      switch (result) {
        case double(isInfinite: true):
          state = state.copyWith(
            error: 'Result is Infinite',
            buffer: '',
            mode: CalculatorEngineMode.result,
            lastEquation: '',
          );
        case double(isNaN: true):
          state = state.copyWith(
            error: 'Result is Not a Number',
            buffer: '',
            mode: CalculatorEngineMode.result,
            lastEquation: '',
          );
        default:
          final resultStr = result.ceil() == result
              ? result.toInt().toString()
              : result.toString();
          state = state.copyWith(
            buffer: resultStr,
            mode: CalculatorEngineMode.result,
            lastEquation: state.buffer,
            calcHistory: [
              '${state.buffer} = $resultStr',
              ...state.calcHistory,
            ],
          );
      }
    } catch (err) {
      state = state.copyWith(
        error: err.toString(),
        buffer: '',
        mode: CalculatorEngineMode.result,
        lastEquation: '',
      );
    }
  }


  void setSourceUnit(Unit unit) {
    state = state.copyWith(sourceUnit: unit);
    if (state.targetUnit.category != unit.category) {
       final newTarget = UnitConverter.getUnitsForCategory(unit.category)
           .firstWhere((u) => u != unit, orElse: () => unit);
       state = state.copyWith(targetUnit: newTarget);
    }
  }

  void setTargetUnit(Unit unit) {
     if (unit.category == state.sourceUnit.category) {
       state = state.copyWith(targetUnit: unit);
     }
  }
}

final calculatorStateProvider =
    StateNotifierProvider<CalculatorEngine, CalculatorState>(
      (_) => CalculatorEngine(),
    );

enum CalculatorMode { standard, unitConverter }

final calculatorModeProvider = StateProvider<CalculatorMode>((_) => CalculatorMode.standard);



class ButtonDefinition {
  const ButtonDefinition({
    required this.areaName,
    required this.label,
    required this.op,
    required this.type,
  });

  final String areaName;
  final String label;
  final CalculatorEngineCallback op;
  final CalcButtonType type;
}

enum CalcButtonType { number, operator, function, equals }

final buttonDefinitions = <ButtonDefinition>[
  ButtonDefinition(
    areaName: 'clear',
    op: (engine) => engine.clear(),
    label: 'AC',
    type: CalcButtonType.function,
  ),
  ButtonDefinition(
    areaName: 'pm',
    op: (engine) => engine.toggleSign(),
    label: '+/-',
    type: CalcButtonType.function,
  ),
  ButtonDefinition(
    areaName: 'percent',
    op: (engine) => engine.addToBuffer('%'),
    label: '%',
    type: CalcButtonType.function,
  ),
  ButtonDefinition(
    areaName: 'divide',
    op: (engine) => engine.addToBuffer('/', continueWithResult: true),
    label: '÷',
    type: CalcButtonType.operator,
  ),
  ButtonDefinition(
    areaName: 'seven',
    op: (engine) => engine.addToBuffer('7'),
    label: '7',
    type: CalcButtonType.number,
  ),
  ButtonDefinition(
    areaName: 'eight',
    op: (engine) => engine.addToBuffer('8'),
    label: '8',
    type: CalcButtonType.number,
  ),
  ButtonDefinition(
    areaName: 'nine',
    op: (engine) => engine.addToBuffer('9'),
    label: '9',
    type: CalcButtonType.number,
  ),
  ButtonDefinition(
    areaName: 'multiply',
    op: (engine) => engine.addToBuffer('*', continueWithResult: true),
    label: '×',
    type: CalcButtonType.operator,
  ),
  ButtonDefinition(
    areaName: 'four',
    op: (engine) => engine.addToBuffer('4'),
    label: '4',
    type: CalcButtonType.number,
  ),
  ButtonDefinition(
    areaName: 'five',
    op: (engine) => engine.addToBuffer('5'),
    label: '5',
    type: CalcButtonType.number,
  ),
  ButtonDefinition(
    areaName: 'six',
    op: (engine) => engine.addToBuffer('6'),
    label: '6',
    type: CalcButtonType.number,
  ),
  ButtonDefinition(
    areaName: 'minus',
    op: (engine) => engine.addToBuffer('-', continueWithResult: true),
    label: '−',
    type: CalcButtonType.operator,
  ),
  ButtonDefinition(
    areaName: 'one',
    op: (engine) => engine.addToBuffer('1'),
    label: '1',
    type: CalcButtonType.number,
  ),
  ButtonDefinition(
    areaName: 'two',
    op: (engine) => engine.addToBuffer('2'),
    label: '2',
    type: CalcButtonType.number,
  ),
  ButtonDefinition(
    areaName: 'three',
    op: (engine) => engine.addToBuffer('3'),
    label: '3',
    type: CalcButtonType.number,
  ),
  ButtonDefinition(
    areaName: 'plus',
    op: (engine) => engine.addToBuffer('+', continueWithResult: true),
    label: '+',
    type: CalcButtonType.operator,
  ),
  ButtonDefinition(
    areaName: 'zero',
    op: (engine) => engine.addToBuffer('0'),
    label: '0',
    type: CalcButtonType.number,
  ),
  ButtonDefinition(
    areaName: 'point',
    op: (engine) => engine.addToBuffer('.'),
    label: '.',
    type: CalcButtonType.number,
  ),
  ButtonDefinition(
    areaName: 'bkspc',
    op: (engine) => engine.backspace(),
    label: '⌫',
    type: CalcButtonType.function,
  ),
  ButtonDefinition(
    areaName: 'equals',
    op: (engine) => engine.evaluate(),
    label: '=',
    type: CalcButtonType.equals,
  ),
];

class CalculatorApp extends ConsumerWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CalculatorHome();
  }
}

class CalculatorHome extends ConsumerStatefulWidget {
  const CalculatorHome({super.key});

  @override
  ConsumerState<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends ConsumerState<CalculatorHome>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _modePanelController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
      value: 1.0, // Open by default
    );
    _modePanelController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
        value: 0.0, // Closed by default
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _modePanelController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta! / 400; // Adjust sensitivity
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_controller.value > 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _onModePanelDragUpdate(DragUpdateDetails details) {
    _modePanelController.value += details.primaryDelta! / 300; // Sensitivity
  }

  void _onModePanelDragEnd(DragEndDetails details) {
    if (_modePanelController.value > 0.3) {
      _modePanelController.forward();
    } else {
      _modePanelController.reverse();
    }
  }

  void _toggleModePanel() {
    if (_modePanelController.isCompleted || _modePanelController.value > 0.5) {
      _modePanelController.reverse();
    } else {
      _modePanelController.forward();
    }
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Grab handle
              Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.palette, color: Colors.white),
                title: const Text('Theme', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement Theme settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text('About', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement About page
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculatorStateProvider);

    final buttonGridAreas = '''
          clear   pm      percent divide
          seven   eight   nine    multiply
          four    five    six     minus
          one     two     three   plus
          zero    point   bkspc   equals
          ''';

    final columnSizes = [1.fr, 1.fr, 1.fr, 1.fr];
    final rowSizes = [1.fr, 1.fr, 1.fr, 1.fr, 1.fr];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Background Layer: History and Display
                    Column(
                      children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Navigation Button
                          GestureDetector(
                            onTap: _toggleModePanel,
                            child: Row(
                              children: const [
                                Text(
                                  'ACalc',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          // Right: Settings Button
                          IconButton(
                            onPressed: _showSettingsSheet,
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    if (ref.watch(calculatorModeProvider) == CalculatorMode.standard) ...[
                      // Standard Mode: History (Flexible) then Display (Bottom)
                      Flexible(
                        fit: FlexFit.loose,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: state.calcHistory.isEmpty
                              ? const SizedBox.shrink()
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  reverse: true,
                                  itemCount: state.calcHistory.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: AutoSizeText(
                                          state.calcHistory[index],
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFFB0B0B0),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                      // Standard Display
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: state.error.isEmpty
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (state.mode == CalculatorEngineMode.result &&
                                        state.lastEquation.isNotEmpty)
                                      AutoSizeText(
                                        formatNumberWithCommas(state.lastEquation),
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Color(0xFFB0B0B0),
                                          fontWeight: FontWeight.w400,
                                        ),
                                        maxLines: 1,
                                      ),
                                    AutoSizeText(
                                      formatNumberWithCommas(state.buffer),
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        fontSize: 64,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ],
                                )
                              : AutoSizeText(
                                  state.error,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Color(0xFFEF5350),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 3,
                                ),
                        ),
                      ),
                    ] else ...[
                      // Unit Mode: Display Boxes (Top)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: SizedBox(
                          height: 160,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Source Box
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                     final units = UnitConverter.getUnitsForCategory(state.sourceUnit.category);
                                     final nextIndex = (units.indexOf(state.sourceUnit) + 1) % units.length;
                                     ref.read(calculatorStateProvider.notifier).setSourceUnit(units[nextIndex]);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: AutoSizeText(
                                            formatNumberWithCommas(state.buffer),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 48,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            state.sourceUnit.symbol,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.6),
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Target Box
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                     final units = UnitConverter.getUnitsForCategory(state.targetUnit.category);
                                     final nextIndex = (units.indexOf(state.targetUnit) + 1) % units.length;
                                     ref.read(calculatorStateProvider.notifier).setTargetUnit(units[nextIndex]);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Builder(
                                            builder: (context) {
                                              final sourceVal = double.tryParse(state.buffer.replaceAll(',', '')) ?? 0.0;
                                              final convertedVal = UnitConverter.convert(sourceVal, state.sourceUnit, state.targetUnit);
                                              final resultStr = convertedVal.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
                                              return AutoSizeText(
                                                formatNumberWithCommas(resultStr),
                                                style: const TextStyle(
                                                  color: Color(0xFFFF9500),
                                                  fontSize: 48,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                              );
                                            }
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            state.targetUnit.symbol,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.6),
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Unit Mode: Reference Grid (Bottom/Flexible)
                      Flexible(
                        fit: FlexFit.loose,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.0,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: UnitConverter.getUnitsForCategory(state.sourceUnit.category).length - 2 > 0 ? UnitConverter.getUnitsForCategory(state.sourceUnit.category).length - 2 : 0,
                            itemBuilder: (context, index) {
                              final allUnits = UnitConverter.getUnitsForCategory(state.sourceUnit.category);
                              final otherUnits = allUnits.where((u) => u != state.sourceUnit && u != state.targetUnit).toList();
                              
                              if (index >= otherUnits.length) return const SizedBox.shrink();

                              final unit = otherUnits[index];
                              final sourceVal = double.tryParse(state.buffer.replaceAll(',', '')) ?? 0.0;
                              final convertedVal = UnitConverter.convert(sourceVal, state.sourceUnit, unit);
                              final resultStr = convertedVal.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');

                              return InkWell(
                                onTap: () {
                                   ref.read(calculatorStateProvider.notifier).setTargetUnit(unit);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: AutoSizeText(
                                          formatNumberWithCommas(resultStr),
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.8),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          unit.symbol,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.5),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                    // Dynamic spacer to push Display/History above the button panel
                    Flexible(
                      fit: FlexFit.loose,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return SizedBox(height: 450 * _controller.value + 50);
                        },
                      ),
                    ),
                    ],
                  ),
                  // Foreground Layer: Sliding Button Panel
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final panelHeight = 450 * _controller.value + 50;
                    return Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: panelHeight,
                      child: GestureDetector(
                        onVerticalDragUpdate: _onVerticalDragUpdate,
                        onVerticalDragEnd: _onVerticalDragEnd,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                    children: [
                                      // Handle / Indicator
                                      SizedBox(
                                        width: double.infinity,
                                        height: 30, // Reduced height
                                        child: Center(
                                          child: Container(
                                            width: 50, // Slightly wider
                                            height: 5, // Slightly thicker
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF424242), // Dark grey
                                              borderRadius: BorderRadius.circular(2.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Button Grid
                                      if (_controller.value > 0.01)
                                        Expanded(
                                          child: Opacity(
                                            opacity: _controller.value,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: LayoutGrid(
                                                areas: buttonGridAreas,
                                                columnSizes: columnSizes,
                                                rowSizes: rowSizes,
                                                children: [
                                                  ...buttonDefinitions.map(
                                                    (definition) => NamedAreaGridPlacement(
                                                      areaName: definition.areaName,
                                                      child: CalcButton(
                                                        label: definition.label,
                                                        op: definition.op,
                                                        type: definition.type,
                                                      ),
                                                    ),
                                                  ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
          // Netflix-style Full Page Mode Selector Overlay
                AnimatedBuilder(
                  animation: _modePanelController,
                  builder: (context, child) {
                    if (_modePanelController.value == 0) {
                      return const SizedBox.shrink();
                    }
                    
                    return Positioned.fill(
                      child: GestureDetector(
                        onTap: () => _modePanelController.reverse(),
                        child: FadeTransition(
                          opacity: _modePanelController,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 25 * _modePanelController.value,
                                sigmaY: 25 * _modePanelController.value,
                              ),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.6 * _modePanelController.value),
                                child: SafeArea(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Spacer(flex: 2),
                                      // Mode Options List
                                      _buildModeOption(CalculatorMode.standard, 'Standard'),
                                      const SizedBox(height: 24),
                                      _buildModeOption(CalculatorMode.unitConverter, 'Unit Converter'),
                                      const Spacer(flex: 3),
                                      // Close Button (X) at bottom
                                      Center(
                                        child: GestureDetector(
                                          onTap: () => _modePanelController.reverse(),
                                          child: Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.black,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 48),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ],
            );
          },
        ),
      ),
    ),
  ),
);
  }

  Widget _buildModeOption(CalculatorMode mode, String label) {
    final isSelected = ref.watch(calculatorModeProvider) == mode;
    return InkWell(
      onTap: () {
         ref.read(calculatorModeProvider.notifier).state = mode;
         _modePanelController.reverse();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

typedef CalculatorEngineCallback = void Function(CalculatorEngine engine);

class CalcButton extends ConsumerWidget {
  const CalcButton({
    super.key,
    required this.op,
    required this.label,
    required this.type,
  });

  final CalculatorEngineCallback op;
  final String label;
  final CalcButtonType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case CalcButtonType.number:
        backgroundColor = const Color(0xFF2C2C2C);
        textColor = const Color(0xFFFFFFFF);
        break;
      case CalcButtonType.operator:
        backgroundColor = const Color(0xFF7A6B5D); // Tan/brown grey
        textColor = const Color(0xFFFFFFFF);
        break;
      case CalcButtonType.function:
        backgroundColor = const Color(0xFFA6A6A6);
        textColor = const Color(0xFF000000);
        break;
      case CalcButtonType.equals:
        backgroundColor = const Color(0xFFFF9500); // Orange
        textColor = const Color(0xFFFFFFFF);
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final radius = constraints.biggest.shortestSide * 0.225;
        return SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: ElevatedButton(
              autofocus: false,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.2),
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(radius * 2), // Continuous uses diameter-like scaling
                ),
              ),
              onPressed: () => op(ref.read(calculatorStateProvider.notifier)),
              child: AutoSizeText(
                label,
                style: TextStyle(
                  fontSize: 28,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                minFontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}


