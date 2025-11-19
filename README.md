# property_app

---

## Project Description
A cross-platform property listing application built with Flutter, BLoC architecture, and Clean Code principles**. Browse properties with advanced filtering, track analytics, manage user profiles, and switch between light and dark themes seamlessly.

### Key Features
- Browse properties with infinite scrolling and lazy loading
- Advanced filtering by price range, location, status, and tags
- Analytics dashboard to track views, interactions, and time spent
- Light and dark theme support with persistent storage
- Performance optimization with caching and minimal API calls
- Responsive design for mobile and desktop
- FCM Notifications implemented for push messages

---

## Setup Instructions

### Prerequisites
- Flutter 3.0.0 or higher
- Dart 3.0.0 or higher
- Android SDK API level 21 or higher
- Xcode 12.0 or higher (for iOS)
- Internet connection for API access

### Git Repository
- https://github.com/Catherine1003/property_app.git

---

## Project Structure
property_app/
├── lib/
│   ├── config/                # App-wide configurations
│   ├── features/
│   │   ├── property/
│   │   │   ├── data/
│   │   │   │   ├── datasource/    # API and local data sources
│   │   │   │   ├── models/        # Data models
│   │   │   │   └── repository/    # Repository implementations
│   │   │   ├── domain/
│   │   │   │   └── entities/      # Business entities
│   │   │   └── presentation/
│   │   │       ├── bloc/          # State management
│   │   │       ├── pages/         # Screens / Pages
│   │   │       └── widgets/       # Reusable UI components
│   │   └── theme/
│   │       ├── data/
│   │       │   ├── datasource/
│   │       │   ├── models/
│   │       │   └── repository/
│   │       ├── domain/
│   │       │   └── entities/
│   │       └── presentation/
│   │           ├── bloc/
│   │           ├── pages/
│   │           └── widgets/
│   └── main.dart              # App entry point
├── pubspec.yaml               # Dependencies & configurations
└── .gitignore                 # Git ignore rules

---

## API Integration

Base URL: http://147.182.207.192:8003/properties

Integration Flow:
User Action → BLoC → Repository → API Service → API → Response → DataModel → Domain Entity → BLoC State → UI

Error Handling: Implemented at service, repository, and BLoC levels.

Offline Strategy: Caching and local storage for image capture and themes.
