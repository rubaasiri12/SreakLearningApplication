# Learning Streak

A SwiftUI app that builds a daily learning habit with goals, streaks and freeze days.

**Platform:** iOS 17.0+ · **Language:** Swift · **Frameworks:** SwiftUI, SwiftData · **Architecture:** MVVM

---

## Overview

Learning Streak lets a person choose something to learn and a duration for it — a week, a month or a year. Each day, they log the day as *Learned*, or use a *Freeze* to protect their streak. The app tracks progress, shows every logged day in a calendar, and tells the person when the goal is completed or missed.

```swift
let goal = LearningGoal(topic: "Swift", duration: .week, startDate: .now)
```

---

## Topics

### Essentials

```swift
@main struct LearningStreakApp: App
```
The app entry point. Creates the three storages once and shows Onboarding or the Activity page.

```swift
struct AppStores
```
Groups the three storages and hands them to every ViewModel.

---

### Goals

```swift
struct LearningGoal
```
What the person learns, for how long, and since when.

```swift
enum GoalDuration { case week, month, year }
```
The goal length. Each case defines `totalDays` (7 · 30 · 365) and `maxFreezes` (2 · 8 · 96).

```swift
enum GoalStatus { case active, completed, missed }
```
Where the current goal stands.

---

### Progress

```swift
enum DayStatus { case learned, freezed }
```
What happened on a logged day.

```swift
@Model final class DayRecord
```
One logged day, saved with SwiftData.

---

### Storage

| Type | Technology | Stores |
|---|---|---|
| `ProgressStorageDB` | SwiftData | Every Learned / Freezed day |
| `GoalAppStorage` | AppStorage | Topic, duration, start date |
| `AppStateDefaults` | UserDefaults | Onboarding done, last log time, goal status |

---

### Screens

Each screen is a **View** (drawing only) paired with a **ViewModel** (rules and text).

| Task | View | ViewModel |
|---|---|---|
| 1 · Start learning | `OnboardingView` | `OnboardingViewModel` |
| 2 · Log a day | `ActivityView` | `ActivityViewModel` |
| 3 · Goal finished | `GoalFinishedView` | `ActivityViewModel` |
| 4 · Change the goal | `LearningGoalView` | `LearningGoalViewModel` |
| 5 · See past days | `CalendarView` | `CalendarViewModel` |

---

### Rules

- A streak resets after more than **32 hours** without logging, or when the goal changes.
- Learned and Freezed days both count toward the goal.
- A new day starts at **12 AM**.
- When a count is 1, the label reads **day**; otherwise **days**.

---

## See Also

- `Views/Theme/Theme.swift` — colors (`#FF9230`, `#3CD3FE`) and shared styles
- `Models/Helpers/AppCalendar.swift` — date rules

---

## Getting Started

1. Clone the repository.
2. Open `LearningStreak.xcodeproj` in Xcode 16 or later.
3. Run on an iPhone or simulator (`⌘R`).

---

*Ruba Asiri · Apple Developer Academy*
