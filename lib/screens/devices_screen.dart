import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/device_tile.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DeviceProvider>();
    final auth = context.watch<AuthProvider>();
    final loadPct = (devices.totalActiveLoad / devices.threshold * 100).clamp(0.0, 100.0);
    final loadColor = loadPct >= 100 ? const Color(0xFFDC2626) : loadPct >= 80 ? const Color(0xFFEAB308) : const Color(0xFF22C55E);
    final mode = auth.accountType;

    // Sync device mode with account type
    if (devices.mode != mode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => devices.setMode(mode));
    }

    return SafeArea(child: Column(children: [
      // Header
      Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Devices', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text('${devices.activeCount} of ${devices.devices.length} active', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
          ]),
          Row(children: [
            // Mode badge (read-only, shows current account type)
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
                Text(mode == 'home' ? 'Home Mode' : 'Industry Mode', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: mode == 'home' ? const Color(0xFF2563EB) : const Color(0xFFEAB308))),
              ]),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0xFF22C55E).withValues(alpha: 0.15)),
              child: Text('${devices.activeCount} On', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF22C55E))),
            ),
          ]),
        ]),
      ])).animate().fadeIn(duration: 400.ms),

      const SizedBox(height: 14),

      // Device list
      Expanded(child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: devices.devices.length,
        separatorBuilder: (_, i) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final d = devices.devices[i];
          return DeviceTile(device: d, onToggle: () => devices.toggleDevice(d.id)).animate(delay: Duration(milliseconds: 80 * i)).fadeIn().slideX(begin: 0.05);
        },
      )),

      // Load footer
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08)))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total Active Load', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            Text('${devices.totalActiveLoad.toStringAsFixed(1)} kWh', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: loadColor)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(
            value: loadPct / 100, minHeight: 5,
            backgroundColor: loadColor.withValues(alpha: 0.15), valueColor: AlwaysStoppedAnimation(loadColor))),
          const SizedBox(height: 4),
          Text('${loadPct.toStringAsFixed(0)}% of ${devices.threshold.toStringAsFixed(1)} kWh threshold', style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
        ]),
      ),
    ]));
  }
}
