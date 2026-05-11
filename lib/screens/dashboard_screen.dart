import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/device_provider.dart';
import '../providers/energy_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/energy_chart.dart';
import 'devices_screen.dart';
import 'analytics_screen.dart';
import 'power_cut_screen.dart';
import 'chatbot_screen.dart';
import 'settings_screen.dart';
import 'alerts_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final energy = context.read<EnergyProvider>();
      final devices = context.read<DeviceProvider>();
      // Pass all required callbacks so overload check runs inside timer, not build
      energy.startSimulation(
        () => devices.totalActiveLoad,
        () => devices.mode,
        () => devices.devices,
        devices.toggleDevice,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _DashboardBody(),
      const DevicesScreen(),
      const AnalyticsScreen(),
      const PowerCutScreen(),
      const ChatbotScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E27), Color(0xFF020617)]),
        ),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1629),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, LucideIcons.home, 'Home'),
                _navItem(1, LucideIcons.cpu, 'Devices'),
                _navItem(2, LucideIcons.barChart2, 'Analytics'),
                _navItem(3, LucideIcons.zap, 'Power'),
                _navItem(4, LucideIcons.messageSquare, 'Chat'),
                _navItem(5, LucideIcons.settings, 'Settings'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final active = _currentIndex == index;
    final energy = context.watch<EnergyProvider>();
    final unread = energy.alerts.where((a) => !a.dismissed).length;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (active) Container(width: 28, height: 3, margin: const EdgeInsets.only(bottom: 4), decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(2))),
        Stack(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: active ? const Color(0xFF2563EB).withValues(alpha: 0.12) : Colors.transparent),
            child: Icon(icon, size: 20, color: active ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.4)),
          ),
          if (index == 3 && unread > 0) Positioned(right: 2, top: 0, child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFDC2626)))),
        ]),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.w500, color: active ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.4))),
      ]),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final energy = context.watch<EnergyProvider>();
    final devices = context.watch<DeviceProvider>();
    final activeDevices = devices.activeDevices;
    final unread = energy.alerts.where((a) => !a.dismissed).length;
    final mode = devices.mode;
    final userName = auth.user?.name ?? 'User';
    final firstName = userName.split(' ').first;

    // System status
    final statusColors = {'normal': const Color(0xFF22C55E), 'warning': const Color(0xFFEAB308), 'critical': const Color(0xFFDC2626)};
    final statusTexts = {'normal': 'All systems normal — operating within safe limits', 'warning': 'High load detected — monitor usage closely', 'critical': 'Overload detected — immediate action required'};
    final statusIcons = {'normal': LucideIcons.checkCircle2, 'warning': LucideIcons.alertTriangle, 'critical': LucideIcons.xOctagon};

    return SafeArea(
      child: Column(children: [
        // Premium header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [const Color(0xFF0F1A3E).withValues(alpha: 0.8), const Color(0xFF0A0E27).withValues(alpha: 0.6)],
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                // Avatar
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                    boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Center(child: Text(firstName[0].toUpperCase(), style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('Hey, $firstName ', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3)),
                    Text('👋', style: GoogleFonts.inter(fontSize: 16)),
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColors[energy.systemStatus])),
                    const SizedBox(width: 6),
                    Text(energy.systemStatus == 'normal' ? 'All systems running smoothly' : energy.systemStatus == 'warning' ? 'High load — monitor closely' : 'Overload — action required',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.5))),
                  ]),
                ]),
              ]),
              Row(children: [
                // Mode badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: mode == 'home' ? const Color(0xFF2563EB).withValues(alpha: 0.15) : const Color(0xFFEAB308).withValues(alpha: 0.15),
                    border: Border.all(color: mode == 'home' ? const Color(0xFF2563EB).withValues(alpha: 0.3) : const Color(0xFFEAB308).withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    Icon(mode == 'home' ? LucideIcons.home : LucideIcons.factory, size: 11, color: mode == 'home' ? const Color(0xFF2563EB) : const Color(0xFFEAB308)),
                    const SizedBox(width: 4),
                    Text(mode == 'home' ? 'Home' : 'Industry', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: mode == 'home' ? const Color(0xFF2563EB) : const Color(0xFFEAB308))),
                  ]),
                ),
                const SizedBox(width: 8),
                // Clickable alerts bell
                GestureDetector(
                  onTap: () => _showAlertsSheet(context, energy),
                  child: Stack(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withValues(alpha: 0.06), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                      child: Icon(LucideIcons.bell, size: 18, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    if (unread > 0) Positioned(right: 0, top: 0, child: Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFDC2626), border: Border.all(color: const Color(0xFF0A0E27), width: 2)),
                      child: Center(child: Text(unread > 9 ? '9+' : '$unread', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white))),
                    )),
                  ]),
                ),
              ]),
            ]),
          ]),
        ).animate().fadeIn(duration: 400.ms),

        // Status banner
        Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: statusColors[energy.systemStatus]!.withValues(alpha: 0.15),
          child: Row(children: [
            Icon(statusIcons[energy.systemStatus], size: 14, color: statusColors[energy.systemStatus]),
            const SizedBox(width: 8),
            Expanded(child: Text(statusTexts[energy.systemStatus]!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: statusColors[energy.systemStatus]))),
          ]),
        ),

        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // KPI cards
          Row(children: [
            _KpiCard(title: 'Energy Today', value: energy.totalEnergyToday.toStringAsFixed(1), unit: 'kWh', trend: 8, color: const Color(0xFF2563EB)),
            const SizedBox(width: 8),
            _KpiCard(title: 'Est. Cost', value: '₹${energy.estimatedCost.toStringAsFixed(0)}', trend: 5, color: const Color(0xFFEAB308)),
            const SizedBox(width: 8),
            _KpiCard(title: 'Efficiency', value: '${energy.efficiencyScore}', unit: '/100', trend: -3, color: const Color(0xFF22C55E)),
          ]).animate(delay: 200.ms).fadeIn(),

          const SizedBox(height: 16),

          // Live chart
          GlassCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Live Energy Usage', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 2),
                Text('kWh · updates every 3s', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
              ]),
              Row(children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF22C55E))),
                const SizedBox(width: 4),
                Text('Live', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF22C55E))),
              ]),
            ]),
            const SizedBox(height: 16),
            EnergyChart(data: energy.energyData),
          ])).animate(delay: 300.ms).fadeIn(),

          const SizedBox(height: 16),

          // Active Devices summary
          GlassCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Active Devices', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: const Color(0xFF2563EB).withValues(alpha: 0.15)),
                child: Text('${activeDevices.length} online', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB))),
              ),
            ]),
            const SizedBox(height: 10),
            ...activeDevices.take(3).map((d) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF22C55E))),
              const SizedBox(width: 8),
              Expanded(child: Text(d.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white), overflow: TextOverflow.ellipsis)),
              Text('${d.currentUsage.toStringAsFixed(1)} kWh', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.5))),
            ]))),
            if (activeDevices.length > 3) Padding(padding: const EdgeInsets.only(top: 6), child: Text('+${activeDevices.length - 3} more active', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)))),
            if (activeDevices.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('No active devices', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)))),
          ])).animate(delay: 400.ms).fadeIn(),

          const SizedBox(height: 16),

          // Quick actions
          GlassCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('QUICK ACTIONS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 1)),
            const SizedBox(height: 12),
            Row(children: [
              _ActionButton(label: 'Turn Off All', onTap: () { devices.turnOffAll(); energy.addTurnOffAllEvent(); }),
              const SizedBox(width: 8),
              _ActionButton(label: energy.autoPowerCut ? 'Auto-Cut: On' : 'Auto-Cut: Off', filled: energy.autoPowerCut, onTap: () => energy.setAutoPowerCut(!energy.autoPowerCut)),
            ]),
          ])).animate(delay: 500.ms).fadeIn(),

          const SizedBox(height: 16),

          // Active load bar
          GlassCard(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
            const Icon(LucideIcons.zap, size: 16, color: Color(0xFF2563EB)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Active Load', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('${devices.totalActiveLoad.toStringAsFixed(1)} / ${devices.threshold.toStringAsFixed(0)} kWh', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB))),
              ]),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
                value: (devices.totalActiveLoad / devices.threshold).clamp(0.0, 1.0), minHeight: 4,
                backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.15), valueColor: const AlwaysStoppedAnimation(Color(0xFF2563EB)))),
            ])),
          ])).animate(delay: 600.ms).fadeIn(),

          const SizedBox(height: 16),
        ]))),
      ]),
    );
  }

  void _showAlertsSheet(BuildContext context, EnergyProvider energy) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F1629),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            // Handle
            Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Notifications', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('${energy.alerts.where((a) => !a.dismissed).length} unread', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF2563EB))),
              ]),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
            Expanded(
              child: energy.alerts.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.bellOff, size: 32, color: Colors.white.withValues(alpha: 0.2)),
                      const SizedBox(height: 12),
                      Text('No notifications', style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.4))),
                    ]))
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: energy.alerts.length,
                      itemBuilder: (_, i) {
                        final alert = energy.alerts[i];
                        final severityColors = {'critical': const Color(0xFFDC2626), 'warning': const Color(0xFFEAB308), 'info': const Color(0xFF2563EB)};
                        final severityIcons = {'critical': LucideIcons.xOctagon, 'warning': LucideIcons.alertTriangle, 'info': LucideIcons.info};
                        final color = severityColors[alert.severity] ?? const Color(0xFF2563EB);
                        final icon = severityIcons[alert.severity] ?? LucideIcons.info;
                        final ago = DateTime.now().difference(alert.timestamp);
                        final timeStr = ago.inMinutes < 60 ? '${ago.inMinutes}m ago' : '${ago.inHours}h ago';

                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: alert.dismissed ? 0.4 : 1.0,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: color.withValues(alpha: 0.08),
                              border: Border.all(color: color.withValues(alpha: 0.15)),
                            ),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Icon(icon, size: 16, color: color),
                              const SizedBox(width: 10),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Expanded(child: Text(alert.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis)),
                                  Text(timeStr, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
                                ]),
                                const SizedBox(height: 4),
                                Text(alert.description, style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.6), height: 1.4)),
                                if (!alert.dismissed) ...[
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => energy.dismissAlert(alert.id),
                                    child: Text('Dismiss', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                                  ),
                                ],
                              ])),
                            ]),
                          ),
                        );
                      },
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title, value;
  final String? unit;
  final int trend;
  final Color color;
  const _KpiCard({required this.title, required this.value, this.unit, required this.trend, required this.color});

  @override
  Widget build(BuildContext context) {
    final trendUp = trend >= 0;
    final trendColor = trendUp ? const Color(0xFFDC2626) : const Color(0xFF22C55E);
    return Expanded(child: GlassCard(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 0.5)),
      const SizedBox(height: 8),
      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
        Flexible(child: Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: color), overflow: TextOverflow.ellipsis)),
        if (unit != null) Text(unit!, style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
      ]),
      const SizedBox(height: 6),
      Row(children: [
        Icon(trendUp ? LucideIcons.trendingUp : LucideIcons.trendingDown, size: 10, color: trendColor),
        const SizedBox(width: 2),
        Text('${trend.abs()}% vs avg', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: trendColor)),
      ]),
    ])));
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _ActionButton({required this.label, this.filled = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
        color: filled ? const Color(0xFF2563EB) : Colors.transparent,
        border: filled ? null : Border.all(color: Colors.white.withValues(alpha: 0.15))),
      child: Center(child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: filled ? Colors.white : Colors.white.withValues(alpha: 0.7)))),
    )));
  }
}
