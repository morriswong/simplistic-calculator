import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main.dart';
import 'unit_converter.dart';

// Mode enum for carousel
enum CarouselMode {
  simple, // Default calculator
  length, // Unit converter - length
  area, // Unit converter - area
  weight, // Unit converter - weight
  volume, // Unit converter - volume
  speed, // Unit converter - speed (placeholder)
}

// Extension for mode labels and metadata
extension CarouselModeExtension on CarouselMode {
  String get label {
    switch (this) {
      case CarouselMode.simple:
        return 'Simple';
      case CarouselMode.length:
        return 'Length';
      case CarouselMode.area:
        return 'Area';
      case CarouselMode.weight:
        return 'Weight';
      case CarouselMode.volume:
        return 'Volume';
      case CarouselMode.speed:
        return 'Speed';
    }
  }

  IconData get icon {
    switch (this) {
      case CarouselMode.simple:
        return Icons.calculate;
      case CarouselMode.length:
        return Icons.straighten;
      case CarouselMode.area:
        return Icons.grid_on;
      case CarouselMode.weight:
        return Icons.monitor_weight;
      case CarouselMode.volume:
        return Icons.opacity;
      case CarouselMode.speed:
        return Icons.speed;
    }
  }

  bool get isImplemented {
    return this == CarouselMode.simple ||
        this == CarouselMode.length ||
        this == CarouselMode.area ||
        this == CarouselMode.weight ||
        this == CarouselMode.volume;
  }
}

// State providers
final carouselModeProvider =
    StateProvider<CarouselMode>((_) => CarouselMode.simple);

final modeOrderProvider = StateProvider<List<CarouselMode>>((_) => [
      CarouselMode.simple,
      CarouselMode.length,
      CarouselMode.area,
      CarouselMode.weight,
      CarouselMode.volume,
      CarouselMode.speed,
    ]);

// Helper function to sync carousel mode with calculator mode
void updateCalculatorMode(CarouselMode mode, WidgetRef ref) {
  switch (mode) {
    case CarouselMode.simple:
      ref.read(calculatorModeProvider.notifier).state =
          CalculatorMode.standard;
      break;

    case CarouselMode.length:
      ref.read(calculatorModeProvider.notifier).state =
          CalculatorMode.unitConverter;
      ref.read(calculatorStateProvider.notifier).setSourceUnit(Unit.meters);
      ref.read(calculatorStateProvider.notifier).setTargetUnit(Unit.feet);
      break;

    case CarouselMode.area:
      ref.read(calculatorModeProvider.notifier).state =
          CalculatorMode.unitConverter;
      ref.read(calculatorStateProvider.notifier).setSourceUnit(Unit.squareMeters);
      ref.read(calculatorStateProvider.notifier).setTargetUnit(Unit.squareFeet);
      break;

    case CarouselMode.weight:
      ref.read(calculatorModeProvider.notifier).state =
          CalculatorMode.unitConverter;
      ref.read(calculatorStateProvider.notifier).setSourceUnit(Unit.kilograms);
      ref.read(calculatorStateProvider.notifier).setTargetUnit(Unit.pounds);
      break;

    case CarouselMode.volume:
      ref.read(calculatorModeProvider.notifier).state =
          CalculatorMode.unitConverter;
      ref.read(calculatorStateProvider.notifier).setSourceUnit(Unit.liters);
      ref.read(calculatorStateProvider.notifier).setTargetUnit(Unit.gallons);
      break;

    case CarouselMode.speed:
      // Placeholder: Keep in Simple mode until features implemented
      ref.read(calculatorModeProvider.notifier).state =
          CalculatorMode.standard;
      break;
  }
}

// Main carousel widget
class ModeCarousel extends ConsumerStatefulWidget {
  const ModeCarousel({
    super.key,
    required this.buttonHeight,
  });

  final double buttonHeight;

  @override
  ConsumerState<ModeCarousel> createState() => _ModeCarouselState();
}

class _ModeCarouselState extends ConsumerState<ModeCarousel>
    with SingleTickerProviderStateMixin {
  late AnimationController _reorderController;
  late ScrollController _scrollController;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _reorderController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _reorderController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onModeTap(CarouselMode tappedMode) {
    if (_isAnimating) return;

    final currentOrder = ref.read(modeOrderProvider);
    final tappedIndex = currentOrder.indexOf(tappedMode);

    if (tappedIndex == 0) return; // Already first

    // Animate reorder
    setState(() => _isAnimating = true);

    _reorderController.forward(from: 0.0).then((_) {
      // Update mode order
      final newOrder = [
        tappedMode,
        ...currentOrder.where((m) => m != tappedMode),
      ];
      ref.read(modeOrderProvider.notifier).state = newOrder;
      ref.read(carouselModeProvider.notifier).state = tappedMode;

      // Clear calculator display
      ref.read(calculatorStateProvider.notifier).clear();

      // Sync with calculator mode
      updateCalculatorMode(tappedMode, ref);

      setState(() => _isAnimating = false);
      _reorderController.reset();

      // Scroll to beginning to show selected mode
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final modeOrder = ref.watch(modeOrderProvider);
    final currentMode = ref.watch(carouselModeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate max width to show 3 full pills + a peek of the 4th
        final horizontalPadding = 16.0; // 8pt on each side
        final gapWidth = 6.0; // Tighter spacing like Apple News
        final availableWidth = constraints.maxWidth - horizontalPadding;

        // Show 3.3 pills to give a peek of the 4th
        final visiblePills = 3.3;
        final maxPillWidth = (availableWidth - (gapWidth * (visiblePills - 1))) / visiblePills;

        return SizedBox(
          height: widget.buttonHeight,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: modeOrder.length,
            separatorBuilder: (_, __) => SizedBox(width: gapWidth),
            itemBuilder: (context, index) {
              final mode = modeOrder[index];
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxPillWidth),
                child: ModePillButton(
                  mode: mode,
                  isSelected: mode == currentMode,
                  onTap: () => _onModeTap(mode),
                  buttonHeight: widget.buttonHeight,
                  animationValue: _isAnimating ? _reorderController.value : 1.0,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Pill button widget - Apple News style
class ModePillButton extends StatelessWidget {
  const ModePillButton({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
    required this.buttonHeight,
    required this.animationValue,
  });

  final CarouselMode mode;
  final bool isSelected;
  final VoidCallback onTap;
  final double buttonHeight;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? const Color(0xFFA6A6A6) // Selected - light grey
        : const Color(0xFF3C3C3C); // Unselected - darker grey

    final iconTextColor = isSelected
        ? const Color(0xFF000000) // Selected - black
        : const Color(0xFFB0B0B0); // Unselected - grey

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      height: buttonHeight,
      child: ElevatedButton(
        autofocus: false,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: iconTextColor,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonHeight / 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              mode.icon,
              size: 16,
              color: iconTextColor,
            ),
            const SizedBox(width: 6),
            Text(
              mode.label,
              style: TextStyle(
                fontSize: 12,
                color: iconTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
