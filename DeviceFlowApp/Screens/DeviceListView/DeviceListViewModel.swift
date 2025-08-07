import Foundation
import Combine

@MainActor
final class DeviceListViewModel: ObservableObject {
    @Published var devices: [Device] = []
    @Published var showBatteryAlert = false

    let provider: DevicesProvider
    private var timer: Timer?
    private var timerCancellable: AnyCancellable?

    init(provider: DevicesProvider) {
        self.provider = provider
        loadInitialData()
        startTimer()
    }

    func loadInitialData() {
        devices = provider.fetchInitialDevices()
    }

    func refresh() {
        devices = provider.fetchInitialDevices()
    }

    func startTimer() {
        timerCancellable = Timer
            .publish(every: 4.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.updateStatuses()
            }
    }
    
    private func updateStatuses() {
        devices = provider.updateDeviceStatuses(current: devices)
        showBatteryAlert = devices.contains { $0.batteryLevel < 20 }
    }

    func toggleStatus(for device: Device) {
        if let index = devices.firstIndex(where: { $0.id == device.id }) {
            devices[index].isOnline.toggle()
            if !devices[index].isOnline {
                devices[index].lastSeen = Date()
            }
        }
    }

    func statusText(for device: Device) -> String {
        if device.isOnline {
            return "Online".localized()
        } else {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            return "Last seen: \(formatter.localizedString(for: device.lastSeen, relativeTo: Date()))"
        }
    }

    deinit {
        timer?.invalidate()
    }
}
