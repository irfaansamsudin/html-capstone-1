# Project Monitor (iOS)

A simple iPhone/iPad app for keeping an eye on your projects: status, phase, schedule, budget and milestones, with a dashboard that flags anything needing attention.

Built with **SwiftUI** (the screens), **SwiftData** (saving data on the device) and **Swift Charts**. No server or account is needed, and everything stays on the phone.

## Features

- **Dashboard**: active / completed counts, projects needing attention, overdue milestones, a status chart, total budget vs. spend, and milestones due in the next 30 days.
- **Projects list**: search by name or client, filter by status, swipe to delete, tap **+** to add.
- **Project detail**:
  - Change status and phase in place (Concept → Schematic → Design Development → Construction Docs → Tender → Construction → Handover).
  - **Progress vs schedule**: compares the share of work done (milestones completed) with the share of time used, and tells you whether you're ahead or behind.
  - Budget used, remaining, and an over-budget warning.
  - A milestone checklist: tap to tick, swipe to delete, add new ones.
- Sample public-sector projects load on first launch so you can explore straight away. Delete them when you're ready.

## Running it

You need a Mac with **Xcode 16 or later** (free from the Mac App Store).

1. Clone this repository and open `ProjectMonitor.xcodeproj`.
2. Pick an iPhone simulator at the top of the window (for example "iPhone 16").
3. Press **⌘R** to build and run.

To run it on your own iPhone: select the **ProjectMonitor** target, open **Signing & Capabilities**, choose your Apple ID as the *Team*, and change the bundle identifier (for example `com.yourname.ProjectMonitor`). Then plug in your phone and press ⌘R.

Requires iOS 17 or later.

## How the code is organised: an architect's view

| Folder | Building analogy | What's inside |
|---|---|---|
| `Models/` | **Structure**: the frame everything sits on | `Project`, `Milestone`, and the `ProjectStatus` / `ProjectPhase` options. These describe *what the data is*, not how it looks. |
| `Views/` | **Interior and facade**: what people see and touch | One file per screen (`DashboardView`, `ProjectListView`, `ProjectDetailView`, `ProjectFormView`) plus reusable parts in `Components.swift`. |
| `Utilities/` | **Services**: plumbing that supports everything | Currency/percent/date formatting and the sample data. |
| `ProjectMonitorApp.swift` | **Site entrance** | Where the app starts and the database is created. |

Ideas worth noticing as you read the code:

1. **Separation of concerns.** The models don't know about colours or screens, and the views don't do maths. All derived values (progress, days left, "needs attention") live in one place, the `extension Project` in `Models/Project.swift`. If you change a rule there, every screen updates.
2. **A single source of truth.** Data is stored once (SwiftData). Screens *read* it with `@Query` and *edit* it with `@Bindable`. Nothing is copied around, so the screens never disagree.
3. **Reusable components.** `StatusBadge`, `ProjectRow` and `StatCard` are like standard details: draw them once, use them everywhere.
4. **Draft, then commit.** `ProjectFormView` edits a temporary copy (`@State`) and only writes to the real project on **Save**, so **Cancel** really does throw changes away. It's the same idea as working on a sketch overlay before updating the drawing set.

## Ideas to try next (good learning exercises)

- Add a `contractor` field to `Project` and show it in the form and on the detail screen. This touches the model, form and view.
- Add a **Photos** section for site photos using `PhotosPicker`.
- Add a reminder notification the day before a milestone is due (`UserNotifications`).
- Export a project summary as PDF to share with your team (`ImageRenderer`).
- Sync across devices with iCloud by enabling CloudKit on the SwiftData container.
