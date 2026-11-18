# Learning Streak — strict MVVM, 3 storages

Open LearningStreak.xcodeproj in Xcode 16 or later, pick an iPhone simulator, press Run (Cmd+R).
Every View has previews: Editor > Canvas (Opt+Cmd+Return).

## Where the data is stored
| Data | Storage | File |
|---|---|---|
| Progress: every Learned / Freezed day | SwiftData (StorageDB) | Models/Storage/ProgressStorageDB.swift |
| The learning goal: topic, duration, start day | AppStorage | Models/Storage/GoalAppStorage.swift |
| App state: onboarding done, last log time, goal status | UserDefaults | Models/Storage/AppStateDefaults.swift |
AppStores.swift bundles the three so ViewModels get them together.

## Folders
App/          start of the app + first screen + navigation (not MVVM)
Models/       data: GoalDuration, LearningGoal, DayStatus, Helpers/AppCalendar, Storage/ (the 3 storages)
ViewModels/   rules + texts, one per screen: Onboarding, Activity, LearningGoal, Calendar
Views/        drawing only: Task1..Task5, Components (DayCircle, GoalFormFields), Theme (colors)
