import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../widgets/glass_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _period = 'daily';

  static const _data = {
    'daily': [
      {'label': '6AM', 'usage': 3.2, 'cost': 27}, {'label': '8AM', 'usage': 5.8, 'cost': 49},
      {'label': '10AM', 'usage': 6.4, 'cost': 54}, {'label': '12PM', 'usage': 7.1, 'cost': 60},
      {'label': '2PM', 'usage': 8.3, 'cost': 71}, {'label': '4PM', 'usage': 7.6, 'cost': 65},
      {'label': '6PM', 'usage': 6.9, 'cost': 59}, {'label': '8PM', 'usage': 5.4, 'cost': 46},
      {'label': '10PM', 'usage': 4.1, 'cost': 35},
    ],
    'weekly': [
      {'label': 'Mon', 'usage': 42.3, 'cost': 360}, {'label': 'Tue', 'usage': 38.7, 'cost': 329},
      {'label': 'Wed', 'usage': 45.1, 'cost': 383}, {'label': 'Thu', 'usage': 41.8, 'cost': 355},
      {'label': 'Fri', 'usage': 47.3, 'cost': 402}, {'label': 'Sat', 'usage': 52.6, 'cost': 447},
      {'label': 'Sun', 'usage': 49.2, 'cost': 418},
    ],
    'monthly': [
      {'label': 'Jan', 'usage': 1240.0, 'cost': 10540}, {'label': 'Feb', 'usage': 1180.0, 'cost': 10030},
      {'label': 'Mar', 'usage': 1310.0, 'cost': 11135}, {'label': 'Apr', 'usage': 1290.0, 'cost': 10965},
      {'label': 'May', 'usage': 1350.0, 'cost': 11475}, {'label': 'Jun', 'usage': 1420.0, 'cost': 12070},
    ],
  };

  static const _summary = {
    'daily': {'kwh': '47.3', 'cost': '₹402', 'peak': '2 PM', 'avg': '5.3 kWh'},
    'weekly': {'kwh': '316.9', 'cost': '₹2,694', 'peak': 'Saturday', 'avg': '45.3 kWh'},
    'monthly': {'kwh': '7,790', 'cost': '₹66,215', 'peak': 'June', 'avg': '1,298 kWh'},
  };

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();
    final data = _data[_period]!;
    final summary = _summary[_period]!;
    final topDevices = deviceProvider.activeDevices..sort((a, b) => b.currentUsage.compareTo(a.currentUsage));
    final top5 = topDevices.take(5).toList();
    final maxUsage = top5.isEmpty ? 1.0 : top5.first.currentUsage;

    return SafeArea(child: Column(children: [
      // Header
      Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Analytics', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text('Energy consumption and cost breakdown', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
      ])).animate().fadeIn(),

      const SizedBox(height: 14),

      // Period tabs
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
        padding: const EdgeInsets.all(3), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white.withValues(alpha: 0.06)),
        child: Row(children: ['daily', 'weekly', 'monthly'].map((p) => Expanded(child: GestureDetector(
          onTap: () => setState(() => _period = p),
          child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: _period == p ? const Color(0xFF2563EB).withValues(alpha: 0.2) : Colors.transparent),
            child: Center(child: Text(p[0].toUpperCase() + p.substring(1), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _period == p ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.5))))),
        ))).toList()),
      )),

      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        // Chart
        GlassCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Usage vs Cost', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 2),
          Text('Bars = kWh · Line = ₹ cost', style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 16),
          SizedBox(height: 160, child: BarChart(BarChartData(
            barGroups: data.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(toY: (e.value['usage'] as num).toDouble(), color: const Color(0xFF2563EB), width: 14, borderRadius: const BorderRadius.only(topLeft: Radius.circular(3), topRight: Radius.circular(3))),
            ])).toList(),
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withValues(alpha: 0.05), strokeWidth: 1)),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox();
                return Text(data[i]['label'] as String, style: GoogleFonts.inter(fontSize: 9, color: Colors.white.withValues(alpha: 0.4)));
              })),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: GoogleFonts.inter(fontSize: 9, color: Colors.white.withValues(alpha: 0.4))))),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1E293B),
              getTooltipItem: (g, gi, r, ri) => BarTooltipItem('${r.toY.toStringAsFixed(1)} kWh', GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            )),
          ))),
          const SizedBox(height: 8),
          Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF2563EB).withValues(alpha: 0.85), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            Text('Usage (kWh)', style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(width: 16),
            Container(width: 10, height: 3, decoration: BoxDecoration(color: const Color(0xFFEAB308), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            Text('Cost (₹)', style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
          ]),
        ])).animate(delay: 200.ms).fadeIn(),

        const SizedBox(height: 12),

        // Summary stats
        Row(children: [
          _StatCard('Total kWh', summary['kwh']!),
          const SizedBox(width: 8),
          _StatCard('Total Cost', summary['cost']!),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _StatCard('Peak Period', summary['peak']!),
          const SizedBox(width: 8),
          _StatCard('Daily Avg', summary['avg']!),
        ]),

        const SizedBox(height: 12),

        // Top consuming devices
        GlassCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Top Consuming Devices', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 12),
          if (top5.isEmpty) Center(child: Text('No active devices', style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)))),
          ...top5.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Text('${e.key + 1}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.4))),
                const SizedBox(width: 8),
                Text(e.value.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
              ]),
              Text('${e.value.currentUsage.toStringAsFixed(1)} kWh', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB))),
            ]),
            const SizedBox(height: 4),
            ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(
              value: e.value.currentUsage / maxUsage, minHeight: 4,
              backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(Color.lerp(const Color(0xFF2563EB).withValues(alpha: 0.4), const Color(0xFF2563EB), 1.0 - e.key * 0.15)!),
            )),
          ]))),
        ])).animate(delay: 400.ms).fadeIn(),

        const SizedBox(height: 16),
      ]))),
    ]));
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  const _StatCard(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: GlassCard(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 0.5)),
      const SizedBox(height: 8),
      Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
    ])));
  }
}
