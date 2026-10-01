import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/legal_content_modal.dart';
import '../../core/widgets/terms_validation_modal.dart';
import '../../widgets/glass_icon_button.dart';
import '../../widgets/red_header_background.dart';
import '../../core/theme/app_theme.dart';
import 'send_feedback_screen.dart';
import '../../core/l10n/l10n.dart';

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
    }
  }

  void _showPolicy(String title, String content) {
    LegalContentModal.show(context, title: title, content: content);
  }

  static List<(String, String)> _faqs(BuildContext context) {
    final l10n = context.l10n;
    return [
      (l10n.faqImportQ, l10n.faqImportA),
      (l10n.faqShareQ, l10n.faqShareA),
      (l10n.faqCookbookQ, l10n.faqCookbookA),
      (l10n.faqPasswordQ, l10n.faqPasswordA),
      (l10n.faqWebQ, l10n.faqWebA),
    ];
  }

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
                color: context.colors.surface,
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
                        GlassIconButton(
                          onTap: () => Navigator.pop(context),
                          size: 42.r,
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 20.sp,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            context.l10n.helpTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.sp,
                              color: context.colors.textPrimary,
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
                            context.l10n.helpHeadline,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w400,
                              fontSize: 15.sp,
                              color: context.colors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Email Card
                          _buildContactCard(
                            icon: Icons.mail_outline_rounded,
                            title: context.l10n.commonEmail,
                            subtitle: context.l10n.authSendToEmail,
                            onTap: () => _openUrl('mailto:contact@cookedapp.com'),
                          ),
                          SizedBox(height: 14.h),

                          // Phone Card
                          _buildContactCard(
                            icon: Icons.phone_outlined,
                            title: context.l10n.commonPhoneNumber,
                            subtitle: context.l10n.authSendToPhone,
                            onTap: () => _openUrl('tel:+1234567890'),
                          ),
                          SizedBox(height: 14.h),

                          // Feedback Card
                          _buildContactCard(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: context.l10n.helpSendFeedback,
                            subtitle: context.l10n.helpSendFeedbackSubtitle,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SendFeedbackScreen()),
                            ),
                          ),
                          SizedBox(height: 28.h),

                          // Legal Policies
                          Text(
                            context.l10n.helpLegal,
                            style: TextStyle(
                              fontFamily: 'Rubik',
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                              color: context.colors.textPrimary,
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
                                label: context.l10n.legalTerms,
                                onTap: () => _showPolicy(context.l10n.legalTerms, dummyTerms),
                              ),
                              _PolicyButton(
                                icon: Icons.receipt_long_outlined,
                                label: context.l10n.legalRefund,
                                onTap: () => _showPolicy(context.l10n.legalRefundCancellation, dummyRefund),
                              ),
                              _PolicyButton(
                                icon: Icons.policy_outlined,
                                label: context.l10n.commonPrivacyPolicy,
                                onTap: () => _showPolicy(context.l10n.commonPrivacyPolicy, dummyPrivacy),
                              ),
                              _PolicyButton(
                                icon: Icons.cookie_outlined,
                                label: context.l10n.legalCookies,
                                onTap: () => _showPolicy(context.l10n.legalCookies, dummyCookies),
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
                              color: context.colors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          ..._faqs(context).map((faq) => _FaqItem(question: faq.$1, answer: faq.$2)),
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
          color: context.colors.pageBackground,
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
                  color: context.colors.accent,
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
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 13.sp,
                    color: context.colors.textSecondary,
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
          color: context.colors.pageBackground,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: context.colors.accent),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: context.colors.textPrimary,
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
          color: context.colors.pageBackground,
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
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                  color: context.colors.textSecondary,
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
                  color: context.colors.textSecondary,
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
