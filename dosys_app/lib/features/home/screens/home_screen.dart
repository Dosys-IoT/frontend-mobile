import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/medications/data/medication_models.dart';
import '../../../features/medications/data/medication_service.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DeviceModel> _devices = [];
  List<ContainerModel> _containers = [];
  List<ScheduleModel> _schedules = [];
  Map<String, dynamic>? _environment;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final devices = await MedicationService.getDevices();
    if (!mounted) return;
    setState(() => _devices = devices);

    if (devices.isNotEmpty) {
      final deviceId = devices.first.id;
      final results = await Future.wait([
        MedicationService.getContainers(deviceId),
        MedicationService.getSchedules(deviceId),
        MedicationService.getLatestEnvironment(deviceId),
      ]);
      if (!mounted) return;
      setState(() {
        _containers = results[0] as List<ContainerModel>;
        _schedules = results[1] as List<ScheduleModel>;
        _environment = results[2] as Map<String, dynamic>?;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _todayLabel {
    final now = DateTime.now();
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  List<ScheduleModel> get _todaySchedules {
    const dayMap = {
      1: 'MONDAY', 2: 'TUESDAY', 3: 'WEDNESDAY',
      4: 'THURSDAY', 5: 'FRIDAY', 6: 'SATURDAY', 7: 'SUNDAY',
    };
    final today = dayMap[DateTime.now().weekday]!;
    return _schedules.where((s) => s.daysOfWeek.contains(today) && s.isActive).toList()
      ..sort((a, b) {
        final aMin = (a.time['hour'] ?? 0) * 60 + (a.time['minute'] ?? 0);
        final bMin = (b.time['hour'] ?? 0) * 60 + (b.time['minute'] ?? 0);
        return aMin.compareTo(bMin);
      });
  }

  ScheduleModel? get _nextSchedule {
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    for (final s in _todaySchedules) {
      final sMin = (s.time['hour'] ?? 0) * 60 + (s.time['minute'] ?? 0);
      if (sMin > nowMin) return s;
    }
    return _todaySchedules.isNotEmpty ? _todaySchedules.first : null;
  }

  ContainerModel? _containerFor(int number) {
    try {
      return _containers.firstWhere((c) => c.containerNumber == number);
    } catch (_) {
      return null;
    }
  }

  bool get _hasLowStock => _containers.any((c) => c.isEnabled && c.remainingPills < 10);

  @override
  Widget build(BuildContext context) {
    final device = _devices.isNotEmpty ? _devices.first : null;
    final humidity = _environment?['humidity'] as double?;
    final next = _nextSchedule;
    final nextContainer = next != null ? _containerFor(next.containerNumber) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(device)),
                    SliverToBoxAdapter(child: _buildEnvCard(device, humidity)),
                    if (_hasLowStock)
                      SliverToBoxAdapter(child: _buildLowStockAlert()),
                    if (next != null)
                      SliverToBoxAdapter(child: _buildNextDoseCard(next, nextContainer)),
                    SliverToBoxAdapter(child: _buildScheduleSection()),
                    SliverToBoxAdapter(child: _buildDeviceModules()),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const DosysBottomNav(currentIndex: 0),
    );
  }

  Widget _buildHeader(DeviceModel? device) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting, ${device?.name ?? 'there'}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_todayLabel  •  ${_todaySchedules.length} meds today',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            color: AppColors.textPrimary,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildEnvCard(DeviceModel? device, double? humidity) {
    final connected = device?.isConnected ?? false;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HUMIDITY', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.water_drop_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        humidity != null ? '${humidity.toStringAsFixed(0)}%' : '--',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text('Optimal', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.border),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DEVICE', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.sync, size: 18, color: connected ? AppColors.primary : AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          connected ? 'Connected' : 'Offline',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: connected ? AppColors.textPrimary : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlert() {
    final low = _containers.where((c) => c.isEnabled && c.remainingPills < 10).first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFED7AA)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFF97316), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Refill Needed Soon', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFFEA580C))),
                  Text(
                    'Compartment ${low.containerNumber} (${low.medicationName ?? 'Unknown'}) is low stock.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFF97316), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildNextDoseCard(ScheduleModel next, ContainerModel? container) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('NEXT DOSE UPCOMING', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Comp. #${next.containerNumber.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(next.timeLabel, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              container?.medicationName ?? 'Unknown',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            Text(
              container?.dosageLabel ?? '',
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Confirm Taken', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    final today = _todaySchedules;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Today's Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go('/medications'),
                child: Text('View full list', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (today.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No doses scheduled for today', style: TextStyle(color: AppColors.textSecondary)),
            ))
          else
            ...today.map((s) {
              final c = _containerFor(s.containerNumber);
              return _ScheduleTile(schedule: s, container: c);
            }),
        ],
      ),
    );
  }

  Widget _buildDeviceModules() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Device Modules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: List.generate(5, (i) {
              final num = i + 1;
              final c = _containerFor(num);
              return _ModuleTile(number: num, container: c);
            }),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final ScheduleModel schedule;
  final ContainerModel? container;

  const _ScheduleTile({required this.schedule, this.container});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(schedule.timeLabel.replaceAll(' AM', '').replaceAll(' PM', ''),
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          Container(
            width: 3,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(container?.medicationName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('Compartment ${schedule.containerNumber} • 1 Pill',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.more_horiz, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final int number;
  final ContainerModel? container;

  const _ModuleTile({required this.number, this.container});

  @override
  Widget build(BuildContext context) {
    final isEmpty = container == null || !container!.isEnabled || (container!.medicationName?.isEmpty ?? true);
    final isLow = !isEmpty && container!.remainingPills < 10;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isLow ? const Color(0xFFFED7AA) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isLow ? const Color(0xFFFFF7ED) : AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('$number', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isLow ? const Color(0xFFEA580C) : AppColors.primary)),
                ),
              ),
              const Spacer(),
              if (isLow)
                Text('REFILL', style: TextStyle(fontSize: 8, color: const Color(0xFFEA580C), fontWeight: FontWeight.bold, letterSpacing: 0.5))
              else if (!isEmpty)
                Text('ACTIVE', style: TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          if (isEmpty) ...[
            Text('Empty', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('No medication assigned', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
          ] else ...[
            Text(container!.medicationName ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('~${container!.remainingPills} pills', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
