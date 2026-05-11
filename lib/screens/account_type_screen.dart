import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/device_provider.dart';
import 'dashboard_screen.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E27), Color(0xFF020617)])),
        child: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: [
          const SizedBox(height: 60),
          Text('Choose Account Type', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 8),
          Text('This selection is locked after choosing.\nOnly the AI assistant can change it later.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.5), height: 1.5)).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 48),
          _TypeCard(icon: LucideIcons.home, title: 'Home', desc: 'Residential appliances\n8.0 kWh threshold', type: 'home').animate(delay: 300.ms).fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 16),
          _TypeCard(icon: LucideIcons.factory, title: 'Industry', desc: 'Industrial equipment\n35.0 kWh threshold', type: 'industry').animate(delay: 450.ms).fadeIn().slideX(begin: 0.1),
        ]))),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String type;
  const _TypeCard({required this.icon, required this.title, required this.desc, required this.type});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final auth = context.read<AuthProvider>();
        final devices = context.read<DeviceProvider>();
        await auth.setAccountType(type);
        devices.setMode(type);
        if (!context.mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
      },
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 28)),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text(desc, style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.5), height: 1.4)),
          ])),
          Icon(LucideIcons.chevronRight, color: Colors.white.withValues(alpha: 0.3), size: 20),
        ]),
      ),
    );
  }
}
