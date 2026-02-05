# ALU Academic Assistant

A Flutter mobile application that serves as a personal academic assistant for ALU (African Leadership University) students. The app helps users organize coursework, track schedules, and monitor academic engagement throughout the term.

---

## Table of Contents

1. [Features](#features)
2. [Project Architecture](#project-architecture)
3. [Setup & Installation](#setup--installation)
4. [Color Palette & Branding](#color-palette--branding)
5. [Data Persistence](#data-persistence)
6. [Key Implementation Details](#key-implementation-details)

---

## Features

### 1. Dashboard (Home Screen)
- Displays today's date and current academic week number
- Shows today's scheduled academic sessions with time and location
- Lists assignments due within the next 7 days
- Displays current overall attendance percentage
- Shows a prominent **AT RISK** warning banner when attendance drops below 75%
- Summary count of all pending (incomplete) assignments

### 2. Assignment Management
- **Create** assignments with title (required), due date (date picker), course name, and priority level (High/Medium/Low)
- **View** all assignments sorted by due date with filter tabs: All, Pending, Completed
- **Complete** assignments with a tap on the check circle
- **Edit** assignment details via the edit icon
- **Delete** assignments with a confirmation dialog
- Overdue assignments are visually highlighted with a red border and "OVERDUE" label

### 3. Academic Session Scheduling
- **Schedule** sessions with title (required), date, start/end time (time pickers), location (optional), and session type dropdown (Class, Mastery Session, Study Group, PSL Meeting)
- **Weekly calendar view** with day-by-day navigation and week-forward/back arrows
- **Attendance recording** via Present/Absent toggle buttons on each session card
- **Edit** and **Delete** sessions with confirmation
- Day dots indicate days with scheduled sessions in the week selector

### 4. Attendance Tracking
- Automatic calculation of attendance percentage from all recorded sessions
- Attendance summary bar on the Schedule screen showing present/absent counts
- Dashboard displays the overall attendance percentage in a stat card
- Visual **AT RISK WARNING** banner on Dashboard when attendance falls below 75%
- Color-coded indicators: green for healthy attendance, red for at-risk

---

## Project Architecture

The project follows a clean folder structure separating UI from business logic:

```
lib/
├── main.dart                       # App entry point, theme setup, navigation shell
├── models/
│   ├── assignment.dart             # Assignment data model with JSON serialization
│   └── session.dart                # Session data model with JSON serialization
├── screens/
│   ├── dashboard_screen.dart       # Home dashboard with stats and overview
│   ├── assignments_screen.dart     # Assignment CRUD interface
│   └── schedule_screen.dart        # Weekly schedule and session management
├── widgets/
│   ├── assignment_card.dart        # Reusable assignment display card
│   └── session_card.dart           # Reusable session display card with attendance
└── utils/
    ├── constants.dart              # ALU colors, text styles, enums
    └── storage_helper.dart         # shared_preferences persistence layer
```

### Design Decisions

- **`IndexedStack`** is used for tab switching to preserve state across tabs (no data loss when switching)
- **Data flows down** from `MainNavigationShell` to child screens via constructor parameters
- **Callbacks flow up** when data changes, triggering save to `shared_preferences`
- **Models** include `toJson()`/`fromJson()` factory methods for serialization
- **Reusable widgets** (`AssignmentCard`, `SessionCard`) are separated for modularity

---

## Setup & Installation

### Prerequisites
- Flutter SDK 3.1+ installed
- Android Studio or VS Code with Flutter extensions
- An Android emulator or physical device (iOS simulator also works)

### Steps

```bash
# 1. Clone the repository
git clone <your-repo-url>
cd alu_academic_assistant

# 2. Install dependencies
flutter pub get

# 3. Run the app on a connected device or emulator
flutter run
```

> **Note on Fonts**: The app references Poppins font. If you don't have the font files,
> simply remove the `fonts` section from `pubspec.yaml` and Flutter will use the default font.

---

## Color Palette & Branding

The app uses ALU's official color palette:

| Color             | Hex Code   | Usage                          |
|-------------------|------------|--------------------------------|
| Primary Dark      | `#0A1628`  | Main background                |
| Primary Navy      | `#0D1F3C`  | Cards, surfaces, nav bar       |
| Navy Light        | `#152744`  | Input fields, secondary cards  |
| Accent Gold       | `#F0C808`  | Buttons, highlights, accents   |
| Danger Red        | `#E63946`  | Warnings, at-risk, delete      |
| Success Green     | `#2ECC71`  | Present, healthy attendance    |
| Warning Orange    | `#F39C12`  | Medium priority                |
| Text White        | `#FFFFFF`  | Primary text                   |
| Text Light        | `#B0BEC5`  | Secondary text                 |
| Text Muted        | `#6C7A89`  | Captions, placeholders         |

---

## Data Persistence

This app uses **`shared_preferences`** for local data persistence.

### How it works:
1. On app startup, `StorageHelper.loadAssignments()` and `StorageHelper.loadSessions()` read JSON data from shared_preferences
2. Each model has `toJson()` and `fromJson()` methods for serialization
3. Whenever data changes (create, edit, delete, toggle), the full list is saved back to shared_preferences via `StorageHelper.saveAssignments()` or `StorageHelper.saveSessions()`
4. Data persists across app restarts automatically

### Storage Keys:
- `alu_assignments` — Stores the assignment list as JSON strings
- `alu_sessions` — Stores the session list as JSON strings

---

## Key Implementation Details

### Navigation
The app uses a `BottomNavigationBar` with 3 tabs (Dashboard, Assignments, Schedule). The `IndexedStack` widget renders all three screens but only displays the selected one, preserving scroll positions and form states.

### Form Validation
- Assignment title is required — shows a red SnackBar if empty
- Session title is required — shows a red SnackBar if empty
- End time must be after start time — validated before saving
- Date pickers prevent selecting dates too far in the past

### Attendance Calculation
Attendance percentage = (Sessions marked Present / Total sessions with attendance recorded) × 100. Sessions without attendance recorded are excluded from the calculation. If no attendance is recorded yet, the percentage defaults to 100%.

### Academic Week Calculation
The academic week is calculated from a configurable term start date (default: January 13, 2026). Adjust `termStart` in `dashboard_screen.dart` to match your actual term start.
