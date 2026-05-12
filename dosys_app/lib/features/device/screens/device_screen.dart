import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/medications/data/medication_models.dart';
import '../../../features/medications/data/medication_service.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<DeviceModel> _devices = [];
  List<ContainerModel> _containers = [];
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
      final id = devices.first.id;
      final results = await Future.wait([
        MedicationService.getContainers(id),
        MedicationService.getLatestEnvironment(id),
      ]);
      if (!mounted) return;
      setState(() {
        _containers = results[0] as List<ContainerModel>;
        _environment = results[1] as Map<String, dynamic>?;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = _devices.isNotEmpty ? _devices.first : null;
    final connected = device?.isConnected ?? false;
    final humidity = (_environment?['humidity'] as num?)?.toDouble();

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
                          _buildStatusCard(connected),
                          const SizedBox(height: 16),
                          _buildEnvCard(humidity),
                          const SizedBox(height: 16),
                          _buildCompartmentStatus(),
                          const SizedBox(height: 24),
                          _buildHelpCard(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DosysBottomNav(currentIndex: 2),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.primaryLight, radius: 18, child: Icon(Icons.person_outline, color: AppColors.primary, size: 20)),
          const SizedBox(width: 12),
          const Text('Dosys', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const Spacer(),
          Icon(Icons.settings_outlined, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool connected) {
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
              Text('HARDWARE STATUS', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: connected ? const Color(0xFFDCFCE7) : AppColors.inputFill,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  connected ? 'Online' : 'Offline',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: connected ? AppColors.primary : AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Device', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatusChip(Icons.wifi, 'Wi-Fi 5'),
              const SizedBox(width: 10),
              _StatusChip(Icons.bluetooth, 'BT 5.0'),
              const SizedBox(width: 10),
              _StatusChip(Icons.battery_full, '84%'),
              const Spacer(),
              Text('Last synced\n2m ago', style: TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.right),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnvCard(double? humidity) {
    final isGood = humidity != null && humidity < 60;
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
              Icon(Icons.home_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text('${humidity?.toStringAsFixed(0) ?? '--'}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('Internal Humidity', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isGood ? const Color(0xFFDCFCE7) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(isGood ? 'GOOD' : 'HIGH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isGood ? AppColors.primary : const Color(0xFFEA580C))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.volume_up_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text('VOLUME: 75%', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('TEST\nSPEAKER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompartmentStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Compartment Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._buildCompartmentTiles(),
      ],
    );
  }

  List<Widget> _buildCompartmentTiles() {
    return List.generate(5, (i) {
      final num = i + 1;
      ContainerModel? c;
      try {
        c = _containers.firstWhere((x) => x.containerNumber == num);
      } catch (_) {}

      final pills = c?.remainingPills ?? 0;
      final medName = c?.medicationName ?? '';
      final isEmpty = c == null || !c.isEnabled || medName.isEmpty;
      final isLow = !isEmpty && pills <= 5;
      final isEnding = !isEmpty && pills <= 10 && pills > 5;

      String statusLabel = isEmpty ? 'INACTIVE' : (isLow ? 'REFILL SOON' : (isEnding ? 'ENDING' : 'ACTIVE'));
      Color statusColor = isEmpty
          ? AppColors.textSecondary
          : isLow
              ? const Color(0xFFDC2626)
              : isEnding
                  ? const Color(0xFFF97316)
                  : AppColors.primary;

      final stockPct = isEmpty ? 0.0 : (pills / 30).clamp(0.0, 1.0);

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isEmpty ? AppColors.inputFill : AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  isEmpty ? Icons.add : Icons.medication_outlined,
                  color: isEmpty ? AppColors.textSecondary : AppColors.primary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(isEmpty ? 'Empty' : medName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const Spacer(),
                      Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(isEmpty ? '0 pills remaining' : '$pills pills remaining',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: stockPct,
                            minHeight: 4,
                            backgroundColor: AppColors.inputFill,
                            valueColor: AlwaysStoppedAnimation(isLow ? const Color(0xFFDC2626) : AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEmpty ? 'ASSIGN MEDICATION' : 'Calibrated',
                        style: TextStyle(fontSize: 10, color: isEmpty ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildHelpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.help_outline, size: 28, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          const Text('Need assistance?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Trouble connecting your Dosys Hub or calibrating scales?', style: TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OPEN DEVICE GUIDE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatusChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
