# Simplistic Calculator - App Store Publishing Guide

## ✅ Completed Setup

The following has been prepared for you:

### 1. App Icon ✓
- **SVG Source**: `assets/icon.svg` - Professional calculator icon design
- **PNG Master**: `assets/icon.png` - 1024x1024 PNG export
- **All iOS Sizes**: Generated in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
  - 15 different icon sizes for all iOS devices
  - App Store 1024x1024 icon included

### 2. Privacy Manifest ✓
- **File**: `ios/Runner/PrivacyInfo.xcprivacy`
- Declares no data collection (compliant with iOS 17+ requirements)
- Ready for App Store submission

### 3. Support Website ✓
- **File**: `support/index.html`
- Professional support page with privacy policy
- **Next Step**: Deploy to GitHub Pages (instructions below)

### 4. Project Configuration ✓
- **pubspec.yaml**: Updated with flutter_launcher_icons dependency
- Ready for App Store build

---

## 📋 What You Need To Do Next

### Step 1: Deploy Support Website (5 minutes)

You have two options:

**Option A: Use this repository (Quick)**
1. The `support/index.html` file is ready
2. You can host it on GitHub Pages or any web hosting
3. For GitHub Pages from this repo:
   ```bash
   # Create a gh-pages branch or enable Pages in repo settings
   # Point to the support folder
   ```

**Option B: Create dedicated repository (Recommended)**
1. Create new GitHub repo: `simplistic-calculator-support`
2. Copy `support/index.html` to the root as `index.html`
3. Enable GitHub Pages in repository settings
4. Your URL will be: `https://morriswong.github.io/simplistic-calculator-support/`

**UPDATE THE EMAIL**: Edit `support/index.html` line with `support@example.com` and replace with your actual email address.

---

### Step 2: Register Bundle ID in Apple Developer Portal (5 minutes)

1. Go to: https://developer.apple.com/account/resources/identifiers/list
2. Sign in with your Apple Developer account
3. Click the "+" button to add new Identifier
4. Select "App IDs" → Click "Continue"
5. Select "App" → Click "Continue"
6. Fill in:
   - **Description**: `Simplistic Calculator`
   - **Bundle ID**: Select "Explicit"
   - **Enter**: `com.morriswong.calculator`
7. Leave capabilities as default
8. Click "Continue" → Click "Register"

---

### Step 3: Update Bundle ID in Xcode (5 minutes)

1. Open the project in Xcode:
   ```bash
   cd /Users/morriswong/Documents/github/samples/simplistic_calculator
   open ios/Runner.xcworkspace
   ```

2. In Xcode:
   - Wait for workspace to load
   - Click "Runner" in left Project Navigator (blue icon)
   - Select "Runner" under TARGETS
   - Go to "Signing & Capabilities" tab
   - Change "Bundle Identifier" from `com.example.simplisticCalculator` to:
     ```
     com.morriswong.calculator
     ```
   - Verify "Team" shows: **TC87DMJLQP**
   - If signing errors appear, click "Try Again"

3. Add Privacy Manifest to Xcode:
   - Right-click "Runner" folder in left navigator
   - Select "Add Files to 'Runner'..."
   - Navigate to: `ios/Runner/PrivacyInfo.xcprivacy`
   - ✓ Check "Copy items if needed"
   - ✓ Ensure "Runner" target is selected
   - Click "Add"

---

### Step 4: Build and Archive (15 minutes)

1. Still in Xcode, from the device dropdown at top, select:
   - **"Any iOS Device (arm64)"**
   - ⚠️ Do NOT select a Simulator

2. Clean the build:
   - Menu: Product → Clean Build Folder
   - Wait for completion

3. Create Archive:
   - Menu: Product → Archive
   - Wait 2-5 minutes for build to complete
   - Archives window will open automatically

---

### Step 5: Create App in App Store Connect (10 minutes)

1. Go to: https://appstoreconnect.apple.com
2. Click "My Apps"
3. Click "+" → "New App"
4. Fill in:
   - **Platforms**: ✓ iOS
   - **Name**: `Simplistic Calculator`
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select `com.morriswong.calculator` from dropdown
   - **SKU**: `calculator-001` (or any unique identifier)
   - **User Access**: Full Access
5. Click "Create"

---

### Step 6: Upload Build (10 minutes)

1. In Xcode Archives window:
   - Select your archive
   - Click "Distribute App" button
   - Select "App Store Connect"
   - Click "Next"
   - Select "Upload"
   - Click "Next"
   - Review signing: should show your team automatically
   - Click "Upload"
   - Wait 2-10 minutes (depends on internet speed)

2. Verify upload:
   - Go to App Store Connect
   - Your App → TestFlight tab
   - Under "iOS Builds" you should see: **Version 1.0.0 (1)**
   - Status: "Processing" → Changes to "Ready to Submit" after 5-15 minutes

---

### Step 7: Complete App Store Metadata (30 minutes)

1. In App Store Connect → Your App → App Store (left sidebar)

2. **App Information**:
   - **Name**: Simplistic Calculator
   - **Subtitle**: Scientific Calculator for iOS
   - **Privacy Policy URL**: Your GitHub Pages URL
   - **Category**: Utilities (Primary), Productivity (Secondary)

3. **Pricing and Availability**:
   - **Price**: Free
   - **Availability**: All countries

4. **App Privacy**:
   - Click "Get Started"
   - Question: "Does this app collect data from users?"
   - Answer: **No**
   - Click "Save"

5. **Prepare for Submission**:
   - Click on "1.0 Prepare for Submission"

6. **Description** (copy/paste):
   ```
   A simple, elegant scientific calculator app built with Flutter. Perfect for everyday calculations and advanced mathematical operations.

   Features:
   • Basic arithmetic operations (+, -, ×, ÷)
   • Scientific functions (sin, cos, tan, sqrt, power)
   • Arc trigonometric functions (arcsin, arccos, arctan)
   • Advanced operations (absolute value, sign, ceiling, floor)
   • Natural logarithm and exponential functions
   • Factorial and modulo operations
   • Calculation history to review past computations
   • Clean, intuitive interface

   Whether you need quick math for daily tasks or complex scientific calculations, Simplistic Calculator provides all the tools you need in a straightforward, user-friendly design.
   ```

7. **Keywords**:
   ```
   calculator,scientific,math,arithmetic,trigonometry,utility,simple,calc,mathematics
   ```

8. **Support URL**: Your GitHub Pages URL (e.g., `https://morriswong.github.io/simplistic-calculator-support/`)

9. **Marketing URL**: Leave blank (optional)

10. **Screenshots** (IMPORTANT):
    - You MUST provide screenshots
    - **Quick method**:
      ```bash
      open -a Simulator
      # Select iPhone 15 Pro Max
      # Run the app in the simulator
      # Take 3-5 screenshots (Cmd+S)
      ```
    - Upload to "6.5\" Display" section
    - Minimum: 3 screenshots
    - Show: Calculator screen, scientific functions, calculations

11. **Build**:
    - Click "Select a build before you submit your app"
    - Select: 1.0.0 (1)
    - Click "Done"

12. **Age Rating**:
    - Click "Edit"
    - Answer all questions (all should be "No" for a calculator)
    - Result will be: **4+** (Everyone)
    - Click "Done"

13. **App Review Information**:
    - **First Name**: Your first name
    - **Last Name**: Your last name
    - **Phone Number**: Your phone number
    - **Email**: Your email
    - **Sign-in Required**: No
    - **Notes**: "This is a scientific calculator app. No login required. Simply tap buttons to perform calculations."

14. **Version Release**:
    - Select "Manually release this version"

15. **Export Compliance**:
    - Select "No" (uses only standard encryption)

---

### Step 8: Submit for Review (1 minute)

1. Review all sections - ensure green checkmarks on all
2. Click "Add for Review" (top right)
3. Click "Submit to App Review"

**Timeline**:
- ⏳ Waiting for Review: 0-48 hours
- ⏳ In Review: 1-6 hours
- ⏳ Processing for App Store: 15-60 minutes
- ✅ Ready for Sale: LIVE!

---

## 🚀 Quick Command Reference

```bash
# Navigate to project
cd /Users/morriswong/Documents/github/samples/simplistic_calculator

# Open in Xcode
open ios/Runner.xcworkspace

# Run in Simulator (for screenshots)
open -a Simulator
# Then in Xcode: Product → Run (or Cmd+R)

# Take screenshots in Simulator
# Press Cmd+S while app is running
```

---

## ⚠️ Common Issues & Solutions

### "No provisioning profiles found"
- Solution: In Xcode → Preferences → Accounts → Download Manual Profiles

### "Archive is grayed out"
- Solution: Ensure "Any iOS Device (arm64)" selected, NOT simulator

### "Signing error"
- Solution: Xcode → Signing & Capabilities → Try Again button

### "Invalid Binary" email from Apple
- Check email for specific reason
- Common: Missing icons → Already generated ✓
- Common: Wrong architecture → Build for device, not simulator

### Screenshots rejected
- Must show actual app functionality
- Use iPhone 15 Pro Max simulator
- Take at least 3 different screens

---

## 📧 Support Site Email Update

**IMPORTANT**: Before deploying support site, update the email address:

Edit `support/index.html` line 106:
```html
<p><strong>Contact us:</strong> <a href="mailto:support@example.com">support@example.com</a></p>
```

Change `support@example.com` to your actual email address.

---

## ✅ Pre-Submission Checklist

Before submitting to App Store, verify:

- [ ] Bundle ID registered in Developer Portal (`com.morriswong.calculator`)
- [ ] Bundle ID updated in Xcode
- [ ] PrivacyInfo.xcprivacy added to Xcode project
- [ ] Support website deployed and accessible
- [ ] Email address updated in support site
- [ ] Build uploaded to App Store Connect
- [ ] All app metadata filled in App Store Connect
- [ ] At least 3 screenshots uploaded
- [ ] App Privacy set to "No data collection"
- [ ] Age Rating completed (should be 4+)
- [ ] Export Compliance answered
- [ ] Build selected for version

---

## 🎯 Your Bundle ID

**Bundle Identifier**: `com.morriswong.calculator`

Use this exact identifier in:
- Apple Developer Portal ✓ (you need to do this)
- Xcode Project ✓ (you need to do this)
- App Store Connect ✓ (you need to do this)

---

## 📱 App Information Summary

**Name**: Simplistic Calculator
**Bundle ID**: com.morriswong.calculator
**Version**: 1.0.0 (1)
**Category**: Utilities
**Price**: Free
**Privacy**: No data collection
**Age Rating**: 4+

---

## 🎉 Ready to Publish!

All code and assets are ready. Follow Steps 1-8 above to complete your App Store submission.

**Estimated total time**: 2-3 hours for first-time setup

Good luck with your first App Store app! 🚀
