import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/legal_content_modal.dart';
import '../../core/widgets/terms_validation_modal.dart';
import '../../widgets/red_header_background.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url : $e');
    }
  }

  void _showPolicy(String title, String content) {
    LegalContentModal.show(context, title: title, content: content);
  }

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Red background fond_page.png ──
          const Positioned.fill(
            child: RedHeaderBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(top: 25.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header (Back Button & Title) ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: 20.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Help Center',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        SizedBox(width: 42.r),
                      ],
                    ),
                  ),

                  // ── Content ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tell us how we can help 👋\nChapters are standing by for service & support!',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w400,
                              fontSize: 15.sp,
                              color: const Color(0xFF0F172A),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Email Card
                          _buildContactCard(
                            icon: Icons.mail_outline_rounded,
                            title: 'Email',
                            subtitle: 'Send to your email',
                            onTap: () => _openUrl('mailto:contact@cookedapp.com'),
                          ),
                          SizedBox(height: 14.h),

                          // Phone Card
                          _buildContactCard(
                            icon: Icons.phone_outlined,
                            title: 'Phone Number',
                            subtitle: 'Send to your phone',
                            onTap: () => _openUrl('tel:+1234567890'),
                          ),
                          SizedBox(height: 28.h),

                          // Legal Policies
                          Text(
                            'Legal & Policies',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 2.3,
                            children: [
                              _PolicyButton(
                                icon: Icons.description_outlined,
                                label: 'Terms & Conditions',
                                onTap: () => _showPolicy('Terms & Conditions', dummyTerms),
                              ),
                              _PolicyButton(
                                icon: Icons.receipt_long_outlined,
                                label: 'Refund Policy',
                                onTap: () => _showPolicy('Refund & Cancellation', dummyRefund),
                              ),
                              _PolicyButton(
                                icon: Icons.policy_outlined,
                                label: 'Privacy Policy',
                                onTap: () => _showPolicy('Privacy Policy', dummyPrivacy),
                              ),
                              _PolicyButton(
                                icon: Icons.cookie_outlined,
                                label: 'Cookie Policy',
                                onTap: () => _showPolicy('Cookie Policy', dummyCookies),
                              ),
                            ],
                          ),
                          SizedBox(height: 28.h),

                          // FAQ Section
                          Text(
                            'FAQ',
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          ..._faqs.map((faq) => _FaqItem(question: faq.$1, answer: faq.$2)),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22.sp,
                  color: const Color(0xFFC83A2D),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 13.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: const Color(0xFFC83A2D)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: const Color(0xFF0F172A),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.r),
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
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
            if (_expanded) ...[
              SizedBox(height: 10.h),
              Text(
                widget.answer,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
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
