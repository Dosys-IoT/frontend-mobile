import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../data/medication_models.dart';
import '../data/medication_service.dart';

class EditMedicationScreen extends StatefulWidget {
  final ContainerModel container;
  final int deviceId;

  const EditMedicationScreen({
    super.key,
    required this.container,
    required this.deviceId,
  });

  @override
  State<EditMedicationScreen> createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _dosageCtrl;
  List<ScheduleModel> _schedules = [];
  bool _reminderAlerts = true;
  bool _lowStockAlerts = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.container.medicationName ?? '');
    _dosageCtrl = TextEditingController(text: _parseDosageNumber(widget.container.dosageLabel));
    _loadSchedules();
  }

  String _parseDosageNumber(String? label) {
    if (label == null) return '';
    final match = RegExp(r'\d+').firstMatch(label);
    return match?.group(0) ?? '';
  }

  Future<void> _loadSchedules() async {
    final schedules = await MedicationService.getSchedules(widget.deviceId);
    if (!mounted) return;
    setState(() {
      _schedules = schedules.where((s) => s.containerNumber == widget.container.containerNumber).toList();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final dosage = _dosageCtrl.text.trim();
    final dosageLabel = dosage.isNotEmpty ? '${dosage}mg' : (widget.container.dosageLabel ?? '');
    await MedicationService.updateContainer(
      widget.deviceId,
      widget.container.containerNumber,
      _nameCtrl.text.trim(),
      dosageLabel,
      widget.container.remainingPills,
      widget.container.isEnabled,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    context.pop();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
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
                  _buildHeroCard(),
                  const SizedBox(height: 24),
                  _buildField('MEDICATION NAME', _nameCtrl, 'Lisinopril'),
                  const SizedBox(height: 16),
                  _buildField('DOSAGE (MG)', _dosageCtrl, '10', keyboardType: TextInputType.number),
                  const SizedBox(height: 24),
                  _buildScheduleSection(),
                  const SizedBox(height: 24),
                  _buildSmartMonitoring(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
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
            child: Text('Edit Medication', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A7C59), Color(0xFF2D5A27)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CURRENTLY MANAGING', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  widget.container.medicationName ?? 'Unknown',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.container.dosageLabel ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.link_outlined, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    final morning = _schedules.where((s) {
      final h = s.time['hour'] ?? 0;
      return h >= 5 && h < 12;
    }).toList();
    final evening = _schedules.where((s) {
      final h = s.time['hour'] ?? 0;
      return h >= 12;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Frequency & Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Manage daily intake windows', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Adjust', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ScheduleRow(
          icon: Icons.wb_sunny_outlined,
          label: 'Morning Dose',
          schedule: morning.isNotEmpty ? morning.first : null,
        ),
        const SizedBox(height: 8),
        _ScheduleRow(
          icon: Icons.nightlight_outlined,
          label: 'Evening Dose',
          schedule: evening.isNotEmpty ? evening.first : null,
        ),
      ],
    );
  }

  Widget _buildSmartMonitoring() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Smart Monitoring', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _ToggleRow(
            label: 'Reminder alerts',
            subtitle: 'Notify 15 minutes before scheduled dose',
            value: _reminderAlerts,
            onChanged: (v) => setState(() => _reminderAlerts = v),
          ),
          const Divider(height: 20),
          _ToggleRow(
            label: 'Low-stock alerts',
            subtitle: 'Notify when less than 7 days remaining',
            value: _lowStockAlerts,
            onChanged: (v) => setState(() => _lowStockAlerts = v),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.history, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'CURRENT INVENTORY: ${widget.container.remainingPills} PILLS',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text('REFILL', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            label: const Text('Re-calibrate Dispenser'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => _confirmDelete(),
            icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
            label: const Text('Delete medication', style: TextStyle(color: Color(0xFFDC2626))),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              side: const BorderSide(color: Color(0xFFFECACA)),
              backgroundColor: const Color(0xFFFEF2F2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete medication?'),
        content: Text('This will clear compartment ${widget.container.containerNumber}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final ScheduleModel? schedule;

  const _ScheduleRow({required this.icon, required this.label, this.schedule});

  @override
  Widget build(BuildContext context) {
    final hasSchedule = schedule != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: hasSchedule ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(
                  hasSchedule ? '${schedule!.timeLabel} • 1 Pill' : 'Not scheduled',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(
            hasSchedule ? Icons.chevron_right : Icons.add_circle_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }
}
