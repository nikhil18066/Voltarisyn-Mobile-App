import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/energy_provider.dart';
import '../providers/device_provider.dart';
import '../widgets/glass_card.dart';

class PowerCutScreen extends StatelessWidget {
  const PowerCutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final energy = context.watch<EnergyProvider>();
    final devices = context.watch<DeviceProvider>();
    final threshold = devices.threshold;
    final loadPct = (devices.totalActiveLoad / threshold * 100).clamp(0.0, 100.0);
    final loadColor = loadPct >= 100 ? const Color(0xFFDC2626) : loadPct >= 80 ? const Color(0xFFEAB308) : const Color(0xFF22C55E);

    final statusCfg = {
      'normal': {'color': const Color(0xFF22C55E), 'title': 'Normal', 'msg': 'All systems operating within safe parameters.'},
      'warning': {'color': const Color(0xFFEAB308), 'title': 'Warning', 'msg': 'Load approaching threshold — consider reducing usage.'},
      'critical': {'color': const Color(0xFFDC2626), 'title': 'Critical', 'msg': 'Overload detected — immediate action required.'},
    };
    final cfg = statusCfg[energy.systemStatus]!;

    final eventCfg = {
      'cut': {'icon': LucideIcons.zap, 'color': const Color(0xFFDC2626), 'label': 'POWER CUT'},
      'restore': {'icon': LucideIcons.checkCircle2, 'color': const Color(0xFF22C55E), 'label': 'RESTORED'},
      'warning': {'icon': LucideIcons.alertTriangle, 'color': const Color(0xFFEAB308), 'label': 'WARNING'},
      'manual': {'icon': LucideIcons.info, 'color': const Color(0xFF2563EB), 'label': 'MANUAL'},
    };

    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Power Control', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text('Overload protection and event log', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
      ])).animate().fadeIn(),

      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        // Auto Power Cut toggle
        GlassCard(padding: const EdgeInsets.all(16), child: Column(children: [
          Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: energy.autoPowerCut ? const Color(0xFF2563EB).withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05)),
              child: Icon(energy.autoPowerCut ? LucideIcons.shieldCheck : LucideIcons.shieldOff, size: 18, color: energy.autoPowerCut ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.4))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Auto Power Cut', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 2),
              Text('Disables the highest-draw device when load exceeds threshold.', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.5), height: 1.4)),
            ])),
            GestureDetector(
              onTap: () => energy.setAutoPowerCut(!energy.autoPowerCut),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 48, height: 28,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: energy.autoPowerCut ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.2)),
                child: AnimatedAlign(duration: const Duration(milliseconds: 200), alignment: energy.autoPowerCut ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(width: 22, height: 22, margin: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 3)]))))),
          ]),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: energy.autoPowerCut ? const Color(0xFF22C55E).withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03), border: Border.all(color: energy.autoPowerCut ? const Color(0xFF22C55E).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05))),
            child: Text(energy.autoPowerCut ? 'Protection active — system will auto-respond to overloads' : 'Protection disabled — manual intervention required', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: energy.autoPowerCut ? const Color(0xFF22C55E) : Colors.white.withValues(alpha: 0.5)))),
        ])).animate(delay: 100.ms).fadeIn(),

        const SizedBox(height: 12),

        // Load meter
        GlassCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Current Load', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: loadPct / 100, minHeight: 10, backgroundColor: loadColor.withValues(alpha: 0.15), valueColor: AlwaysStoppedAnimation(loadColor))),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${devices.totalActiveLoad.toStringAsFixed(1)} kWh (${loadPct.toStringAsFixed(0)}%)', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: loadColor)),
            Text('Limit ${threshold.toStringAsFixed(1)} kWh', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _Legend(const Color(0xFF22C55E), 'Normal (<80%)'),
            const SizedBox(width: 12),
            _Legend(const Color(0xFFEAB308), 'Warning (80-99%)'),
            const SizedBox(width: 12),
            _Legend(const Color(0xFFDC2626), 'Critical (≥100%)'),
          ]),
        ])).animate(delay: 200.ms).fadeIn(),

        const SizedBox(height: 12),

        // System status
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: (cfg['color'] as Color).withValues(alpha: 0.1), border: Border.all(color: (cfg['color'] as Color).withValues(alpha: 0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cfg['title'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: cfg['color'] as Color)),
            const SizedBox(height: 4),
            Text(cfg['msg'] as String, style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
          ])).animate(delay: 300.ms).fadeIn(),

        const SizedBox(height: 12),

        // Manual power cut button
        GestureDetector(
          onTap: () { devices.turnOffAll(); energy.addManualPowerCutEvent(); },
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFFDC2626)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.zap, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text('Trigger Manual Power Cut', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ])),
        ).animate(delay: 400.ms).fadeIn(),

        const SizedBox(height: 12),

        // Event log
        GlassCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Event Log', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            GestureDetector(onTap: energy.clearPowerEvents, child: Row(children: [
              Icon(LucideIcons.trash2, size: 12, color: Colors.white.withValues(alpha: 0.4)),
              const SizedBox(width: 4),
              Text('Clear', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
            ])),
          ]),
          const SizedBox(height: 12),
          if (energy.powerEvents.isEmpty) Center(child: Column(children: [
            const SizedBox(height: 16),
            Icon(LucideIcons.checkCircle2, size: 24, color: const Color(0xFF22C55E).withValues(alpha: 0.6)),
            const SizedBox(height: 8),
            Text('No events recorded', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 16),
          ])),
          ...energy.powerEvents.take(5).map((event) {
            final ec = eventCfg[event.type]!;
            final timeStr = '${event.timestamp.hour > 12 ? event.timestamp.hour - 12 : event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')} ${event.timestamp.hour >= 12 ? 'PM' : 'AM'}';
            return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: (ec['color'] as Color).withValues(alpha: 0.08), border: Border.all(color: (ec['color'] as Color).withValues(alpha: 0.15))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(ec['icon'] as IconData, size: 14, color: ec['color'] as Color),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(ec['label'] as String, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: ec['color'] as Color, letterSpacing: 0.5)),
                    const SizedBox(width: 8),
                    Text(timeStr, style: GoogleFonts.inter(fontSize: 9, color: Colors.white.withValues(alpha: 0.4))),
                  ]),
                  const SizedBox(height: 4),
                  Text(event.message, style: GoogleFonts.inter(fontSize: 12, color: Colors.white, height: 1.4)),
                ])),
              ]));
          }),
        ])).animate(delay: 500.ms).fadeIn(),

        const SizedBox(height: 16),
      ]))),
    ]));
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend(this.color, this.label);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(fontSize: 9, color: Colors.white.withValues(alpha: 0.5))),
    ]);
  }
}
