import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:noble_pasteur/app.dart';
import 'package:noble_pasteur/core/constants/app_strings.dart';
import 'package:noble_pasteur/core/utils/validators.dart';
import 'package:noble_pasteur/features/profile/presentation/providers/profile_provider.dart';
import 'package:noble_pasteur/features/sos/presentation/providers/sos_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Validators Test Suite', () {
    test('Name validator enforces non-empty and minimum length', () {
      expect(Validators.validateName(null), isNotNull);
      expect(Validators.validateName(''), isNotNull);
      expect(Validators.validateName('A'), isNotNull);
      expect(Validators.validateName('John Doe'), isNull);
    });

    test('Phone number validator enforces valid emergency phone format', () {
      expect(Validators.validatePhoneNumber(null), isNotNull);
      expect(Validators.validatePhoneNumber(''), isNotNull);
      expect(Validators.validatePhoneNumber('123'), isNotNull);
      expect(Validators.validatePhoneNumber('invalid_text'), isNotNull);
      expect(Validators.validatePhoneNumber('+12345678901'), isNull);
      expect(Validators.validatePhoneNumber('9876543210'), isNull);
    });

    test('Address validator enforces minimum content', () {
      expect(Validators.validateAddress(null), isNotNull);
      expect(Validators.validateAddress(''), isNotNull);
      expect(Validators.validateAddress('abc'), isNotNull);
      expect(Validators.validateAddress('123 Main Street, Apt 4B'), isNull);
    });
  });

  group('Ambulance SOS Widget Tests', () {
    testWidgets('App renders Home Screen with SOS trigger and emergency navigation',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final mockPrefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: const AmbulanceSosApp(),
        ),
      );

      // Pulse a single frame and a small interval (avoiding pumpAndSettle due to infinite pulse beacon animation)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Top Title
      expect(find.text('EMERGENCY SOS'), findsOneWidget);

      // Verify SOS Hold Text
      expect(find.text(AppStrings.sosButtonText), findsOneWidget);

      // Verify Direct Dial Backup is available
      expect(find.text('112'), findsOneWidget);
      expect(find.text('911'), findsOneWidget);
    });
  });

  group('SosState Machine Tests', () {
    test('Initial state is idle with 0 progress', () {
      const state = SosState();
      expect(state.status, SosStatus.idle);
      expect(state.holdProgress, 0.0);
      expect(state.isProcessing, isFalse);
      expect(state.isActive, isFalse);
    });

    test('State copyWith updates progress and flags properly', () {
      const state = SosState();
      final holding = state.copyWith(
        status: SosStatus.holding,
        holdProgress: 0.5,
      );
      expect(holding.status, SosStatus.holding);
      expect(holding.holdProgress, 0.5);
      expect(holding.isProcessing, isFalse);

      final locating = holding.copyWith(status: SosStatus.locating);
      expect(locating.isProcessing, isTrue);
    });
  });
}
