import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_pasteur/core/constants/app_colors.dart';
import 'package:noble_pasteur/core/constants/app_strings.dart';
import 'package:noble_pasteur/core/utils/validators.dart';
import 'package:noble_pasteur/features/profile/domain/entities/user_profile.dart';
import 'package:noble_pasteur/features/profile/presentation/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _medicalNotesController;
  late final TextEditingController _emergencyContactController;
  String? _selectedBloodGroup;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _medicalNotesController = TextEditingController();
    _emergencyContactController = TextEditingController();

    // Populate controllers if profile already loaded
    final currentProfile = ref.read(profileProvider).asData?.value;
    if (currentProfile != null) {
      _populateFields(currentProfile);
    }
  }

  void _populateFields(UserProfile profile) {
    _nameController.text = profile.name;
    _phoneController.text = profile.phoneNumber;
    _addressController.text = profile.address;
    _selectedBloodGroup = profile.bloodGroup;
    _medicalNotesController.text = profile.medicalNotes ?? '';
    _emergencyContactController.text = profile.emergencyContactPhone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _medicalNotesController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profile = UserProfile(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      bloodGroup: _selectedBloodGroup,
      medicalNotes: _medicalNotesController.text.trim().isEmpty
          ? null
          : _medicalNotesController.text.trim(),
      emergencyContactPhone: _emergencyContactController.text.trim().isEmpty
          ? null
          : _emergencyContactController.text.trim(),
    );

    final success =
        await ref.read(profileProvider.notifier).saveProfile(profile);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.successGreen,
            content: Text(
              AppStrings.profileSavedSuccess,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.emergencyRed,
            content: Text('Failed to save profile. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserProfile?>>(profileProvider, (previous, next) {
      next.whenData((profile) {
        if (profile != null && _nameController.text.isEmpty) {
          setState(() {
            _populateFields(profile);
          });
        }
      });
    });

    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMERGENCY PROFILE'),
      ),
      body: SafeArea(
        child: profileState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.emergencyRed),
          ),
          error: (err, _) => Center(
            child: Text(
              'Error loading profile: $err',
              style: const TextStyle(color: AppColors.emergencyRed),
            ),
          ),
          data: (profile) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.emergencyRedGlow,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.medical_information_outlined,
                          color: AppColors.emergencyRed,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppStrings.profileSubtitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '${AppStrings.fullName} *',
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '${AppStrings.phoneNumber} *',
                      prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textMuted),
                      hintText: '+1 555 123 4567',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhoneNumber,
                  ),
                  const SizedBox(height: 16),

                  // Primary Address
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: '${AppStrings.address} *',
                      prefixIcon: Icon(Icons.home_outlined, color: AppColors.textMuted),
                      hintText: 'Apartment, Street, City',
                    ),
                    maxLines: 2,
                    validator: Validators.validateAddress,
                  ),
                  const SizedBox(height: 20),

                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),
                  const Text(
                    'SUPPLEMENTARY MEDICAL DATA',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Blood Group Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBloodGroup,
                    dropdownColor: AppColors.surfaceElevated,
                    decoration: const InputDecoration(
                      labelText: AppStrings.bloodGroup,
                      prefixIcon: Icon(Icons.bloodtype_outlined, color: AppColors.textMuted),
                    ),
                    items: _bloodGroups.map((group) {
                      return DropdownMenuItem(
                        value: group,
                        child: Text(group, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedBloodGroup = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Critical Allergies / Medical Notes
                  TextFormField(
                    controller: _medicalNotesController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.medicalNotes,
                      prefixIcon: Icon(Icons.note_alt_outlined, color: AppColors.textMuted),
                      hintText: 'e.g., Penicillin allergy, Diabetic, Asthma',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Emergency Contact Phone
                  TextFormField(
                    controller: _emergencyContactController,
                    decoration: const InputDecoration(
                      labelText: AppStrings.emergencyContact,
                      prefixIcon: Icon(Icons.contact_phone_outlined, color: AppColors.textMuted),
                      hintText: '+1 555 987 6543',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: Validators.validateOptionalPhone,
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: _handleSave,
                    child: const Text(AppStrings.saveProfile),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
