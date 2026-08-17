# Add Authentication and Cloud Progress Tracking

Currently, the app stores user XP, streak, and group completion scores locally using `SharedPreferences`. To retain this progress securely across sessions and devices, and to provide actual user accounts, we need to integrate a backend service. 

I propose using **Firebase** (Firebase Authentication and Cloud Firestore) as it's the industry standard for Flutter apps and provides a robust, easy-to-use solution for email login and real-time database tracking.

## User Review Required

> [!IMPORTANT]
> **Firebase Setup Requires Manual Action**
> To proceed with this plan, you will need to create a Firebase project:
> 1. Go to the [Firebase Console](https://console.firebase.google.com/).
> 2. Create a new project (e.g., `gre-quizmaster`).
> 3. Enable **Authentication** (Email/Password provider).
> 4. Enable **Firestore Database** (Start in Test Mode).
> 5. Provide me with the **Project ID** so I can configure the Flutter app to connect to it using the FlutterFire CLI.

## Open Questions

> [!WARNING]  
> 1. Do you want to migrate the user's existing local progress to the cloud when they sign up, or should they start fresh?
> 2. Are you okay with using Firebase, or do you have a preference for another backend service like Supabase or Appwrite?

## Proposed Changes

We will introduce Firebase to handle authentication and database storage.

### 1. Dependencies

#### [MODIFY] [pubspec.yaml](file:///D:/Projects/GRE-Quizmaster/pubspec.yaml)
Add the following packages:
- `firebase_core`: For Firebase initialization.
- `firebase_auth`: For email/password login.
- `cloud_firestore`: For saving group progress and XP.

---

### 2. Authentication & Data Layer

#### [NEW] `lib/data/repositories/auth_repository.dart`
Will handle signing in, signing up, and signing out using Firebase Auth.

#### [MODIFY] [progress_repository.dart](file:///D:/Projects/GRE-Quizmaster/lib/data/repositories/progress_repository.dart)
Modify the existing repository to fetch and save data to Cloud Firestore instead of `SharedPreferences`. 
- **Database Schema**: 
  - `users/{uid}` -> Stores XP, streak, last active.
  - `users/{uid}/group_progress/{groupId}` -> Stores the score for each specific group.

---

### 3. User Interface

#### [NEW] `lib/ui/views/auth/login_screen.dart`
A new screen where users can enter their email and password to log in.

#### [NEW] `lib/ui/views/auth/register_screen.dart`
A new screen for new users to create an account.

#### [MODIFY] [main.dart](file:///D:/Projects/GRE-Quizmaster/lib/main.dart)
- Initialize Firebase (`Firebase.initializeApp()`).
- Update the app's initial route: if the user is logged in, show the Home screen; if not, show the Login screen.

## Verification Plan

### Automated Tests
- N/A

### Manual Verification
1. I will configure the project using `flutterfire configure`.
2. Launch the app and verify the Login/Register screens appear.
3. Create a test account and verify authentication works.
4. Play through a vocabulary group and verify that the progress and score are saved to Firestore and persist upon logging out and logging back in.
