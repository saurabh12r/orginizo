# Orginizo – Implementation & Architecture Documentation

This document describes the current implementation, all pages, functionality, and architecture of the **Orginizo** Flutter task management app.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Project Structure](#project-structure)
4. [Routes & Pages](#routes--pages)
5. [Features & Screens](#features--screens)
6. [Data Layer](#data-layer)
7. [Core Services](#core-services)
8. [Theme & Styling](#theme--styling)
9. [Key Flows](#key-flows)

---

## Overview

**Orginizo** is a mobile task scheduling app (Android & iOS) with:

- **Firebase Authentication** (email/password) for login and signup
- **Local task storage** via Hive
- **GetX** for state management and routing
- **Feature-based** folder structure
- **Soft green productivity** theme (minimal, calm UI)
- **Today-focused home** and **weekly schedule** with timeline
- **Local notifications** for task reminders (at start + advance reminders)
- **Overlap detection** for tasks on the same day

---

## Architecture

### High-Level Layers

```
┌─────────────────────────────────────────────────────────┐
│  UI (Views) – GetView<Controller> / StatelessWidget      │
├─────────────────────────────────────────────────────────┤
│  State (Controllers) – GetX GetxController                │
├─────────────────────────────────────────────────────────┤
│  Data – Repository → HiveService / PrefService           │
├─────────────────────────────────────────────────────────┤
│  Core – Theme, Colors, Errors, NotificationService       │
└─────────────────────────────────────────────────────────┘
```

- **GetX**: Routing (`GetMaterialApp`, `GetPage`, `Get.toNamed`, `Get.offAllNamed`), state (`Obx`, `.obs`), dependency injection (`Get.put`, `Get.find`, `BindingsBuilder`).
- **Feature-based**: Each feature has `controller/`, `view/`, and optionally `widget/`, `model/`, `utils/`.
- **Single source of truth**: Tasks live in Hive; UI listens via `TaskRepository.listenable()` so all screens stay in sync.

### Routing & Bindings

- **Routes** are defined in `lib/routes/app_routes.dart` (string constants).
- **Pages** and **bindings** are in `lib/routes/app_pages.dart`: each `GetPage` uses `BindingsBuilder` to `Get.put(Controller)` when the route is pushed, so controllers are created and disposed with the route.
- **Main shell** binding registers `MainShellController`, `HomeController`, and `ScheduleController` together so Home and Schedule share the same instances when switching tabs.
- **Add Task** has no binding; the controller is put when navigating with optional `TaskModel` argument (edit mode).

---

## Project Structure

```
lib/
├── app/
│   └── my_app.dart                 # GetMaterialApp, theme, routes
├── core/
│   ├── constants/
│   │   └── colors.dart             # OrColors (primaryGreen, primaryGreenDark, bg, textDark, textGrey, etc.)
│   ├── error/
│   │   └── firebase_error.dart      # getFirebaseAuthMessage(code)
│   ├── services/
│   │   ├── local_storage_services/
│   │   │   ├── auth_service.dart   # (placeholder)
│   │   │   ├── hive_services.dart  # Hive CRUD + listenable for tasks
│   │   │   └── pref_service.dart   # SharedPreferences (e.g. isLoggedIn)
│   │   └── notification_services.dart  # Local notifications for task reminders
│   └── theme/
│       ├── dark_theme.dart
│       └── light_theme.dart
├── data/
│   ├── models/
│   │   ├── task_model.dart         # TaskModel (Hive) + reminderOffsetsCsv
│   │   └── task_model.g.dart       # Hive adapter
│   ├── repository/
│   │   └── task_repository.dart    # getAll, getTasksForDay, add, update, delete, listenable
│   └── task_dummy_data.dart
├── features/
│   ├── add_task/
│   │   ├── controller/
│   │   │   └── add_task_contoller.dart
│   │   └── view/
│   │       └── add_task_view.dart
│   ├── home/
│   │   ├── controller/
│   │   │   └── home_controller.dart
│   │   └── view/
│   │       └── home_view.dart
│   ├── login/
│   │   ├── controller/
│   │   │   ├── login_controller.dart
│   │   │   └── signup_screen_controller.dart
│   │   ├── view/
│   │   │   ├── login_screen_view.dart
│   │   │   └── signup_screen_view.dart
│   │   └── widget/
│   │       ├── input_field.dart
│   │       └── social_button.dart
│   ├── main_shell/
│   │   ├── controller/
│   │   │   └── main_shell_controller.dart
│   │   └── view/
│   │       └── main_shell_view.dart
│   ├── schedule/
│   │   ├── controller/
│   │   │   └── schedule_controller.dart
│   │   ├── model/
│   │   │   └── task_model.dart     # re-export / local if needed
│   │   ├── utils/
│   │   │   └── overlap_utils.dart   # timeRangesOverlap, dayHasOverlappingTasks, overlapGroups, etc.
│   │   ├── view/
│   │   │   └── schedule_view.dart
│   │   └── widgets/
│   │       ├── calendar_stripe.dart
│   │       ├── day_tasks_bottom_sheet.dart
│   │       ├── header_bar.dart
│   │       ├── timeline_day_view.dart
│   │       └── tittle_bar.dart
│   ├── splash/
│   │   ├── controller/
│   │   │   └── splash_screen_controller.dart
│   │   └── view/
│   │       └── splash_screen_view.dart
│   └── test/
│       └── testui.dart
├── routes/
│   ├── app_pages.dart
│   └── app_routes.dart
├── firebase_options.dart
└── main.dart
```

---

## Routes & Pages

| Route       | Path         | Screen           | Binding / Controller        |
|------------|--------------|------------------|-----------------------------|
| Splash     | `/splash`    | SplashScreen     | SplashController            |
| Login      | `/login`     | LoginScreen      | LoginController             |
| Signup     | `/signup`    | SignUpScreen     | SignUpController            |
| Main       | `/main`      | MainShellView    | MainShellController, HomeController, ScheduleController |
| Schedule   | `/schedule`  | ScheduleView     | ScheduleController (when used as standalone) |
| Add Task   | `/add-task`  | AddTaskPage      | AddTaskController (put on navigate, args: TaskModel? for edit) |
| Test       | `/test`      | TasksTestPage    | —                            |

- **Initial route**: `Routes.splash`.
- After auth (splash/login/signup), app uses `Get.offAllNamed(Routes.main)` so back stack is cleared.
- **Main** hosts **Home** and **Schedule** in an `IndexedStack`; bottom nav toggles between them. FAB and “Add Task” open `Routes.addTask` (optional `arguments: task` for edit).

---

## Features & Screens

### 1. Splash

- **Controller**: `SplashController`
- **View**: `SplashScreen`
- **Behaviour**: Waits ~2 seconds, then listens to `FirebaseAuth.authStateChanges().first`. If user exists → `Get.offAllNamed(Routes.main)`; else → `Get.offAllNamed(Routes.login)`.

### 2. Login

- **Controller**: `LoginController`
- **View**: `LoginScreen` (GetView)
- **Functionality**:
  - Email & password fields, form validation.
  - `login()`: `signInWithEmailAndPassword`; on success sets `PrefService().setLoggedIn(true)` and navigates to `Routes.main`.
  - Errors mapped via `getFirebaseAuthMessage(e.code)` and shown with `Get.snackbar`.
  - Toggle password visibility.

### 3. Sign Up

- **Controller**: `SignUpController`
- **View**: `SignUpScreen`
- **Functionality**:
  - Name, email, password, confirm password; validation.
  - `signup()`: `createUserWithEmailAndPassword`, optional `updateDisplayName(name)`; on success → `Get.offAllNamed(Routes.main)`.
  - Same error handling via `getFirebaseAuthMessage`.
  - Toggle password visibility for both fields.

### 4. Main Shell

- **Controller**: `MainShellController`
- **View**: `MainShellView`
- **Functionality**:
  - `isSchedulePage` (obs): toggles between Home (index 0) and Schedule (index 1).
  - `IndexedStack` keeps both views alive; only one visible.
  - **Bottom nav**: Floating bar (white, rounded, soft shadow), single tab “Schedule” with calendar icon; active state uses soft green background and dark green icon/text.
  - `goToAddTask()`: `Get.toNamed(Routes.addTask)`.
  - Scaffold `backgroundColor: OrColors.bg`.

### 5. Home (Today’s Tasks)

- **Controller**: `HomeController`
- **View**: `HomeView`
- **Functionality**:
  - **Data**: `todayTasks` (obs) from `TaskRepository.getTasksForDay(todayEpoch)`, sorted by start time; listens to `_repo.listenable()` so list updates when Hive changes.
  - **Header (SliverAppBar)**:
    - **Greeting** (“Good Morning ☀️” / “Good Afternoon” / “Good Evening”): shown only when app bar is fully expanded; **totally invisible when user scrolls** (widget removed when height &lt; expanded − 2).
    - **Today block** (always visible when collapsed): “Today” title, subtitle (e.g. “Monday, Feb 2”), task count chip (pill, soft green, “X tasks” / “No tasks”). Collapsed toolbar height 118px so chip is not clipped.
  - **List**: Today’s tasks as cards; swipe-to-dismiss to delete (calls `NotificationService().cancelAllForTask` + `_repo.deleteTask`). Tap card → Add Task with `arguments: task`.
  - **Empty state**: Message + “Add Task” button.
  - **FAB**: “Add Task” (green, pill, slight elevation).
  - **Task card**: White, rounded, soft shadow, thin green left accent, title (bold), time range with clock icon, chevron.

### 6. Schedule

- **Controller**: `ScheduleController`
- **View**: `ScheduleView`
- **Functionality**:
  - **Tabs**: 7-day strip (dates); `TabController` + `dates` list; today centered initially; shifting forward/backward loads more dates.
  - **Tasks**: `allTasks` from `TaskRepository.getAll()`; listener keeps it in sync. `getTasksForDay(dayEpoch)` returns sorted tasks for selected day.
  - **Overlap**: `overlap_utils.dart` – `dayHasOverlappingTasks`, `isTaskInConflict`, `overlapGroups` (union-find) for timeline grouping.
  - **Day bottom sheet**: Tapping a day opens `DayTasksBottomSheet(dayEpoch, date)` – list of tasks, Edit (navigate to Add Task with task) and Delete (cancel notifications + repo delete). Overlap warning shown when applicable.
  - **Timeline**: `TimelineDayView` (and related widgets) for day view with overlap grouping.

### 7. Add Task / Edit Task

- **Controller**: `AddTaskController`
- **View**: `AddTaskView` (AddTaskPage)
- **Functionality**:
  - **Edit mode**: If `Get.arguments` is `TaskModel`, prefill title, date, start/end time, reminder offsets.
  - **Fields**: Title, date picker (today → max date), start/end time pickers. End time auto-adjusted if before start when start changes.
  - **Reminders**: Multi-select chips (15, 30, 45, 60 min before start); stored in `TaskModel.reminderOffsetsCsv`.
  - **Validation** (before save):
    - Title non-empty.
    - Date today or future, within range.
    - Start time not in past when date is today.
    - End &gt; start.
    - Short duration (&lt; 5 min) → confirmation dialog.
    - Overlap with same-day tasks → confirmation dialog.
  - **Save**: If edit → cancel old notifications, update task, schedule new reminders. If add → add task, schedule reminders. Snackbar if all reminder times in past. Then `Get.back()`.

---

## Data Layer

### TaskModel (Hive)

- **Location**: `lib/data/models/task_model.dart`
- **Fields**: `id`, `title`, `day` (epoch ms at midnight), `startMinutes`, `endMinutes`, `isCompleted`, `reminderOffsetsCsv` (e.g. `"15,30"`).
- **Getters**: `reminderOffsets` (parsed list of int); `setReminderOffsets(List<int>)`.
- **Hive**: typeId 0, adapter in `task_model.g.dart`.

### TaskRepository

- **Location**: `lib/data/repository/task_repository.dart`
- **Methods**: `getAll()`, `getTasksForDay(dayEpoch)`, `addTask(task)`, `updateTask(task)`, `deleteTask(id)`, `listenable()` (ValueListenable for Hive box).
- **Day normalization**: Same-day comparison via normalized day epoch (midnight).

### HiveService

- **Location**: `lib/core/services/local_storage_services/hive_services.dart`
- **Box**: `Hive.box<TaskModel>('tasks')`; `save(task)`, `delete(id)`, `getAll()`, `listenable()`.

---

## Core Services

### NotificationService

- **Location**: `lib/core/services/notification_services.dart`
- **Singleton**: `NotificationService()`.
- **Init**: Timezone, `FlutterLocalNotificationsPlugin` init, Android channel “Task Reminders”.
- **Per task**:
  - **At start**: One notification at task start time (“Task starting now”).
  - **Advance**: One per `reminderOffsets` (e.g. 15, 30 min before) – “Task starts in X minutes”.
- **IDs**: `Object.hash(taskId, offsetMinutes)` (offset 0 = at start).
- **Cancel**: `cancelAllForTask(taskId, reminderOffsets)` cancels at-start and all advance reminders.
- **Scheduling**: Skips past times; deduplicates multiple reminders in the same minute. Uses `zonedSchedule` with `AndroidScheduleMode.exactAllowWhileIdle`.

### PrefService

- **Location**: `lib/core/services/local_storage_services/pref_service.dart`
- **Keys**: e.g. `isLoggedIn` (bool).
- **Methods**: `setLoggedIn(bool)`, `isLoggedIn()`, `clear()`.

### Firebase Error Handling

- **Location**: `lib/core/error/firebase_error.dart`
- **Function**: `getFirebaseAuthMessage(String code)` maps Firebase Auth error codes to user-friendly strings (invalid-email, wrong-password, email-already-in-use, etc.). Used by login and signup for snackbars.

---

## Theme & Styling

### Colors (`OrColors`)

- **Location**: `lib/core/constants/colors.dart`
- **Usage**: `primaryGreen`, `primaryGreenDark`, `bg`, `textDark`, `textGrey`; also `green`, `purple`, `darkCard`, `lightBg` for legacy/other use.
- **Home/Schedule**: Soft green productivity theme; gradients green-only (no purple in header).

### Light / Dark Theme

- **Location**: `lib/core/theme/light_theme.dart`, `dark_theme.dart`
- **Applied in**: `MyApp` → `GetMaterialApp(theme: lightTheme, darkTheme: darkTheme, themeMode: ThemeMode.light)`.
- **Light**: Material 3, `OrColors.bg`, primary green, rounded buttons (30), rounded filled inputs (28), green focus border.

---

## Key Flows

1. **App start**: `main()` → NotificationService init, Hive init + open “tasks” box, Firebase init → `MyApp` → initial route `/splash` → after delay + auth check → `/main` or `/login`.
2. **Login/Signup**: Validate form → Firebase auth → on success set prefs (login) / update display name (signup) → `Get.offAllNamed(Routes.main)`.
3. **Home**: Load today’s tasks from repo (listener); display in SliverList; swipe to delete (notifications cancelled + repo delete); tap card → Add Task with task; FAB → Add Task.
4. **Schedule**: Load all tasks; 7-day strip; select day → bottom sheet with day’s tasks; Edit → Add Task with task; Delete → cancel notifications + repo delete.
5. **Add/Edit Task**: Validate → short-duration and overlap confirmations → save/update in repo → cancel old notifications (edit) → schedule new reminders → back.

---

## Summary Table (Pages & Main Responsibility)

| Page        | Main responsibility |
|------------|----------------------|
| Splash     | Auth check, route to main or login |
| Login      | Email/password sign-in, navigate to main |
| Sign Up    | Create account, optional display name, navigate to main |
| Main Shell | Bottom nav (Home / Schedule), FAB to Add Task |
| Home       | Today’s tasks, greeting (hidden on scroll), chip, swipe delete, tap edit |
| Schedule   | 7-day strip, day bottom sheet, timeline, edit/delete |
| Add Task   | Create/edit task, validation, reminders, overlap/short-duration confirm, save & schedule notifications |

This document reflects the implementation as of the latest changes (greeting fully invisible on scroll, task count chip visible when collapsed, green-only theme, notifications and overlap handling).
