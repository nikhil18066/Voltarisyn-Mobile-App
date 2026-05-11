import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/gradient_button.dart';
import 'login_screen.dart';
import 'account_type_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _pass.dispose(); _confirm.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pass = _pass.text;
    final confirm = _confirm.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill all fields', style: GoogleFonts.inter()), backgroundColor: const Color(0xFFDC2626)));
      return;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid email address', style: GoogleFonts.inter()), backgroundColor: const Color(0xFFDC2626)));
      return;
    }

    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password must be at least 6 characters long', style: GoogleFonts.inter()), backgroundColor: const Color(0xFFDC2626)));
      return;
    }

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match', style: GoogleFonts.inter()), backgroundColor: const Color(0xFFDC2626)));
      return;
    }
    setState(() => _loading = true);
    await context.read<AuthProvider>().signup(name, email, pass);
    setState(() => _loading = false);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AccountTypeScreen()));
  }

  Widget _field(String label, TextEditingController c, String hint, {bool obscure = false, TextInputType type = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8))),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white.withValues(alpha: 0.06), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
        child: TextField(controller: c, obscureText: obscure, keyboardType: type, style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.3)), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
      width: double.infinity, height: double.infinity,
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E27), Color(0xFF020617)])),
      child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: [
        const SizedBox(height: 36),
        Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 6))]),
          child: const Icon(LucideIcons.zap, color: Colors.white, size: 28)).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: 20),
        Text('Create account', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)).animate(delay: 200.ms).fadeIn(),
        const SizedBox(height: 6),
        Text('Start optimizing your energy today', style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.5))).animate(delay: 300.ms).fadeIn(),
        const SizedBox(height: 32),
        _field('Full name', _name, 'Alex Johnson'),
        const SizedBox(height: 16),
        _field('Email address', _email, 'alex@company.com', type: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _field('Password', _pass, '••••••••', obscure: true),
        const SizedBox(height: 16),
        _field('Confirm password', _confirm, '••••••••', obscure: true),
        const SizedBox(height: 28),
        GradientButton(text: 'Create Account', onPressed: _signup, isLoading: _loading).animate(delay: 400.ms).fadeIn(),
        const SizedBox(height: 28),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Already have an account? ", style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
          GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
            child: Text('Sign in', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)))),
        ]),
        const SizedBox(height: 32),
      ]))),
    ));
  }
}
