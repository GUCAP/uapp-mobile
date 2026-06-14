# UAPP Mobile — Setup Guide

## 1. Install Flutter (first time only)

```bash
# macOS — install via Homebrew
brew install --cask flutter

# Or download directly from https://flutter.dev/docs/get-started/install/macos
```

After installing, run:
```bash
flutter doctor
```
Fix any issues it flags (Xcode, CocoaPods, etc.)

## 2. Install Xcode (for iOS)

Open the Mac App Store and install **Xcode** (free).

Then accept the license:
```bash
sudo xcodebuild -license accept
```

Install CocoaPods:
```bash
sudo gem install cocoapods
```

## 3. Bootstrap the Flutter project

Open Terminal in this folder (`uapp_mobile/`) and run:

```bash
flutter create . --project-name uapp_mobile --org uk.uapp
```

This generates the iOS project files. Our Dart code in `lib/` is already there.

## 4. Install dependencies

```bash
flutter pub get
```

## 5. Run on iPhone Simulator

```bash
# Open iOS Simulator
open -a Simulator

# Run the app
flutter run
```

Or open `ios/Runner.xcworkspace` in Xcode and hit the Play button.

## Project Structure

```
lib/
├── main.dart                   # Entry point + bottom nav shell
├── core/
│   └── theme.dart              # Dark theme colours + AppTheme
├── models/
│   ├── user.dart               # AppUser model
│   ├── message.dart            # ChatMessage, ChatThread models
│   └── meeting.dart            # Meeting, TimeSlot models
├── data/
│   └── mock_data.dart          # All seed data (users, threads, meetings)
├── screens/
│   ├── chat_list_screen.dart   # Messages tab — thread list
│   ├── chat_view_screen.dart   # Individual conversation
│   ├── schedule_call_screen.dart  # Book a call (calendar + time slots)
│   ├── scheduled_calls_screen.dart # View upcoming/past/canceled calls
│   ├── news_feed_screen.dart   # Team news feed
│   └── profile_screen.dart     # User profile & settings
└── widgets/
    ├── user_avatar.dart         # Coloured initials avatar
    └── message_bubble.dart      # Chat bubbles + schedule call card
```

## Brand Colours

| Token        | Value     |
|-------------|-----------|
| Background  | #001516   |
| Surface     | #021D1F   |
| Primary Teal| #008F91   |
| Teal Light  | #05BEC0   |
| Orange CTA  | #FC7300   |
| Online      | #40E080   |
