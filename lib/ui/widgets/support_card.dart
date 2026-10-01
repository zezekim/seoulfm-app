import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/nav.dart';
import 'package:seoulfm/ui/widgets/common.dart';

/// "Keep SeoulFM free": the way into Support, on Home and at the top of More. A supporter sees
/// a thank-you instead.
class SupportCard extends StatelessWidget {
  const SupportCard({super.key});
  @override
  Widget build(BuildContext context) {
    final accent = context.watch<ChannelController>().active.color;
    final store = context.read<AppState>().support;
    final l = context.l;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final fill = forWhiteText(Color.lerp(accent, Colors.black, 0.35)!);
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 4),
          child: Pressable(
            scale: 0.98,
            onTap: Nav.openSupport,
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 14, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [fill, forWhiteText(Color.lerp(fill, Colors.black, 0.45)!)],
                ),
                borderRadius: BorderRadius.circular(Radii.lg),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), shape: BoxShape.circle),
                    child: Icon(store.supporter ? AppIcons.supporter : AppIcons.support, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.supporter ? l.supportYouAreSupporter : l.supportCardTitle,
                          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        if (!store.supporter) ...[
                          const SizedBox(height: 2),
                          Text(
                            l.supportCardBody,
                            style: TextStyle(fontSize: 13, height: 1.35, color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
                    child: Text(
                      l.support,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF09090B)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
