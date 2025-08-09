import Foundation
import Combine

@MainActor
final class DeviceListViewModel: ObservableObject {
    @Published var devices: [Device] = []
    @Published var showBatteryAlert = false
    
    let provider: DevicesProvider
    private var manuallyToggledIDs: Set<UUID> = []
    private var timer: Timer?
    private var timerCancellable: AnyCancellable?
    
    init(provider: DevicesProvider) {
        self.provider = provider
        startTimer()
    }
    
    func loadInitialData() {
        devices = provider.fetchInitialDevices()
    }
    
    func refresh() async {
        devices = provider.fetchInitialDevices()
        manuallyToggledIDs.removeAll()
    }
    
    private func startTimer() {
        timerCancellable = Timer
            .publish(every: 4.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.updateStatuses()
            }
    }
    
    private func updateStatuses() {
        let updated = provider.updateDeviceStatuses(current: devices)
        
        devices = updated.map { newItem in
            guard manuallyToggledIDs.contains(newItem.id),
                  let current = devices.first(where: { $0.id == newItem.id }) else {
                return newItem
            }
            var merged = newItem
            merged.isOnline = current.isOnline
            merged.lastSeen = current.lastSeen
            return merged
        }
        
        showBatteryAlert = devices.contains { $0.batteryLevel < 20 }
    }
    
    func toggleStatus(for device: Device) {
        if let index = devices.firstIndex(where: { $0.id == device.id }) {
            devices[index].isOnline.toggle()
            if !devices[index].isOnline {
                devices[index].lastSeen = Date()
            }
        }
        manuallyToggledIDs.insert(device.id)
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
