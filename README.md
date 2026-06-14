# UAPP Mobile

A Flutter mobile application for the **UAPP Communication Hub** — UK's student recruitment platform.

Built with **Flutter 3.44** · Targets **iOS** · Web preview available

---

## Screenshots

| Splash | Login | Feed | Messages |
|--------|-------|------|----------|
| Animated splash with UAPP logo | Email/password login | News Feed with 4 tabs | Chat threads with reactions |

| Schedule | Availability | Promotions | Settings |
|----------|--------------|------------|----------|
| Upcoming/Past calls + group meetings | Week agenda + work hours | Live commission campaigns | User mgmt, permissions, webhooks |

---

## Tech Stack

| | |
|---|---|
| Framework | Flutter 3.44.2 (Dart 3) |
| Platform target | iOS (primary) · Web (preview) |
| State management | `ValueNotifier` — no third-party packages |
| Localisation | Custom `t(key)` helper — EN / FR / BN / AR |
| Theme | Dark + Light modes via `ThemeMode` |

---

## Getting Started

### Prerequisites

```bash
# Install Flutter (macOS)
brew install --cask flutter

# Verify installation
flutter doctor
```

Xcode is required for iOS builds — install from the Mac App Store.

### Run (iOS Simulator)

```bash
git clone https://github.com/GUCAP/uapp-mobile.git
cd uapp-mobile
flutter pub get
flutter run          # picks up an available simulator/device
```

### Run (Web preview)

```bash
flutter build web --release
python3 -m http.server 3001 -d build/web
# Open http://localhost:3001
```

---

## Demo Accounts

Log in with any of these emails (any password works):

| Email | User | Role |
|-------|------|------|
| `rahman@gmail.com` | Shamim Rahman | CEO / System Admin |
| `olivia@gmail.com` | Olivia Becker | CEO / System Admin (Acme) |
| `shamim@gmail.com` | Md Shamim | Branch Manager (Sales) |
| `andreea@gmail.com` | Andreea Cinpoi | Sales Manager |
| `laura@gmail.com` | Laura Tomova | Sales Team Leader |
| `tousif@gmail.com` | Tousif Sadman | Consultant |
| `riad@gmail.com` | Riad Hossain | Consultant |
| `mihadul@gmail.com` | Mihadul Islam | Consultant |
| `asad@gmail.com` | Asad Fahad | Consultant |
| `jennifer@gmail.com` | Jennifer Aboje | Branch Manager (Admission) |
| `raj@gmail.com` | Raj Ahmed | Global Admission Manager |
| `nur@gmail.com` | Nur Mohammad | Admission Manager |
| `siam@gmail.com` | Md Siam | Admission Officer |
| `rakib@gmail.com` | Md Rakib | Admission Officer |
| `nadia@gmail.com` | Nadia Ahmed | Admission Officer |
| `thomas@gmail.com` | Thomas Fletcher | Admission Officer |
| `roni@gmail.com` | Md Roni | Admission Officer |

---

## Project Structure

```
lib/
├── core/
│   ├── theme.dart              # Dark + Light colour palettes, C(context) helper
│   ├── app_state.dart          # Global ValueNotifiers (theme, language, user)
│   └── translations.dart       # EN / FR / BN / AR strings
├── data/
│   └── mock_data.dart          # All seed data — replace with API later
├── models/
│   ├── user.dart               # AppUser
│   ├── message.dart            # ChatThread, ChatMessage
│   ├── meeting.dart            # Meeting, TimeSlot
│   └── post.dart               # FeedPost, PostCategory, PostReaction
├── screens/
│   ├── splash_screen.dart      # Animated splash → Login
│   ├── login_screen.dart       # Login with email/password
│   ├── shell_screen.dart       # Bottom nav shell (5 tabs)
│   ├── news_feed_screen.dart   # Feed: For You / Team / Company / Saved
│   ├── chat_list_screen.dart   # Message threads
│   ├── chat_view_screen.dart   # Individual conversation
│   ├── scheduled_calls_screen.dart
│   ├── schedule_call_screen.dart
│   ├── availability_screen.dart
│   ├── promotions_feed_screen.dart
│   ├── notifications_screen.dart
│   ├── profile_screen.dart
│   ├── new_meeting_screen.dart
│   ├── group_meeting_screen.dart
│   ├── post_composer_screen.dart
│   └── settings/
│       ├── settings_screen.dart
│       ├── user_management_screen.dart
│       ├── permissions_screen.dart
│       ├── templates_screen.dart
│       ├── webhooks_screen.dart
│       ├── feed_preferences_screen.dart
│       ├── timezone_screen.dart
│       └── promotions_screen.dart
└── widgets/
    ├── user_avatar.dart
    ├── message_bubble.dart
    ├── top_bar_actions.dart        # Bell + avatar shown on every screen
    └── floating_reaction_picker.dart  # Overlay emoji picker (FB/WA style)
```

---

## Features

### Completed ✅
- **Splash screen** — diagonal stripe background, UAPP app icon, god-ray beam, tagline
- **Login screen** — matches design, email/password auth, per-user accounts
- **News Feed** — 4 tabs, pinned posts, 15 post categories, reactions (floating picker), comments, share to chat, post composer with feelings/tag/photo/schedule/recurrence
- **Messages** — thread list (All/Unread/Groups/Favourites), chat view with reactions, reply, templates, attachments, message search, swipe-to-archive
- **Promotions** — live campaign cards with commission info, Apply Now, news tab
- **Schedule** — upcoming/past/canceled calls, pending invites (Accept/Decline), group meeting wizard (4-step), filter by type
- **Availability** — week agenda, work hours editor, away periods, Today jump, New Meeting FAB
- **Notifications** — full-page (5 filter tabs), time-grouped, avatar+type badge, swipe-to-dismiss
- **Profile** — dark/light mode toggle, language picker (4 languages), account settings
- **Settings** — User Management, Permissions, Group Templates, Webhooks, Feed Preferences, Work Hours & Timezone, Promotions & Commissions
- **Dark / Light mode** — full theme switching, all screens adapt
- **Language** — English · Français · বাংলা · العربية

---

## Brand

| Token | Value |
|-------|-------|
| Primary teal | `#008F91` |
| Teal light | `#05BEC0` |
| Orange CTA | `#FC7300` |
| Dark bg | `#001516` |
| Light bg | `#F0F9FA` |

---

© 2026 UAPP Ltd · [uapp.uk](https://uapp.uk)
