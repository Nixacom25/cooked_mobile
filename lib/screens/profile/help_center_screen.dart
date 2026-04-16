import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

// ══════════════════════════════════════════════════════════════════════════════
// HELP CENTER SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final _scrollCtrl = ScrollController();

  // Total height of the expanded header (image area)
  double get _headerExpandedH => 130.0.h;
  // Height of the collapsed pinned bar (status bar height + compact bar)
  double get _collapsedBarH => 60.0.h;
  // How many px of scroll make the header fully collapse
  double get _collapseRange => _headerExpandedH - _collapsedBarH;

  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollCtrl.offset.clamp(0.0, _collapseRange);
    if (offset != _scrollOffset) setState(() => _scrollOffset = offset);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri))
      launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // 0.0 = expanded, 1.0 = fully collapsed
  double get _collapseFraction => _scrollOffset / _collapseRange;

  static const _faqs = [
    (
      'How do I import a recipe?',
      'Go to the Import tab, paste a link, or use the camera to scan a recipe.',
    ),
    (
      'Can I share my recipes?',
      'Yes! Open a recipe and tap the share button in the top right corner.',
    ),
    (
      'How do I create a cookbook?',
      'From the Home tab, tap the « + » button next to Your Cookbooks.',
    ),
    (
      'How do I change my password?',
      'Go to Profile → Security and enter your new password.',
    ),
    (
      'Is there a web version?',
      'No, Cooked is currently available as a mobile app only.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final statusH = MediaQuery.of(context).padding.top;

    // Progress values for individual elements
    final descOpacity = (1.0 - _collapseFraction * 2.5).clamp(0.0, 1.0);
    final titleSlide = _collapseFraction; // 0→1: subtitle slides up into bar

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable body ─────────────────────────────────────────────
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // Transparent spacer = header height
              SliverToBoxAdapter(
                child: SizedBox(height: _headerExpandedH + statusH),
              ),

              // ── Contact options ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ContactCard(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          subtitle: 'Send to your email',
                          onTap: () => _openUrl('mailto:support@cooked.com'),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _ContactCard(
                          icon: Icons.phone_rounded,
                          label: 'Phone Number',
                          subtitle: 'Send to your phone',
                          onTap: () => _openUrl('tel:+1234567890'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Legal policies grid ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 28.h, 18.w, 0),
                  child: Text(
                    'Legal & Policies',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14.w,
                    mainAxisSpacing: 14.h,
                    childAspectRatio: 2.5,
                    children: [
                      _PolicyButton(
                        icon: Icons.description_rounded,
                        label: 'Terms & Conditions',
                        onTap: () =>
                            _openUrl('https://cooked.com/terms-and-condition'),
                      ),
                      _PolicyButton(
                        icon: Icons.receipt_long_rounded,
                        label: 'Refund & Cancellation',
                        onTap: () => _openUrl(
                          'https://cooked.com/refund-and-cancellation',
                        ),
                      ),
                      _PolicyButton(
                        icon: Icons.policy_rounded,
                        label: 'Privacy Policy',
                        onTap: () =>
                            _openUrl('https://cooked.com/privacy-policy'),
                      ),
                      _PolicyButton(
                        icon: Icons.cookie_rounded,
                        label: 'Cookie Policy',
                        onTap: () =>
                            _openUrl('https://cooked.com/cookie-policy'),
                      ),
                    ],
                  ),
                ),
              ),

              // ── FAQs ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 32.h, 18.w, 12.h),
                  child: Text(
                    'FAQ',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) =>
                        _FaqItem(question: _faqs[i].$1, answer: _faqs[i].$2),
                    childCount: _faqs.length,
                  ),
                ),
              ),
            ],
          ),

          // ── Animated header overlay ────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _headerExpandedH + statusH - _scrollOffset,
            child: ClipRRect(
              borderRadius: _collapseFraction < 0.95
                  ? BorderRadius.vertical(bottom: Radius.circular(15.r))
                  : BorderRadius.zero,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  Image.asset(
                    'assets/images/fond4.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, 0.5],
                        colors: [Color(0xFFC83A2D), Color(0x63C83A2D)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Pinned floating bar (always on top) ────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: Duration.zero,
              color: _collapseFraction >= 0.98
                  ? Colors.white.withValues(alpha: 0.95)
                  : Colors.transparent,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: _collapsedBarH,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              size: 24.sp,
                              color: _collapseFraction >= 0.98
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        // Title always visible, changes color
                        Text(
                          'Help Center',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w800,
                            fontSize: 24.sp,
                            color: _collapseFraction >= 0.98
                                ? const Color(0xFF1A1A1A)
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Expanded header content (title + description, fades out) ───
          Positioned(
            top: statusH + _collapsedBarH,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: descOpacity,
              child: Transform.translate(
                offset: Offset(0, -titleSlide * 30),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tell us how we can help 👋\nChapter are standing by for service & support!',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w200,
                          fontSize: 16.sp,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Policy button tile ─────────────────────────────────────────────────────────
class _PolicyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PolicyButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 18.sp, color: const Color(0xFFCC3333)),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── FAQ expandable item ────────────────────────────────────────────────────────
class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: _expanded ? const Color(0xFFFFF5F5) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: _expanded
                ? const Color(0xFFCC3333).withValues(alpha: 0.3)
                : const Color(0xFFEEEEEE),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: _expanded
                          ? const Color(0xFFCC3333)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                  color: _expanded
                      ? const Color(0xFFCC3333)
                      : const Color(0xFF888888),
                ),
              ],
            ),
            if (_expanded) ...[
              SizedBox(height: 10.h),
              Text(
                widget.answer,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 13.sp,
                  color: const Color(0xFF555555),
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Contact card ───────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36.sp, color: const Color(0xFFC83A2D)),
            SizedBox(height: 24.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 13.sp,
                color: const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
