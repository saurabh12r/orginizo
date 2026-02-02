# Notifications in Orginizo

This document describes what has been included in the app for **local notifications** (task reminders).

---

## Overview

- **Type:** Local notifications (on-device), no push/FCM.
- **Purpose:** Remind the user when a task is due (at the task’s start time).
- **Implementation:** `NotificationService` singleton + `flutter_local_notifications` and `timezone`.

---

## Dependencies (`pubspec.yaml`)

| Package                     | Purpose                                      |
|----------------------------|----------------------------------------------|
| `flutter_local_notifications` | Schedule and show local notifications    |
| `timezone`                  | Schedule notifications at a specific time   |
| `permission_handler`       | Request notification and exact-alarm permissions |

---

## App Startup (`lib/main.dart`)

1. **NotificationService init**
   - `await NotificationService().init()` runs before `runApp()`.
   - Initializes timezones and the local notifications plugin.
   - Requests Android notification permission via the plugin.

2. **Permission requests**
   - **Notification:** `Permission.notification` — requested if denied.
   - **Exact alarm (Android):** `Permission.scheduleExactAlarm` — requested if denied (used for on-time task reminders).

---

## NotificationService (`lib/core/services/notification_services.dart`)

- **Singleton:** One shared instance via factory constructor.
- **Plugin:** `FlutterLocalNotificationsPlugin`.

### Initialization (`init()`)

- Initializes timezones (`tz.initializeTimeZones()`).
- Sets Android init settings (e.g. default icon).
- Initializes the plugin and requests notification permission on Android.

### Task reminder: `scheduleTaskNotification()`

**Parameters:**

| Parameter        | Type       | Description                          |
|-----------------|------------|--------------------------------------|
| `id`            | `String`   | Task id (used to derive notification id) |
| `title`         | `String`   | Task title (shown in notification)   |
| `date`          | `DateTime` | Task date (day)                      |
| `startMinutes`  | `int`      | Start time as minutes from midnight |

**Behaviour:**

- Builds a `DateTime` for the task’s start time on the given `date`.
- Schedules a **zoned** notification at that time using `tz.TZDateTime.from(..., tz.local)`.
- **Channel:** `task_channel_id` — “Task Reminders” (task and meeting reminders).
- **Importance / priority:** Max importance, high priority (so it can show as a pop-up/alert on Android).
- **Schedule mode:** `AndroidScheduleMode.exactAllowWhileIdle` so the alarm can fire at the exact time when the device is idle.

**Shown notification:**

- Title: `"📅 {task title}"`
- Body: `"Your task is starting now"`

**Note:** The notification id used with the plugin is `id.hashCode` (int). If a task is updated, scheduling again with the same task id overwrites the previous notification for that task.

---

## Where notifications are scheduled

### 1. Add new task (`lib/features/add_task/controller/add_task_contoller.dart`)

- When the user **saves a new task**, after the task is added to the repository:
  - `NotificationService().scheduleTaskNotification(...)` is called with the new task’s `id`, `title`, `date`, and `startMinutes`.
- So every **new** task gets a reminder at its start time.

### 2. Update existing task (same controller)

- When the user **updates a task** (edit flow), after the task is updated in the repository:
  - `NotificationService().scheduleTaskNotification(...)` is called again with the updated task’s `id`, `title`, `date`, and `startMinutes`.
- So the reminder is **rescheduled** for the new time/title; the previous reminder for that task id is effectively replaced.

---

## What is *not* included

- **Cancelling a notification** when a task is **deleted** — the scheduled notification for that task id may still fire until the app or OS clears it. To fully support “no reminder for deleted tasks”, you’d add a call to cancel the notification by id (e.g. using the same `id.hashCode`) in the delete flow.
- **Foreground / background handlers** for when the user taps the notification (e.g. open app to that task).
- **Push / cloud messaging** (FCM) — only local scheduling is implemented.
- **Repeating reminders** (e.g. daily) — each reminder is a one-time schedule at the task’s start time.

---

## UI reference

- **Schedule screen:** The header includes a notification icon (`Icons.notifications_none`) in `lib/features/schedule/widgets/header_bar.dart`. It is **visual only**; no notification logic is tied to that button in the current code.

---

## Summary table

| Item                         | Included |
|-----------------------------|----------|
| Init on app start           | ✅       |
| Request notification permission | ✅   |
| Request exact alarm (Android) | ✅    |
| Schedule at task start time | ✅       |
| On new task                 | ✅       |
| On update task              | ✅       |
| Cancel on delete task       | ❌       |
| Tap notification → open app/task | ❌  |
| Push / FCM                  | ❌       |
