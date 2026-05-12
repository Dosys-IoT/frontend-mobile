import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../data/medication_models.dart';
import '../data/medication_service.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  List<ContainerModel> _containers = [];
  List<ScheduleModel> _schedules = [];
  int? _deviceId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final devices = await MedicationService.getDevices();
    if (!mounted || devices.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    _deviceId = devices.first.id;
    final results = await Future.wait([
      MedicationService.getContainers(_deviceId!),
      MedicationService.getSchedules(_deviceId!),
    ]);
    if (!mounted) return;
    setState(() {
      _containers = results[0] as List<ContainerModel>;
      _schedules = results[1] as List<ScheduleModel>;
      _loading = false;
    });
  }

  ScheduleModel? _nextScheduleFor(int containerNumber) {
    final now = DateTime.now();
    const dayMap = {1: 'MONDAY', 2: 'TUESDAY', 3: 'WEDNESDAY', 4: 'THURSDAY', 5: 'FRIDAY', 6: 'SATURDAY', 7: 'SUNDAY'};
    final today = dayMap[now.weekday]!;
    final nowMin = now.hour * 60 + now.minute;

    final relevant = _schedules
        .where((s) => s.containerNumber == containerNumber && s.isActive && s.daysOfWeek.contains(today))
        .toList()
      ..sort((a, b) {
        final aMin = (a.time['hour'] ?? 0) * 60 + (a.time['minute'] ?? 0);
        final bMin = (b.time['hour'] ?? 0) * 60 + (b.time['minute'] ?? 0);
        return aMin.compareTo(bMin);
      });

    for (final s in relevant) {
      if ((s.time['hour'] ?? 0) * 60 + (s.time['minute'] ?? 0) > nowMin) return s;
    }
    return relevant.isNotEmpty ? relevant.first : null;
  }

  int get _totalAdherence => 94;

  @override
  Widget build(BuildContext context) {
    final active = _containers.where((c) => c.isEnabled && (c.medicationName?.isNotEmpty ?? false)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        children: [
                          _buildAdherenceCard(),
                          const SizedBox(height: 16),
                          ...active.map((c) => _MedCard(
                            container: c,
                            nextSchedule: _nextScheduleFor(c.containerNumber),
                            onTap: () => context.go('/medications/${c.id}', extra: {'container': c, 'deviceId': _deviceId}),
                          )),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _deviceId != null ? context.go('/medications/add', extra: _deviceId) : null,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const DosysBottomNav(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.primaryLight, radius: 18, child: Icon(Icons.person_outline, color: AppColors.primary, size: 20)),
          const SizedBox(width: 12),
          const Text('Medications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const Spacer(),
          Icon(Icons.settings_outlined, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildAdherenceCard() {
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
          Text('WEEKLY HEALTH PULSE', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text('Adherence', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('$_totalAdherence%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(width: 4),
              Text('on track', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(7, (i) {
              final pct = [0.6, 0.8, 0.5, 1.0, 0.9, 0.7, 0.95][i];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: pct > 0.85 ? AppColors.primary : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MedCard extends StatelessWidget {
  final ContainerModel container;
  final ScheduleModel? nextSchedule;
  final VoidCallback onTap;

  const _MedCard({required this.container, this.nextSchedule, required this.onTap});

  double get _stockPercent {
    const maxPills = 30;
    return (container.remainingPills / maxPills).clamp(0.0, 1.0);
  }

  bool get _isCritical => container.remainingPills <= 5;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(container.medicationName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Comp ${container.containerNumber}', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.link_outlined, color: AppColors.textSecondary, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoCol(label: 'NEXT DOSE', value: nextSchedule?.timeLabel ?? '--'),
                _InfoCol(label: 'STOCK LEFT', value: '${container.remainingPills} Pills'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  _isCritical ? 'CRITICAL REFILL' : 'REFILL PROGRESS',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: _isCritical ? const Color(0xFFDC2626) : AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(_stockPercent * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isCritical ? const Color(0xFFDC2626) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _stockPercent,
                minHeight: 6,
                backgroundColor: AppColors.inputFill,
                valueColor: AlwaysStoppedAnimation(
                  _isCritical ? const Color(0xFFDC2626) : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCol extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, letterSpacing: 1, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
