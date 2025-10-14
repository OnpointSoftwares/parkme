import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/kanjo_service.dart';
import '../models/kanjo_models.dart';
import 'kanjo_dashboard.dart';

/// Screen for setting up kanjo officer profile
class KanjoProfileSetupScreen extends StatefulWidget {
  const KanjoProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<KanjoProfileSetupScreen> createState() => _KanjoProfileSetupScreenState();
}

class _KanjoProfileSetupScreenState extends State<KanjoProfileSetupScreen> {
  final KanjoService _service = KanjoService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _badgeNumberController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  bool _isLoading = false;

  final List<String> _zones = [
    'CBD',
    'Westlands',
    'Kilimani',
    'Karen',
    'Eastleigh',
    'Kasarani',
    'Embakasi',
    'Langata',
  ];

  @override
  void initState() {
    super.initState();
    _departmentController.text = 'Parking Enforcement';
    _zoneController.text = _zones.first;
  }

  @override
  void dispose() {
    _badgeNumberController.dispose();
    _departmentController.dispose();
    _zoneController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.security,
                  size: 80,
                  color: Colors.orange[800],
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Kanjo Officer Profile Setup',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Please provide your officer details to complete your profile',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildTextField(
                controller: _badgeNumberController,
                label: 'Badge Number',
                icon: Icons.badge,
                hint: 'e.g., NCC-001',
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Badge number is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _departmentController,
                label: 'Department',
                icon: Icons.business,
                readOnly: true,
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                value: _zoneController.text,
                label: 'Zone Assignment',
                icon: Icons.location_city,
                items: _zones,
                onChanged: (value) {
                  setState(() {
                    _zoneController.text = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _contactController,
                label: 'Contact Number',
                icon: Icons.phone,
                hint: '+254712345678',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Contact number is required';
                  if (!value!.startsWith('+254') && !value.startsWith('07') && !value.startsWith('01')) {
                    return 'Please enter a valid Kenyan phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Complete Setup',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
      ),
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // Format phone number
      String contactNumber = _contactController.text.trim();
      if (contactNumber.startsWith('07') || contactNumber.startsWith('01')) {
        contactNumber = '+254${contactNumber.substring(1)}';
      }

      final officer = KanjoOfficer(
        id: user.uid,
        name: user.displayName ?? 'Officer',
        badgeNumber: _badgeNumberController.text.trim(),
        department: _departmentController.text.trim(),
        zone: _zoneController.text,
        contactNumber: contactNumber,
        isActive: true,
        joinedDate: DateTime.now(),
        assignedAreas: [_zoneController.text],
      );

      await _service.createOfficerProfile(officer);

      if (mounted) {
        // Navigate to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const KanjoDashboard(),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile setup complete! Welcome aboard.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
