# SignMirror

SignMirror is a Flutter-based mobile application designed to help users learn and practice sign language interactively. This repository contains the front-end codebase for the application, featuring structured lessons, a comprehensive sign dictionary, personalized learning paths, and progress tracking.

## Features

*   **Sign Language Lessons:** Structured lessons broken down by level (e.g., beginner, intermediate) and categories to help users incrementally learn sign language.
*   **Sign Dictionary:** A searchable glossary of sign language gestures and vocabulary, providing quick access to visual demonstrations.
*   **Progress Tracking & Dashboard:** Personal learning analytics powered by `fl_chart`, displaying user progress, lesson completion rates, and learning streaks.
*   **Personalization & Onboarding:** Custom learning paths tailored to the user's proficiency level and goals during the initial setup.
*   **Local Caching with Isar:** Offline-first capability utilizing a high-performance local NoSQL database (`isar_community`) to securely store lessons, signs, and user progression.
*   **State Management:** Built leveraging `flutter_riverpod` for robust, scalable, and reactive state management across complex user flows.

## Architecture

The application is structured logically to separate concerns and ensure maintainability:

*   **`lib/main.dart`**: Application entry point defining the routing and core theme.
*   **`lib/constants/`**: Environment, color (`app_colors.dart`), and routing (`route_names.dart`) constants.
*   **`lib/models/`**: Isar database schemas and typed models representing entities like `Lesson` and `Sign`.
*   **`lib/screens/`**: The core UI views, categorized by feature:
    *   Auth flow: `signin_screen.dart`, `signup_screen.dart`
    *   Onboarding: `onboarding_screen.dart`, `personalization_screen.dart`
    *   Core app: `main_screen.dart`, `dashboard_screen.dart`, `profile_screen.dart`
    *   Learning: `lessons_screen.dart`, `lesson_signs_screen.dart`, `sign_screen.dart`, `dictionary_screen.dart`
*   **`lib/services/`**: Integration layers with persistent storage, specifically the offline `isar_service.dart`.
*   **`lib/state/`**: Riverpod providers managing reactive application state for user sessions and learning progress.
*   **`lib/theme/`**: Theme definitions configuring the visual design language (custom fonts, colors).
*   **`lib/widgets/`**: Reusable UI components shared across multiple screens.

## Dependencies

Key packages utilized in this project include:

*   **`flutter_riverpod`**: A reactive caching and data-binding framework for state management.
*   **`isar_community` & `isar_community_flutter_libs`**: Fast, cross-platform local NoSQL database for managing offline data.
*   **`fl_chart`**: A highly customizable Flutter charting library used for rendering data visualizations in the user dashboard.
*   **`path_provider`**: Handles finding commonly used locations on the device filesystem.

## Getting Started

To run the project locally, ensure you have the Flutter SDK installed.

1. Clone the repository.
2. Run `flutter pub get` to install all dependencies.
3. Since the app uses `isar`, ensure you run the code generator to build the latest Isar model schemas:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Start the application:
   ```bash
   flutter run
   ```