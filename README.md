# Device Monitor

A lightweight iOS demo that displays a list of mock devices with real‑time status updates. Built with **SwiftUI** and **MVVM**.

## How to Run
1. Open the project in **Xcode 15** (or later) with iOS 16 SDK.
2. Select an **iOS 16.0+** simulator or a physical device.
3. Build & run (⌘R). No external dependencies or configuration required.

## Requirements
- iOS **16.0+**
- **SwiftUI** only (per task)
- Uses **@StateObject** for the ViewModel
- Supports **Light/Dark** mode
- Clean separation of **View** and **ViewModel**

## Architecture & Approach
- **MVVM**: `DeviceListView` (View) observes `DeviceListViewModel` (ObservableObject).
- **Data source**: `DevicesProvider` generates and updates mock data; no networking.
- **State exposure**: `@Published private(set)` for `devices` and `showBatteryAlert` to keep state read‑only from outside while preserving SwiftUI updates.
- **Timer-driven simulation**: A `Timer.publish(every: 4, on: .main, in: .common).autoconnect()` updates device states.
- **User actions**:
  - **Pull‑to‑refresh** resets all devices to 100% battery.
  - **Tap on a row** toggles the device’s online/offline state (manual override respected across updates).
  - **Low battery alert** appears when any device drops below **20%**.
- **Last seen**: Updates to the current timestamp when a device goes offline (manually or due to 0% battery). Displayed using `RelativeDateTimeFormatter`.

## Notable Implementation Details
- **Manual overrides**: Tapping a device marks its ID in `manuallyToggledIDs`. During timer updates, these devices keep their user‑chosen online status and last-seen timestamp unless battery hits 0%.
- **Zero-battery handling**: If battery <= 0, the device is forced offline, `lastSeen` is set to `Date()`, and its ID is removed from manual overrides.
- **Alert binding with read‑only state**: Since `showBatteryAlert` is `private(set)`, the view uses a custom `Binding(get:set:)` that calls a small `setShowBatteryAlert(_:)` method in the ViewModel.
- **Performance**: Minor micro‑optimizations (e.g., preallocating result arrays; dictionary lookup for current devices by ID).

## UI
Each row shows:
- Device **name/ID**
- **Online/Offline** indicator (green/red circle)
- **Battery** percentage
- **Last seen** timestamp (e.g., “2 min ago”) when offline

## Testing / Debugging
- A `#if DEBUG` method `test_updateStatuses()` is available to invoke a single status tick in previews or tests.

## Time Spent
Approx. **6–7 hours** (setup, implementation, polish, README). *Adjust here if your actual time differs.*
