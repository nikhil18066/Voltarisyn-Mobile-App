import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/energy_provider.dart';
import '../providers/device_provider.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final energy = context.watch<EnergyProvider>();
    final devices = context.watch<DeviceProvider>();
    final mode = devices.mode;

    return SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: Align(alignment: Alignment.centerLeft,
        child: Text('Profile', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
      )).animate().fadeIn(),

      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        // User card
        GlassCard(padding: const EdgeInsets.all(16), child: Row(children: [
          Container(width: 52, height: 52, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2563EB)),
            child: Center(child: Text(
              (auth.user?.name ?? 'U').substring(0, 1).toUpperCase() + ((auth.user?.name ?? 'U').split(' ').length > 1 ? (auth.user?.name ?? 'U').split(' ').last.substring(0, 1).toUpperCase() : ''),
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(auth.user?.name ?? 'User', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 2),
            Text(auth.user?.email ?? '', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 6),
            Row(children: [
              Icon(LucideIcons.crown, size: 12, color: const Color(0xFFEAB308)),
              const SizedBox(width: 4),
              Text('Pro Plan', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFEAB308))),
            ]),
          ])),
        ])).animate(delay: 100.ms).fadeIn(),

        const SizedBox(height: 12),

        // Account type (read-only)
        GlassCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Account Type', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white.withValues(alpha: 0.04), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
            child: Row(children: [
              Icon(mode == 'home' ? LucideIcons.home : LucideIcons.factory, size: 18, color: const Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Text(mode == 'home' ? 'Home Mode' : 'Industry Mode', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: const Color(0xFFEAB308).withValues(alpha: 0.15)),
                child: Row(children: [
                  Icon(LucideIcons.lock, size: 10, color: const Color(0xFFEAB308)),
                  const SizedBox(width: 4),
                  Text('Locked', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFFEAB308))),
                ])),
            ])),
          const SizedBox(height: 8),
          Text('To change, ask the AI assistant', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.4), fontStyle: FontStyle.italic)),
        ])).animate(delay: 200.ms).fadeIn(),

        const SizedBox(height: 12),

        // Settings list
        GlassCard(padding: const EdgeInsets.all(0), child: Column(children: [
          _SettingRow(icon: LucideIcons.bell, iconBg: const Color(0xFF2563EB).withValues(alpha: 0.15), iconColor: const Color(0xFF2563EB), label: 'Notifications', sub: 'Alert push notifications',
            trailing: _Toggle(value: energy.notificationsEnabled, onChanged: energy.setNotificationsEnabled)),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          _SettingRow(icon: LucideIcons.zap, iconBg: const Color(0xFF22C55E).withValues(alpha: 0.15), iconColor: const Color(0xFF22C55E), label: 'Auto Power Cut', sub: 'Overload protection',
            trailing: _Toggle(value: energy.autoPowerCut, onChanged: energy.setAutoPowerCut)),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          _SettingRow(icon: LucideIcons.ruler, iconBg: const Color(0xFFEAB308).withValues(alpha: 0.15), iconColor: const Color(0xFFEAB308), label: 'Energy Threshold', sub: 'Overload trigger point',
            trailing: Text(mode == 'home' ? '8.0 kWh' : '35.0 kWh', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
        ])).animate(delay: 300.ms).fadeIn(),

        const SizedBox(height: 20),

        // Sign out
        GestureDetector(
          onTap: () async {
            await auth.logout();
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
          },
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.4))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.logOut, size: 16, color: Color(0xFFDC2626)),
              const SizedBox(width: 8),
              Text('Sign Out', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFDC2626))),
            ])),
        ).animate(delay: 400.ms).fadeIn(),

        const SizedBox(height: 16),
      ]))),
    ]));
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label, sub;
  final Widget trailing;
  const _SettingRow({required this.icon, required this.iconBg, required this.iconColor, required this.label, required this.sub, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: iconBg),
        child: Icon(icon, size: 16, color: iconColor)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
        Text(sub, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
      ])),
      trailing,
    ]));
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 48, height: 28,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: value ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.2)),
        child: AnimatedAlign(duration: const Duration(milliseconds: 200), alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 22, height: 22, margin: const EdgeInsets.all(3), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 3)])))),
    );
  }
}
