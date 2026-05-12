import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<_AlertItem> _alerts = [
    _AlertItem(
      color: const Color(0xFFDC2626),
      title: 'Low stock - Comp 3',
      body: 'Only 4 doses remaining in Compartment 3. Please restock to ensure treatment continuity.',
      actions: ['OPEN MED', 'SNOOZE'],
      icon: Icons.warning_amber_rounded,
    ),
    _AlertItem(
      color: const Color(0xFFF97316),
      title: 'Refill needed - Lisinopril',
      body: 'Prescription refill for Lisinopril is required immediately. Pharmacy request initiated.',
      actions: ['OPEN MED', 'MARK RESOLVED'],
      icon: Icons.link_outlined,
    ),
    _AlertItem(
      color: const Color(0xFFEAB308),
      title: 'Humidity Warning - High (62%)',
      body: 'Internal chamber humidity exceeds safety threshold. Check device seal and desiccant pack.',
      actions: ['VIEW SENSORS'],
      icon: Icons.water_drop_outlined,
    ),
    _AlertItem(
      color: AppColors.primary,
      title: 'Buy more in 2 days',
      body: 'Based on your current consumption, you will need to reorder general supplies in 48 hours.',
      actions: ['ORDER NOW', 'DISMISS'],
      icon: Icons.shopping_cart_outlined,
    ),
    _AlertItem(
      color: AppColors.textSecondary,
      title: 'Treatment ending in 48h - Omega-3',
      body: 'Your 30-day Omega-3 regimen is concluding. Consult your physician for a renewal is needed.',
      actions: ['SNOOZE', 'VIEW LOGS'],
      icon: Icons.notifications_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: _alerts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _AlertCard(alert: _alerts[i]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DosysBottomNav(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          const Text('Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text('OPERATIONAL NOTICES', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const Spacer(),
          Icon(Icons.settings_outlined, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _AlertItem {
  final Color color;
  final String title;
  final String body;
  final List<String> actions;
  final IconData icon;

  const _AlertItem({
    required this.color,
    required this.title,
    required this.body,
    required this.actions,
    required this.icon,
  });
}

class _AlertCard extends StatelessWidget {
  final _AlertItem alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(color: alert.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(alert.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
              Icon(alert.icon, size: 18, color: alert.color),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(alert.body, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Row(
              children: alert.actions.map((a) {
                final isPrimary = alert.actions.indexOf(a) == 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isPrimary ? alert.color : AppColors.textSecondary,
                      side: BorderSide(color: isPrimary ? alert.color : AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(a, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
