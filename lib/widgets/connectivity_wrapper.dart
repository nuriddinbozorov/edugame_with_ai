import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleConnectivityChange(ConnectivityService service) {
    _hideTimer?.cancel();

    if (!service.isConnected) {
      // Offline — bannerni ko'rsat (yashirma)
      _controller.forward();
    } else if (service.wasOffline) {
      // Qayta ulandi — "tiklandi" xabarini ko'rsat, 2s keyin yashir
      _controller.forward();
      _hideTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          _controller.reverse();
          service.clearWasOffline();
        }
      });
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        // Animatsiyani boshqar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleConnectivityChange(connectivity);
        });

        return Stack(
          children: [
            widget.child,
            // Offline bo'lsa butun ekranni bloklash overlay
            if (!connectivity.isConnected)
              Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(color: Colors.transparent),
                ),
              ),
            // Yuqori banner
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnim,
                child: _ConnectivityBanner(
                  isConnected: connectivity.isConnected,
                  wasOffline: connectivity.wasOffline,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConnectivityBanner extends StatelessWidget {
  final bool isConnected;
  final bool wasOffline;

  const _ConnectivityBanner({
    required this.isConnected,
    required this.wasOffline,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = isConnected;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: isOnline
                    ? [const Color(0xFF16A34A), const Color(0xFF22C55E)]
                    : [const Color(0xFFDC2626), const Color(0xFFEF4444)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isOnline ? 'Internet tiklandi' : 'Internet mavjud emas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOnline
                            ? 'Davom etishingiz mumkin'
                            : 'Internetni yoqing va qayta urinib ko‘ring',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
