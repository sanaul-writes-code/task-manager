# Task Manager App

A real-time task management mobile application built using Flutter and Firebase Firestore.  
This app allows users to create, manage and organize tasks with nested subtasks in real time.

---

## Features

### Core Features
- Add new tasks
- Real-time task list using Firestore streams
- Mark tasks as complete/incomplete
- Delete tasks
- Persistent cloud storage (Firestore)
- Nested subtasks (add/delete)
- Expandable task view

### Enhanced Features
- Task search and filtering
- Delete confirmation dialog
- Loading, empty, and error UI states
- Real-time updates across sessions/devices

---

## Tech Stack

- Flutter (UI framework)
- Dart
- Firebase Core
- Cloud Firestore (NoSQL database)

---

## Project Structure

```
TASK_MANAGER/lib
|   firebase_options.dart
|   main.dart
|
+---models
|       task.dart
|
+---screens
|       task_screen.dart
|
+---services
        task_service.dart
```


---

## Setup Instructions

### 1. Clone the repository
```
git clone <your-repo-url>
cd <your-repo-name>
```

### 2. Install dependencies
```
flutter pub get
```

### 3. Configure Firebase
- Create a Firebase project
- Enable Firestore Database
- Use FlutterFire CLI:
```
flutterfire configure
```

### 4. Run the app
```
flutter run
```

## Firestore Data Model

Each task is stored as a document in the tasks collection:

```
{
  "title": "Buy groceries",
  "isCompleted": false,
  "subtasks": ["Buy milk", "Buy eggs"],
  "createdAt": "timestamp"
}
```

## How It Works
- Tasks are stored in Firestore
- The app uses a StreamBuilder to listen to real-time updates
- Any change (add, delete, update) instantly updates the UI
- Subtasks are stored as a list inside each task document


## Testing

Test the following features:

- Add tasks
- Delete tasks (with confirmation)
- Toggle completion
- Add and delete subtasks
- Search and filter tasks
- Real-time updates
- App restart persistence


## Firestore Rules (Development)

During development, Firestore rules may be set to:

```
allow read, write: if true;
```

This is for testing only. Production apps should use secure rules.


## Future Improvements

- Dark mode support
- Subtask completion tracking
- Task deadlines and reminders
- Drag-and-drop reordering
- User authentication