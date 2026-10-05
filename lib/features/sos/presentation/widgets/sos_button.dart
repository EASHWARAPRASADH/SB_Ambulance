import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_pasteur/core/constants/app_colors.dart';
import 'package:noble_pasteur/core/constants/app_strings.dart';
import 'package:noble_pasteur/features/sos/presentation/providers/sos_provider.dart';
import 'package:noble_pasteur/features/sos/presentation/providers/sos_state.dart';
import 'package:noble_pasteur/features/sos/presentation/widgets/animated_pulse_ring.dart';

class SosButton extends ConsumerStatefulWidget {
  const SosButton({super.key});

  @override
  ConsumerState<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends ConsumerState<SosButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _holdController;
  static const Duration _holdDuration = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: _holdDuration,
    )..addListener(() {
        ref.read(sosProvider.notifier).updateHoldProgress(_holdController.value);
      });
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _onPressStart() {
    final status = ref.read(sosProvider).status;
    if (status == SosStatus.idle) {
      ref.read(sosProvider.notifier).onHoldStart();
      _holdController.forward(from: 0.0);
    }
  }

  void _onPressEnd() {
    final status = ref.read(sosProvider).status;
    if (status == SosStatus.holding) {
      _holdController.reset();
      ref.read(sosProvider.notifier).onHoldCancelled();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(sosProvider);
    final isProcessing = sosState.isProcessing;
    final isHolding = sosState.status == SosStatus.holding;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background radar pulsing rings
          AnimatedPulseRing(
            size: 260,
            isPulsing: !isProcessing && sosState.status != SosStatus.active,
            color: isHolding ? AppColors.warningAmber : AppColors.emergencyRed,
          ),

          // Outer Hold-Progress Ring (Active during holding)
          AnimatedBuilder(
            animation: _holdController,
            builder: (context, child) {
              return SizedBox(
                width: 240,
                height: 240,
                child: CircularProgressIndicator(
                  value: isProcessing ? null : _holdController.value,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surfaceElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isProcessing
                        ? AppColors.infoBlue
                        : isHolding
                            ? AppColors.warningAmber
                            : AppColors.emergencyRed,
                  ),
                ),
              );
            },
          ),

          // Core Interactive SOS Trigger Button
          GestureDetector(
            onTapDown: (_) => _onPressStart(),
            onTapUp: (_) => _onPressEnd(),
            onTapCancel: () => _onPressEnd(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isProcessing
                      ? [const Color(0xFF1E3A5F), const Color(0xFF0F1E33)]
                      : isHolding
                          ? [const Color(0xFFFF6D00), const Color(0xFFDD2C00)]
                          : [AppColors.emergencyRed, AppColors.emergencyRedDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isHolding ? AppColors.warningAmber : AppColors.emergencyRed)
                        .withValues(alpha: 0.4),
                    blurRadius: isHolding ? 35 : 25,
                    spreadRadius: isHolding ? 4 : 2,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.white.withValues(alpha: 0.1),
                    child: Center(
                      child: isProcessing
                          ? _buildProcessingContent(sosState)
                          : _buildIdleContent(isHolding),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleContent(bool isHolding) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isHolding ? Icons.touch_app_rounded : Icons.local_hospital_rounded,
          size: 46,
          color: Colors.white,
        ),
        const SizedBox(height: 8),
        Text(
          isHolding ? 'HOLDING...' : AppStrings.sosButtonText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isHolding ? 'Release to cancel' : 'HOLD 1.5s',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingContent(SosState state) {
    String message = AppStrings.acquiringLocation;
    if (state.status == SosStatus.findingHospital) {
      message = AppStrings.findingHospital;
    } else if (state.status == SosStatus.dispatching) {
      message = AppStrings.dispatchingAmbulance;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
