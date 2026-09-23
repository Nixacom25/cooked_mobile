# RevenueCat Setup Guide - Cooked App

## Overview
This guide provides step-by-step instructions for completing the RevenueCat integration for the Cooked app, including configuration for both iOS and Android platforms.

## Current Implementation Status

### ✅ Completed
- **RevenueCat SDK Integration**: Fully integrated in `mobile/lib/services/revenuecat_service.dart`
- **Paywall UI**: Enhanced to display real-time pricing and trial information from RevenueCat
- **Backend Webhook**: `RevenueCatWebhookController.java` handles subscription events
- **Trial Detection**: Backend correctly identifies trial vs. active subscriptions
- **Admin Interface**: Comprehensive subscription management panel in landing page
- **Sync Mechanism**: Mobile app syncs subscription status with backend via `/user/sync-subscription`

### ⏳ Requires Manual Configuration
- iOS App Store Connect subscription setup
- Google Play Console subscription setup
- RevenueCat dashboard configuration
- TestFlight/sandbox testing

## Platform-Specific Configuration

### iOS (App Store Connect)

#### 1. Create Subscription Products
1. Go to **App Store Connect** → Your App → Subscriptions
2. Create **Monthly Subscription**:
   - Product ID: `monthly_sub`
   - Subscription Group: Create a group (e.g., "Cooked Premium")
   - Price: $9.99/month
   - Free Trial: **0 days** (no trial)
   - Duration: 1 month
   - Auto-renewal: Yes

3. Create **Yearly Subscription**:
   - Product ID: `yearly_sub`
   - Subscription Group: Same as monthly
   - Price: $29.99/year
   - Free Trial: **3 days**
   - Duration: 1 year
   - Auto-renewal: Yes

#### 2. Configure RevenueCat for iOS
1. Go to **RevenueCat Dashboard** → Your Project → iOS Apps
2. Add your app with Bundle ID: `com.cookedapp.app`
3. Upload your **App Store Connect API Key**:
   - Generate in App Store Connect → Users and Access → Keys
   - Select "App Manager" role
   - Upload the `.p8` file to RevenueCat
4. Verify products are synced from App Store Connect

#### 3. TestFlight Testing
1. Create a TestFlight build with the updated app
2. Add internal test users
3. Test subscription flow:
   - Install TestFlight build
   - Navigate to paywall
   - Test monthly subscription (should charge immediately)
   - Test yearly subscription (should show 3-day trial)
   - Verify trial activation and post-trial behavior

### Android (Google Play Console)

#### 1. Create Subscription Products
1. Go to **Google Play Console** → Your App → Monetize → Subscriptions
2. Create **Monthly Subscription**:
   - Product ID: `monthly_sub`
   - Name: Monthly Premium
   - Price: $9.99/month
   - Trial period: **0 days** (no trial)
   - Billing period: 1 month
   - Renewal: Auto-renew

3. Create **Yearly Subscription**:
   - Product ID: `yearly_sub`
   - Name: Yearly Premium
   - Price: $29.99/year
   - Trial period: **3 days**
   - Billing period: 1 year
   - Renewal: Auto-renew

#### 2. Configure RevenueCat for Android
1. Go to **RevenueCat Dashboard** → Your Project → Android Apps
2. Add your app with Package Name: `com.cookedapp.app`
3. Upload your **Google Play Service Account JSON**:
   - Create service account in Google Cloud Console
   - Grant "View financial data" permission in Google Play Console
   - Download JSON key and upload to RevenueCat
4. Verify products are synced from Google Play Console

#### 3. Testing Setup
1. Create **Internal Test Track** in Google Play Console
2. Add internal tester accounts
3. Upload APK/AAB to internal test track
4. Test subscription flow with test accounts:
   - Install from internal test track
   - Test monthly subscription (immediate charge)
   - Test yearly subscription (3-day trial)
   - Verify sandbox behavior

## RevenueCat Dashboard Configuration

### 1. Entitlements Setup
- **Entitlement ID**: `premium`
- **Description**: Full access to Cooked app features
- **Products**: Link both `monthly_sub` and `yearly_sub` to this entitlement

### 2. Webhook Configuration
- **Webhook URL**: `https://cooked-backend-latest.onrender.com/subscriptions/revenuecat-webhook`
- **Webhook Secret**: Set in backend environment variable `REVENUECAT_WEBHOOK_SECRET`
- **Events to send**: All subscription events

### 3. App Configuration
- **iOS API Key**: `appl_KydPawFScfkuOWNyDtoJyTZHYnn` (already configured)
- **Android API Key**: `goog_sutqrppuWHniyEBbZUiQmkpHkds` (already configured)

## Testing Checklist

### Mobile App Testing
- [ ] Paywall displays correct pricing from RevenueCat
- [ ] Yearly subscription shows "3 days free" badge
- [ ] Monthly subscription shows no trial
- [ ] Purchase flow completes successfully
- [ ] Trial period activates correctly
- [ ] Post-trial charging works
- [ ] Restore purchases functions
- [ ] Subscription status syncs with backend
- [ ] Canceling subscription works
- [ ] Re-activating subscription works

### Backend Testing
- [ ] Webhook receives RevenueCat events
- [ ] Trial subscriptions set status to `TRIAL`
- [ ] Active subscriptions set status to `ACTIVE`
- [ ] Expiration events set status to `EXPIRED`
- [ ] Billing issue events send email notifications
- [ ] `/user/sync-subscription` endpoint works
- [ ] Admin panel shows correct subscription status

### Admin Interface Testing
- [ ] Subscriptions tab displays all users with subscriptions
- [ ] Subscription status colors are correct
- [ ] Can modify subscription status via admin panel
- [ ] RevenueCat customer ID is displayed
- [ ] Expiration dates are shown correctly

## Known Limitations & Considerations

### Trial Limitations
- Apple and Google have specific rules about trial eligibility
- Users may not be eligible for trials if they've previously subscribed
- Trial availability depends on region and account history

### Sandbox Testing
- TestFlight and Google Play internal testing use sandbox environments
- No real money is charged during testing
- Purchase flows may differ slightly from production
- Test purchases need to be reset periodically

### Regional Pricing
- Consider implementing regional pricing in App Store Connect
- RevenueCat supports localized pricing display
- Current implementation uses USD pricing

## Troubleshooting

### Common Issues

#### "No products found" error
- **Cause**: Products not synced with RevenueCat
- **Solution**: Wait for product sync (can take up to 24 hours after App Store/Google Play setup)

#### Trial not showing
- **Cause**: Trial period not configured in App Store Connect/Google Play Console
- **Solution**: Verify trial period settings in store consoles

#### Webhook not receiving events
- **Cause**: Webhook URL incorrect or secret mismatch
- **Solution**: Verify webhook URL and secret in RevenueCat dashboard

#### Subscription status not updating
- **Cause**: User not found by email or ID in webhook
- **Solution**: Ensure app uses consistent user IDs between mobile and backend

## Security Considerations

### API Keys
- **RevenueCat API Keys**: Already configured in code (public keys)
- **Webhook Secret**: Must be set as environment variable in backend
- **Store Credentials**: Keep Apple and Google service credentials secure

### Payment Security
- RevenueCat handles all payment processing securely
- Backend validates subscription status on each request
- Client-side subscription checks are for UI only (not security)

## Next Steps

1. **Configure App Store Connect** (iOS)
   - Create subscription products
   - Set up RevenueCat integration
   - Test with TestFlight

2. **Configure Google Play Console** (Android)
   - Create subscription products
   - Set up RevenueCat integration
   - Test with internal test track

3. **Production Deployment**
   - Verify all webhook endpoints are accessible
   - Set up webhook secret in production environment
   - Monitor initial subscription events
   - Set up billing issue monitoring

## Support Resources

- **RevenueCat Documentation**: https://docs.revenuecat.com/
- **Apple Subscription Guide**: https://developer.apple.com/in-app-purchase/
- **Google Play Billing**: https://developer.android.com/google/play/billing
- **Backend Webhook Reference**: See `RevenueCatWebhookController.java`

## Contact

For issues with this integration, refer to:
- Backend team for webhook and API issues
- Mobile team for app integration issues
- RevenueCat support for platform-specific issues