# Notification Icon Setup

This document explains how the `notilogo.png` notification icon has been set up for both Android and iOS platforms.

## Files Created/Modified

### Android Setup
1. **Icon Files Added:**
   - `android/app/src/main/res/drawable/notilogo.png` (main icon)
   - `android/app/src/main/res/drawable-hdpi/notilogo.png`
   - `android/app/src/main/res/drawable-mdpi/notilogo.png`
   - `android/app/src/main/res/drawable-xhdpi/notilogo.png`
   - `android/app/src/main/res/drawable-xxhdpi/notilogo.png`
   - `android/app/src/main/res/drawable-xxxhdpi/notilogo.png`

2. **AndroidManifest.xml Updates:**
   ```xml
   <!-- Firebase Messaging notification icon -->
   <meta-data
       android:name="com.google.firebase.messaging.default_notification_icon"
       android:resource="@drawable/notilogo" />
   
   <!-- Firebase Messaging notification color -->
   <meta-data
       android:name="com.google.firebase.messaging.default_notification_color"
       android:resource="@android:color/holo_purple" />
   
   <!-- Firebase Messaging notification channel -->
   <meta-data
       android:name="com.google.firebase.messaging.default_notification_channel_id"
       android:value="high_importance_channel" />
   ```

3. **Firebase Messaging Service:**
   - Created `MyFirebaseMessagingService.kt` for handling notifications

### iOS Setup
1. **Icon Files Added:**
   - `ios/Runner/Assets.xcassets/NotificationIcon.imageset/notilogo.png`
   - `ios/Runner/Assets.xcassets/NotificationIcon.imageset/Contents.json`

### Flutter Code Updates
1. **sendNotificationHandler.dart:**
   - Updated notification channel to use proper naming
   - Added iOS notification configuration
   - Enhanced notification details with icon and sound settings
   - Added test notification method

2. **Settings Page:**
   - Added test notification button to verify the icon works
   - Users can now test notifications from Settings → Game Preferences

## How to Test

1. **Local Test:**
   - Go to Settings in the app
   - Scroll to "Game Preferences" section
   - Tap the "Test" button next to "Test Notification"
   - Check your notification panel for the test notification with the icon

2. **Firebase Test:**
   - Send a push notification through Firebase Console
   - The notification should appear with the custom `notilogo.png` icon

## Technical Details

### Android
- Uses `@drawable/notilogo` as the notification icon
- Channel ID: `high_importance_channel`
- Channel Name: `Mindrena Notifications`
- Supports vibration and sound

### iOS
- Uses system notification handling
- Icon is included in app bundle
- Supports badge, sound, and alert

## Icon Requirements

### Android
- **Format:** PNG
- **Color:** Monochrome (white with transparent background recommended)
- **Size:** 24x24dp (but can be automatically scaled)
- **Background:** Transparent

### iOS
- **Format:** PNG
- **Size:** Various sizes (handled by iOS automatically)
- **Background:** Can be colored (iOS handles the styling)

## Troubleshooting

1. **Icon not showing on Android:**
   - Ensure the icon is in the correct drawable folders
   - Check that AndroidManifest.xml has the correct meta-data
   - Clear app data and reinstall

2. **Notifications not appearing:**
   - Check notification permissions
   - Verify Firebase configuration
   - Use the test button in Settings to debug

3. **iOS icon issues:**
   - Ensure the icon is properly added to Assets.xcassets
   - Check that Contents.json is correctly formatted

## Future Improvements

1. **Multiple Icon Sizes:** Create different sizes for better quality
2. **Adaptive Icons:** Use Android adaptive icon format
3. **Dark Mode Support:** Different icons for light/dark themes
4. **Rich Notifications:** Add action buttons and expandable content
