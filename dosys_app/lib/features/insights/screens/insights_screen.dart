import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: [
                  _buildAdherenceCard(),
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                  _buildTrendCard(),
                  const SizedBox(height: 16),
                  _buildStorageHealth(),
                  const SizedBox(height: 16),
                  _buildRefillPrediction(),
                  const SizedBox(height: 16),
                  _buildInventoryCard(),
                ],
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
          const Text('Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const Spacer(),
          Icon(Icons.settings_outlined, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildAdherenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CURRENT STATUS', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('94%', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('on track', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: 0.94,
                    strokeWidth: 12,
                    backgroundColor: AppColors.inputFill,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Monthly', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    Text('94%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.trending_up, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text('+2% vs July', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _StatCard(icon: Icons.check_circle_outline, label: 'Taken on Time', value: '128', color: AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(icon: Icons.cancel_outlined, label: 'Skip Count', value: '4', color: const Color(0xFFDC2626))),
      ],
    );
  }

  Widget _buildTrendCard() {
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
              const Text('Adherence Trend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                child: Text('Consistent', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          Text('Last 7 days performance', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [0.7, 0.5, 0.9, 1.0, 0.8, 0.95, 0.85].map((v) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: FractionallySizedBox(
                      heightFactor: v,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: v > 0.85 ? AppColors.primary : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) =>
              Text(d, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageHealth() {
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
              const Text('Storage Health', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('◇ 42% Avg', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [0.3, 0.6, 0.4, 0.9, 0.5, 0.7, 0.4].map((v) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: FractionallySizedBox(
                      heightFactor: v,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: v > 0.7 ? AppColors.primary : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Humidity peaked on Thursday. Ensure your Dosys Device is kept away from bathroom steam to maintain pill integrity.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildRefillPrediction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('REFILL PREDICTION', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
              const Text('3 refills predicted this week', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const Spacer(),
          Icon(Icons.link_outlined, color: Colors.white.withValues(alpha: 0.7)),
        ],
      ),
    );
  }

  Widget _buildInventoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 20, color: Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AVG INVENTORY', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const Text('Days remaining: 12 (Avg)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
