import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:noble_pasteur/core/constants/app_colors.dart';
import 'package:noble_pasteur/core/constants/app_strings.dart';
import 'package:noble_pasteur/features/profile/presentation/providers/profile_provider.dart';
import 'package:noble_pasteur/features/profile/presentation/screens/profile_screen.dart';
import 'package:noble_pasteur/features/sos/presentation/providers/sos_provider.dart';
import 'package:noble_pasteur/features/sos/presentation/providers/sos_state.dart';
import 'package:noble_pasteur/features/sos/presentation/widgets/dispatch_status_sheet.dart';
import 'package:noble_pasteur/features/sos/presentation/widgets/emergency_drawer.dart';
import 'package:noble_pasteur/features/sos/presentation/widgets/sos_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialLocationReadiness();
    });
  }

  Future<void> _checkInitialLocationReadiness() async {
    final locationService = ref.read(locationServiceProvider);
    try {
      final isEnabled = await locationService.isLocationServiceEnabled();
      if (isEnabled) {
        await locationService.checkPermission();
      }
    } catch (_) {}
  }

  Future<void> _callEmergency(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(sosProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      drawer: const EmergencyDrawer(),
      appBar: AppBar(
        title: const Text('EMERGENCY SOS'),
        actions: [
          IconButton(
            tooltip: 'Emergency Profile',
            icon: Stack(
              children: [
                const Icon(Icons.person_outline_rounded, size: 26),
                if (profileAsync.asData?.value?.isComplete != true)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.warningAmber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Minimalist Center Screen
            Column(
              children: [
                // Minimal Notice / Instructions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: profileAsync.when(
                    loading: () => const SizedBox(height: 36),
                    error: (_, __) => const SizedBox(height: 36),
                    data: (profile) {
                      if (profile != null && profile.isComplete) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.successGreen,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Profile active for: ${profile.name}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.warningAmber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.warningAmber,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Tap to complete medical profile (Name, Phone, Address)',
                                style: TextStyle(
                                  color: AppColors.warningAmber,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Center Massive SOS Trigger
                const Expanded(
                  child: Center(
                    child: SosButton(),
                  ),
                ),

                // Fallback Quick Dial Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_in_talk_rounded,
                        color: AppColors.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Direct dial backup:',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _callEmergency(AppStrings.emergencyNumber),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            '112',
                            style: TextStyle(
                              color: AppColors.emergencyRed,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const Text('•', style: TextStyle(color: AppColors.textMuted)),
                      InkWell(
                        onTap: () => _callEmergency(AppStrings.altEmergencyNumber),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            '911',
                            style: TextStyle(
                              color: AppColors.emergencyRed,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Failure Alert Banner / Modal
            if (sosState.status == SosStatus.failure)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.emergencyRed, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.emergencyRed,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'SOS DISPATCH FAILED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sosState.errorMessage ?? 'Unable to complete dispatch.',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (sosState.isPermissionPermanentlyDenied)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  ref.read(locationServiceProvider).openAppSettings();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.border),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Open Settings'),
                              ),
                            )
                          else
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  ref.read(sosProvider.notifier).resetToIdle();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.border),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Dismiss'),
                              ),
                            ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.emergencyRed,
                              ),
                              onPressed: () => _callEmergency(AppStrings.emergencyNumber),
                              icon: const Icon(Icons.phone, size: 18),
                              label: const Text('Call 112 Now'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Active Dispatch Bottom Sheet
            if (sosState.status == SosStatus.active && sosState.dispatch != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: DispatchStatusSheet(
                  dispatch: sosState.dispatch!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
