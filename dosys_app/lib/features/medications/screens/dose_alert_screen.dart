import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../data/medication_models.dart';

class DoseAlertScreen extends StatefulWidget {
  final int deviceId;
  final ScheduleModel schedule;
  final ContainerModel container;

  const DoseAlertScreen({
    super.key,
    required this.deviceId,
    required this.schedule,
    required this.container,
  });

  @override
  State<DoseAlertScreen> createState() => _DoseAlertScreenState();
}

class _DoseAlertScreenState extends State<DoseAlertScreen> {
  bool _confirming = false;

  Future<void> _confirmTaken() async {
    setState(() => _confirming = true);
    // POST intake event handled by device — navigate back with success
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD4EDD0), Color(0xFFF7FAF5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'SCHEDULED NOW',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.container.medicationName ?? 'Medication',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PillBadge('1 Pill'),
                  const SizedBox(width: 10),
                  _PillBadge('Comp ${widget.container.containerNumber}'),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Device Alert Active', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            'Dosys pillbox is playing audio reminder and flashing compartment ${widget.container.containerNumber}.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3A2A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2D5A27), Color(0xFF1A3A2A)],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A7C59),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.medication, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _confirming ? null : _confirmTaken,
                        icon: _confirming
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.check_circle_outline),
                        label: const Text('Confirm Taken', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text('Repeat Alert in 5m', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final String label;
  const _PillBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}
