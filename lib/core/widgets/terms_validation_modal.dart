import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'legal_content_modal.dart';

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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
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
                color: const Color(0xFFE5E7EB),
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
              color: const Color(0xFF0D1B3E),
              fontFamily: 'SF Pro',
            ),
          ),
          
          SizedBox(height: 12.h),
          
          Text(
            'Before continuing with social login, please review and accept our legal terms to protect your data.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF7B8190),
              fontFamily: 'SF Pro',
              height: 1.5,
            ),
          ),
          
          SizedBox(height: 32.h),
          
          // Checkbox Section
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24.r,
                  width: 24.r,
                  child: Checkbox(
                    value: _accepted,
                    activeColor: const Color(0xFFC83A2D),
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
                          color: const Color(0xFF4B5563),
                          fontFamily: 'SF Pro',
                        ),
                      ),
                      _linkText('Terms of Use', () {
                        LegalContentModal.show(context, 
                          title: 'Terms of Use', 
                          content: dummyTerms
                        );
                      }),
                      Text(
                        ' and ',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF4B5563),
                          fontFamily: 'SF Pro',
                        ),
                      ),
                      _linkText('Privacy Policy', () {
                        LegalContentModal.show(context, 
                          title: 'Privacy Policy', 
                          content: dummyPrivacy
                        );
                      }),
                      Text(
                        '.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF4B5563),
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
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: _accepted 
                ? () {
                    Navigator.pop(context);
                    widget.onAccepted();
                  }
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC83A2D),
                disabledBackgroundColor: const Color(0xFFE5E7EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                elevation: 0,
              ),
              child: Text(
                'Confirm and Continue',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _accepted ? Colors.white : const Color(0xFF9CA3AF),
                  fontFamily: 'SF Pro',
                ),
              ),
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20.h),
        ],
      ),
    );
  }

  Widget _linkText(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: const Color(0xFFC83A2D),
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          fontFamily: 'SF Pro',
        ),
      ),
    );
  }
}

const String dummyTerms = """
Effective Date: April 1, 2026

By using Cooked, you agree to the following terms.

1. Use of the App
Cooked provides AI-powered recipe recommendations.
You agree to use the App lawfully and not misuse the service.

2. Accounts
You may create an account using:
● Google login
● Apple login
● Email
You are responsible for maintaining account security.

3. Subscriptions
Cooked offers paid subscriptions:
● Monthly plan
● Annual plan
● 3-day free trial

Billing
● Payments are processed through Apple or Google
● Subscriptions automatically renew unless canceled

Cancellation
● Managed through your App Store or Google Play account
● No refunds except as required by platform policies

4. AI Disclaimer
Recipes and recommendations are generated by AI.
We do not guarantee:
● Accuracy
● Nutritional correctness
● Suitability for allergies
Users are responsible for verifying ingredients and safety.

5. User Content
You retain ownership of content you upload.
You grant Cooked a license to use it to provide the service.

6. Limitation of Liability
Cooked is provided “as is”.
We are not liable for:
● Errors in recipes
● Health issues related to food
● Service interruptions

7. Termination
We may suspend or terminate accounts for misuse.

8. Changes to Terms
We may update these terms at any time.

9. Contact
Cooked Technologies, Inc
  Email: contact@cookedapp.com
""";

const String dummyRefund = """
Effective Date: April 1, 2026

Refunds and Cancellations

1. Refund Policy
Since Cooked provides digital services and a 3-day free trial, we generally do not offer refunds once a subscription has been processed. 
However, exceptions may be made in accordance with Apple App Store or Google Play Store policies.

2. How to Cancel
You can cancel your subscription at any time through your device's subscription management settings:
● iOS: Settings > Apple ID > Subscriptions
● Android: Google Play Store > Profile > Payments & Subscriptions

3. Effects of Cancellation
If you cancel, you will continue to have access to premium features until the end of your current billing period.

4. Contact Support
If you encounter billing issues, please contact us at support@cooked.com.
""";

const String dummyCookies = """
Effective Date: April 1, 2026

Cookie Policy

1. What are Cookies?
Cookies are small text files used to store small pieces of information. They are stored on your device when the App is loaded.

2. How we use Cookies
We use cookies to:
● Keep you logged in
● Remember your preferences
● Analyze App performance
● Improve user experience

3. Your Choices
Most mobile devices allow you to control or disable cookies through settings. However, disabling cookies may affect the functionality of some features within Cooked.

4. Third-Party Cookies
We may use analytics providers (like Google Analytics) that use their own cookies to help us understand how the App is used.
""";

const String dummyPrivacy = """
Effective Date: April 1, 2026

Cooked Technologies, Inc (“Cooked”, “we”, “our”, or “us”) operates the Cooked mobile application (the “App”).
This Privacy Policy explains how we collect, use, and protect your information.

1. Information We Collect
We may collect:
Account Information
● Name
● Email address
● Phone number

User Content
● Photos you upload (e.g., fridge/pantry images)
● Saved recipes and preferences (dietary, cuisine, etc.)

Usage Data
● App interactions
● Analytics data (for performance and improvement)

2. How We Use Your Information
We use your data to:
● Provide and improve the App
● Generate recipes and recommendations
● Personalize your experience
● Process subscriptions
● Monitor performance and usage

3. AI Processing
Cooked uses artificial intelligence to power core features.
This includes:
● Processing images you upload to detect ingredients
● Generating recipes and recommendations
Your data may be securely processed by third-party AI providers solely to provide these features.
We do not sell your personal data.

4. Payments
All payments are processed through:
● Apple App Store
● Google Play Store
We do not store or process your payment information directly.

5. Data Storage
We store:
● Account information
● Saved recipes
● Preferences
We do not sell your personal data.

6. Data Sharing
We may share data only with:
● Service providers (e.g., AI processing, analytics)
● When required by law
We do not sell or rent user data.

7. Data Security
We take reasonable measures to protect your data, but no system is completely secure.

8. Children’s Privacy
Cooked is intended for users 13 years and older.
We do not knowingly collect data from children under 13.

9. Your Rights
You may:
● Request deletion of your data
● Contact us for any privacy concerns
Email: contact@cookedapp.com

10. Changes
We may update this policy. Continued use means acceptance of updates.
""";
