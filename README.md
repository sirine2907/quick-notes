# Quick Notes

A Flutter notes app with tag-based organization and local storage. Built as a portfolio project to practice clean architecture, SQLite persistence, and Flutter fundamentals.

---

## Features

- Create, edit, and delete notes
- Tag notes and filter by tag
- Search notes by title or body
- Timestamps — created and last modified
- Fully offline — all data stored on device with sqflite

---

## Screenshots

> Coming soon

---

## Tech Stack

| Layer | Tool |
|---|---|
| Framework | Flutter (Dart) |
| Local storage | sqflite |
| State management | setState |

---

## Getting Started

**Prerequisites:** Flutter SDK installed, Android emulator or physical device.

```bash
git clone https://github.com/sirine2907/quick-notes.git
cd quick-notes
flutter pub get
flutter run
```

---

## Project Structure

```
lib/
├── models/       # Plain Dart data classes
├── db/           # SQLite repository — all queries live here
├── screens/      # Full-page views pushed onto the Navigator stack
└── widgets/      # Reusable UI components
```

---

## Status

Active development. Data layer complete — UI in progress.
