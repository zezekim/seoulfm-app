import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seoulfm/config.dart';
import 'package:seoulfm/state/app_state.dart';
import 'package:seoulfm/state/channel_controller.dart';
import 'package:seoulfm/state/support_store.dart';
import 'package:seoulfm/theme.dart';
import 'package:seoulfm/ui/icons.dart';
import 'package:seoulfm/ui/widgets/common.dart';
import 'package:url_launcher/url_launcher.dart';

/// Support: the site's page (no ads, no paywall, where it goes, what stays the same), with the
/// ways to give through the App Store or Google Play: monthly, or a one-time tip. Nothing is
/// unlocked by supporting.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  late final SupportStore _store = context.read<AppState>().support;

  @override
  void initState() {
    super.initState();
    _store.start();
    _store.thanked.addListener(_thank);
  }

  @override
  void dispose() {
    _store.thanked.removeListener(_thank);
    super.dispose();
  }

  void _thank() {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    showModalBottomSheet<void>(context: context, useRootNavigator: true, builder: (_) => const _Thanks());
  }

  Future<void> _open(String path) =>
      launchUrl(Uri.parse('${Config.siteUrl}$path'), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    final l = context.l;
    final accent = context.watch<ChannelController>().active.color;
    return Scaffold(
      body: ListenableBuilder(
        listenable: _store,
        builder: (context, _) => CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: c.bg,
              surfaceTintColor: Colors.transparent,
              title: Text(l.support),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.supportEyebrow.toUpperCase(), style: eyebrow(context, color: accent)),
                    const SizedBox(height: 12),
                    Text(
                      l.supportH1,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        height: 1.05,
                      ),
                    ),
                    Text(
                      l.supportH1Sub,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        height: 1.05,
                        color: c.muted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(l.supportLead, style: TextStyle(fontSize: 16, height: 1.5, color: c.muted)),
                    const SizedBox(height: 26),
                    if (_store.supporter) _SupporterBadge(accent: accent),
                    _Options(store: _store, accent: accent),
                    if (_store.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(_store.error!, style: const TextStyle(color: Color(0xFFFF5A5F), fontSize: 13)),
                      ),
                    // Restore and the subscription's terms only mean something once the store is up.
                    if (_store.available) ...[
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton.icon(
                          onPressed: _store.available ? _store.restore : null,
                          icon: const Icon(AppIcons.restore, size: 16),
                          label: Text(l.supportRestore),
                        ),
                      ),
                      Text(
                        l.supportSubscriptionTerms,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: c.faint, height: 1.4),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => _open('/terms/'),
                            child: Text(l.terms, style: const TextStyle(fontSize: 12)),
                          ),
                          Text('·', style: TextStyle(color: c.faint)),
                          TextButton(
                            onPressed: () => _open('/privacy/'),
                            child: Text(l.privacy, style: const TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: SectionHeader(l.supportWhereItGoes)),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _Fact(icon: AppIcons.radio, title: l.supportCostStreamTitle, body: l.supportCostStreamBody),
                  _Fact(icon: AppIcons.music, title: l.supportCostLibraryTitle, body: l.supportCostLibraryBody),
                  _Fact(icon: AppIcons.support, title: l.supportCostWorkTitle, body: l.supportCostWorkBody),
                ],
              ),
            ),
            SliverToBoxAdapter(child: SectionHeader(l.supportStaysTheSame)),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  for (final p in [l.supportPromiseNoAds, l.supportPromiseNothingLocked, l.supportPromiseOptional])
                    ListTile(
                      leading: Icon(AppIcons.check, color: accent),
                      title: Text(p, style: const TextStyle(fontSize: 15, height: 1.35)),
                    ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                child: Text(l.supportFreeWays, style: TextStyle(fontSize: 13.5, color: c.muted, height: 1.5)),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 32)),
          ],
        ),
      ),
    );
  }
}

class _SupporterBadge extends StatelessWidget {
  const _SupporterBadge({required this.accent});
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(Radii.md)),
    child: Row(
      children: [
        Icon(AppIcons.supporter, color: accent, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(context.l.supportYouAreSupporter, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}

/// Monthly first and highlighted, then the three tips.
class _Options extends StatelessWidget {
  const _Options({required this.store, required this.accent});
  final SupportStore store;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.sfm;
    if (store.started && !store.available) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(Radii.lg)),
        child: Row(
          children: [
            Icon(AppIcons.support, color: c.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l.supportUnavailable, style: TextStyle(color: c.muted, height: 1.4)),
            ),
          ],
        ),
      );
    }
    final monthly = store.product(SupportStore.monthly);
    final tips = [
      (SupportStore.tips[0], AppIcons.coffee, l.supportTipSmall),
      (SupportStore.tips[1], AppIcons.gift, l.supportTipMedium),
      (SupportStore.tips[2], AppIcons.star, l.supportTipLarge),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Monthly: the accent card.
        Pressable(
          scale: 0.98,
          onTap: monthly == null || store.supporter ? null : () => store.buy(SupportStore.monthly),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [forWhiteText(accent), forWhiteText(Color.lerp(accent, Colors.black, 0.45)!)],
              ),
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.supportMonthly,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.supportMonthlyBody,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _PriceButton(
                  label: monthly == null ? '—' : l.supportPerMonth(monthly.price),
                  busy: store.pending == SupportStore.monthly,
                  done: store.supporter,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(l.supportOnce.toUpperCase(), style: eyebrow(context)),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < tips.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: _Tip(
                  icon: tips[i].$2,
                  label: tips[i].$3,
                  price: store.product(tips[i].$1)?.price,
                  busy: store.pending == tips[i].$1,
                  onTap: store.product(tips[i].$1) == null ? null : () => store.buy(tips[i].$1),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PriceButton extends StatelessWidget {
  const _PriceButton({required this.label, required this.busy, required this.done});
  final String label;
  final bool busy, done;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
    child: busy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF09090B)),
          )
        : done
        ? const Icon(AppIcons.check, size: 18, color: Color(0xFF09090B))
        : Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF09090B)),
          ),
  );
}

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.label, required this.price, required this.busy, required this.onTap});
  final IconData icon;
  final String label;
  final String? price;
  final bool busy;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: c.text),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            busy
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    price ?? '—',
                    style: TextStyle(color: c.muted, fontWeight: FontWeight.w600),
                  ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title, body;
  @override
  Widget build(BuildContext context) {
    final c = context.sfm;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 6, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.text.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Icon(icon, size: 20, color: c.text),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(body, style: TextStyle(color: c.muted, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thanks extends StatelessWidget {
  const _Thanks();
  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(28, 28, 28, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(AppIcons.support, size: 34, color: readableOn(accent)),
            ),
            const SizedBox(height: 16),
            Text(context.l.supportThanksTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              context.l.supportThanksBody,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.sfm.muted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(context.l.close)),
            ),
          ],
        ),
      ),
    );
  }
}
