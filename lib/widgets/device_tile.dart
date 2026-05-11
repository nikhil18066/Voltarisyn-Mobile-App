import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/device_model.dart';

class DeviceTile extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback onToggle;

  const DeviceTile({
    super.key,
    required this.device,
    required this.onToggle,
  });

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'wind':
        return LucideIcons.wind;
      case 'thermometer':
        return LucideIcons.thermometer;
      case 'rotate-cw':
        return LucideIcons.rotateCw;
      case 'lightbulb':
        return LucideIcons.lightbulb;
      case 'flame':
        return LucideIcons.flame;
      case 'zap':
        return LucideIcons.zap;
      case 'settings':
        return LucideIcons.settings;
      case 'cpu':
        return LucideIcons.cpu;
      case 'move-right':
        return LucideIcons.moveRight;
      case 'gauge':
        return LucideIcons.gauge;
      default:
        return LucideIcons.zap;
    }
  }

  @override
  Widget build(BuildContext context) {
    final usagePct = (device.currentUsage / 4.0 * 100).clamp(0.0, 100.0);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: device.isOn ? 1.0 : 0.55,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: device.isOn
                    ? const Color(0xFF2563EB).withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIcon(device.icon),
                size: 18,
                color: device.isOn
                    ? const Color(0xFF2563EB)
                    : Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          device.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (device.alwaysOn) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Always on',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (device.isOn) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: usagePct / 100,
                              minHeight: 3,
                              backgroundColor:
                                  const Color(0xFF2563EB).withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF2563EB)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${device.currentUsage.toStringAsFixed(1)} kWh',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      'Off',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Toggle
            GestureDetector(
              onTap: device.alwaysOn ? null : onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: device.isOn
                      ? const Color(0xFF2563EB)
                      : Colors.white.withValues(alpha: 0.2),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: device.isOn
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
