import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'legal_content_modal.dart';
import '../../widgets/red_button.dart';
import '../theme/app_theme.dart';

class TermsValidationModal extends StatefulWidget {
  final VoidCallback onAccepted;

  const TermsValidationModal({
    super.key,
    required this.onAccepted,
  });

  static void show(BuildContext context, {required VoidCallback onAccepted}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TermsValidationModal(onAccepted: onAccepted),
    );
  }

  @override
  State<TermsValidationModal> createState() => _TermsValidationModalState();
}

class _TermsValidationModalState extends State<TermsValidationModal> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        // Modals/sheets sit a step lighter than cards (elevatedSurface), so
        // this visibly separates from the page behind it in both themes.
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            'Terms & Conditions',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
              fontFamily: 'SF Pro',
            ),
          ),

          SizedBox(height: 12.h),

          Text(
            'Before continuing with social login, please review and accept our legal terms to protect your data.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: colors.textSecondary,
              fontFamily: 'SF Pro',
              height: 1.5,
            ),
          ),

          SizedBox(height: 32.h),

          // Checkbox Section
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: colors.pageBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24.r,
                  width: 24.r,
                  child: Checkbox(
                    value: _accepted,
                    activeColor: colors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                    onChanged: (val) => setState(() => _accepted = val ?? false),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Wrap(
                    children: [
                      Text(
                        'I have read and agree to the ',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: colors.textSecondary,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                      _linkText(context, 'Terms of Use', () {
                        LegalContentModal.show(context,
                          title: 'Terms of Use',
                          content: dummyTerms
                        );
                      }),
                      Text(
                        ' and ',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: colors.textSecondary,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                      _linkText(context, 'Privacy Policy', () {
                        LegalContentModal.show(context,
                          title: 'Privacy Policy',
                          content: dummyPrivacy
                        );
                      }),
                      Text(
                        '.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: colors.textSecondary,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 40.h),

          // Action Button
          RedButton(
            label: 'Confirm and Continue',
            isDisabled: !_accepted,
            onTap: () {
              Navigator.pop(context);
              widget.onAccepted();
            },
            height: 56.h,
            fontSize: 16.sp,
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
        ],
      ),
    );
  }

  Widget _linkText(BuildContext context, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: context.colors.accent,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          fontFamily: 'SF Pro',
        ),
      ),
    );
  }
}

const String dummyTerms = """
TERMS OF USE
Effective Date: September 23, 2026

1. Acceptance of Terms
By downloading and using the Cooked mobile application, you agree to be bound by these Terms of Use.

2. Description of Service
Cooked is a mobile application that provides recipe recommendations, meal planning, and grocery list features using artificial intelligence.

3. User Accounts
You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.

4. Intellectual Property
All content, features, and functionality of the App are owned by Cooked Technologies, Inc and are protected by international copyright, trademark, and other intellectual property laws.

5. User Conduct
You agree not to:
- Use the App for any illegal purpose
- Attempt to gain unauthorized access to the App or its related systems
- Interfere with or disrupt the App or servers

6. AI-Generated Content
The App uses artificial intelligence to generate recipes and recommendations. While we strive for accuracy, AI-generated content may not always be perfect.

7. Subscription and Payments
The App offers subscription-based features. All payments are processed through Apple App Store or Google Play Store according to their respective terms and conditions.

8. Privacy
Your use of the App is also governed by our Privacy Policy, which is incorporated into these Terms by reference.

9. Termination
We reserve the right to terminate or suspend your account at any time for violation of these Terms.

10. Disclaimer of Warranties
The App is provided "as is" without warranties of any kind, either express or implied.

11. Limitation of Liability
Cooked Technologies, Inc shall not be liable for any indirect, incidental, special, or consequential damages.

12. Changes to Terms
We reserve the right to modify these Terms at any time. Continued use of the App constitutes acceptance of the updated Terms.

Contact Us
For questions about these Terms: contact@cookedapp.com
""";

const String dummyRefund = """
Refund Policy

1. Digital Content
As Cooked provides immediate access to digital premium content and AI services, we generally do not offer refunds.

2. Platform Handling
All refund requests must be directed to the Apple App Store or Google Play Store, as we do not manage the billing directly.

3. Trials
The 3-day free trial allows you to test the service. If you do not wish to be charged, you must cancel at least 24 hours before the trial ends.
""";

const String dummyCookies = """
Cookie & Tracking Policy
Effective Date: April 1, 2026

1. Scope
Cooked is a mobile app, not a website, so we don't use browser cookies. This policy instead covers the local storage and tracking technologies the app itself uses on your device.

2. Essential Local Storage
We use on-device local storage (not shared with anyone) to:
● Keep you signed in between sessions.
● Remember your dietary preferences, allergies, and appearance (light/dark) settings.
● Store your recently viewed recipes and in-progress onboarding answers so you don't lose them.
● Cache recipe images so they load faster.

3. Analytics
We use Firebase Analytics to understand how the app is used (e.g. which screens are visited, feature usage, crash reports) so we can fix bugs and improve the experience. This data is tied to an anonymous device/installation identifier, not your name.

4. Subscription and Purchase Tracking
We use RevenueCat to manage and verify Premium subscriptions purchased through the Apple App Store or Google Play Store. RevenueCat receives your purchase receipt data to confirm your subscription status; it does not receive your payment details, which are handled entirely by Apple/Google.

5. Sign-In Providers
If you sign in with Google or Apple, those providers set their own identifiers to authenticate you. We only receive the name, email, and profile photo you authorize them to share.

6. Push Notifications
If you enable notifications, we use a device push token to deliver them. You can disable this anytime in your device settings or in-app Notification Preferences.

7. Your Choices
● You can reset advertising/analytics identifiers via your device's OS settings.
● You can clear locally stored data by logging out or deleting your account in Profile > Delete Account.
● You can disable push notifications at any time from your device settings.

8. Changes to This Policy
We may update this policy as we add or change features. Continued use of the app after an update means you accept the revised policy.

9. Contact
Questions about this policy: support@cookedapp.com
""";

const String dummyPrivacy = """
PRIVACY POLICY
Effective Date: September 23, 2026

Cooked Technologies, Inc ("Cooked", "we", "our", or "us") operates the Cooked mobile application (the "App").

This Privacy Policy explains how we collect, use, and protect your information.

1. Information We Collect
We may collect:
- Account Information: Name, email address, phone number
- User Content: Photos you upload (e.g., fridge/pantry images), saved recipes and preferences
- Usage Data: App interactions, analytics data (for performance and improvement)

2. How We Use Your Information
We use your data to:
- Provide and improve the App
- Generate recipes and recommendations
- Personalize your experience
- Process subscriptions
- Monitor performance and usage

3. AI Processing
Cooked uses artificial intelligence to power core features. This includes:
- Processing images you upload to detect ingredients
- Generating recipes and recommendations

Your data may be securely processed by third-party AI providers solely to provide these features. We do not sell your personal data.

4. Payments & Storage
Payments: All payments are processed through Apple App Store or Google Play Store. We do not store or process your payment information directly.

Data Storage: We store Account information, Saved recipes, and Preferences.
We do not sell your personal data.

5. Data Sharing & Security
We may share data only with service providers (e.g., AI processing, analytics) or when required by law.
We do not sell or rent user data.
We take reasonable measures to protect your data, but no system is completely secure.

6. Children's Privacy
Cooked is intended for users 13 years and older. We do not knowingly collect data from children under 13.

7. Your Rights & Changes
You may request deletion of your data or contact us for any privacy concerns. We may update this policy, and continued use means acceptance of updates.

Contact Us
For any questions or concerns about your privacy: contact@cookedapp.com
""";
