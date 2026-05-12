import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'legal_content_modal.dart';
import '../../widgets/red_button.dart';

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

1. Agreement to Terms
By accessing or using Cooked, you agree to be bound by these Terms of Service. If you do not agree, do not use the app.

2. Description of Service
Cooked is an AI-powered kitchen assistant that provides recipe recommendations based on user-provided ingredients through manual input or camera scanning.

3. User Accounts
To access most features, you must register for an account via Google, Apple, or Email. You are responsible for maintaining the confidentiality of your account.

4. Subscriptions and Payments
● Cooked offers Premium subscriptions (Monthly/Annual).
● Payments are handled exclusively by the Apple App Store or Google Play Store.
● Subscriptions automatically renew unless canceled 24 hours before the end of the period.

5. AI and Accuracy Disclaimer
Recipes are generated by Artificial Intelligence. We do not guarantee nutritional accuracy, ingredient safety (especially regarding allergies), or cooking results. Use at your own risk.

6. User Content and Camera
You may upload or take photos of ingredients. You grant us a non-exclusive license to process these images solely to provide the AI features.

7. Termination
We reserve the right to terminate access for any user who violates these terms or misuse the AI services.

8. Contact
Support: support@cookedapp.com
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

1. Usage
We use essential cookies and local storage to:
● Maintain your session.
● Remember your dietary preferences.
● Store your recently viewed recipes.

2. Analytics
We may use third-party analytics (like Google Analytics for Firebase) to understand app usage and improve performance.
""";

const String dummyPrivacy = """
Effective Date: April 1, 2026

Cooked Technologies ("we", "us", "our") is committed to protecting your privacy. This policy explains our data practices.

1. Information We Collect
● Account Data: Name, email address, and profile picture provided via social login.
● User Content: Images you take or upload of food ingredients.
● Usage Data: Information on how you interact with recipes and app features.

2. Permissions & Tool Usage
● Camera: We request access to your camera to allow you to scan ingredients directly. Photos are processed by our AI to identify food items.
● Storage: We access your photo gallery if you choose to upload a pre-existing image of your ingredients.

3. How We Use Data
● To generate personalized AI recipes.
● To manage your subscription status.
● To provide customer support and app updates.

4. Data Sharing & Security
● We DO NOT sell your personal data.
● Images are processed securely and are used solely for ingredient detection.
● Data is stored using industry-standard encryption.

5. Your Rights
You can request the deletion of your account and all associated data at any time via the app settings or by contacting us.

6. Children's Privacy
Our service is not intended for children under 13.

7. Contact Us
For any privacy-related questions: privacy@cookedapp.com
""";
