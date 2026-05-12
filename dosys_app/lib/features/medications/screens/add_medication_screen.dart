import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../data/medication_models.dart';
import '../data/medication_service.dart';

class AddMedicationScreen extends StatefulWidget {
  final int deviceId;
  const AddMedicationScreen({super.key, required this.deviceId});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _pillWeightCtrl = TextEditingController(text: '500');
  final _refillThresholdCtrl = TextEditingController(text: '15');
  final _loadedQtyCtrl = TextEditingController(text: '30');
  final _dosagePerIntakeCtrl = TextEditingController(text: '1');

  int _selectedCompartment = 1;
  bool _saving = false;
  String? _error;

  List<ContainerModel> _containers = [];

  @override
  void initState() {
    super.initState();
    _loadContainers();
  }

  Future<void> _loadContainers() async {
    final c = await MedicationService.getContainers(widget.deviceId);
    if (mounted) setState(() => _containers = c);
  }

  bool _isCompartmentAvailable(int num) {
    try {
      final c = _containers.firstWhere((c) => c.containerNumber == num);
      return !c.isEnabled || (c.medicationName?.isEmpty ?? true);
    } catch (_) {
      return true;
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Medication name is required.');
      return;
    }
    setState(() { _saving = true; _error = null; });

    final dosage = _dosageCtrl.text.trim();
    final dosageLabel = dosage.isNotEmpty
        ? '${dosage}mg • Once Daily • Morning'
        : 'Once Daily • Morning';

    final ok = await MedicationService.updateContainer(
      widget.deviceId,
      _selectedCompartment,
      _nameCtrl.text.trim(),
      dosageLabel,
      int.tryParse(_loadedQtyCtrl.text) ?? 30,
      true,
    );

    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      context.pop();
    } else {
      setState(() => _error = 'Failed to save. Try again.');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _pillWeightCtrl.dispose();
    _refillThresholdCtrl.dispose();
    _loadedQtyCtrl.dispose();
    _dosagePerIntakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildIntro(),
                  const SizedBox(height: 20),
                  _buildField('MEDICATION NAME', _nameCtrl, 'e.g. Metformin'),
                  const SizedBox(height: 16),
                  _buildCompartmentPicker(),
                  const SizedBox(height: 24),
                  _buildDosageLogistics(),
                  const SizedBox(height: 24),
                  _buildFrequencySchedule(),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildActions(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text('Add New Medication', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ),
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            radius: 18,
            child: Icon(Icons.person_outline, color: AppColors.primary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New Entry', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          'Ensure accuracy to maintain your clinical sanctuary. Calibration helps Dosys detect dosage errors automatically.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(controller: ctrl, keyboardType: keyboardType, decoration: InputDecoration(hintText: hint)),
      ],
    );
  }

  Widget _buildCompartmentPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('COMPARTMENT ASSIGNMENT', style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (i) {
            final num = i + 1;
            final available = _isCompartmentAvailable(num);
            final selected = _selectedCompartment == num;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: available ? () => setState(() => _selectedCompartment = num) : null,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.primary
                        : available
                            ? AppColors.primaryLight
                            : AppColors.inputFill,
                    border: selected ? null : Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      '$num',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? Colors.white
                            : available
                                ? AppColors.primary
                                : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDosageLogistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dosage Logistics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildSmallField('DOSAGE PER INTAKE', _dosagePerIntakeCtrl, 'pil', TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _buildSmallField('LOADED QUANTITY', _loadedQtyCtrl, 'total', TextInputType.number)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSmallField('PILL WEIGHT', _pillWeightCtrl, 'mg', TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _buildSmallField('REFILL THRESHOLD', _refillThresholdCtrl, '%', TextInputType.number)),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallField(String label, TextEditingController ctrl, String suffix,
      TextInputType keyboardType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            suffixText: suffix,
            suffixStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FREQUENCY SCHEDULE', style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        _ScheduleOption(
          icon: Icons.calendar_today_outlined,
          label: 'Daily Intake',
          subtitle: 'Every day at 08:00 AM',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _ScheduleOption(
          icon: Icons.timer_outlined,
          label: 'Intervals',
          subtitle: '',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: const Text('Save Medication', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.tune),
            label: const Text('Calibrate Sensor', style: TextStyle(fontSize: 15)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _ScheduleOption({required this.icon, required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
