import Foundation
import Combine

@MainActor
final class DeviceListViewModel: ObservableObject {
    @Published private(set) var devices: [Device] = []
    @Published private(set) var showBatteryAlert = false
    
    private let provider: DevicesProvider
    private let formatter = RelativeDateTimeFormatter()
    private var manuallyToggledIDs: Set<UUID> = []
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
    
    func setShowBatteryAlert(_ value: Bool) {
        showBatteryAlert = value
    }
    
    private func startTimer() {
        timerCancellable = Timer
            .publish(every: 4.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateStatuses()
            }
    }
    
    private func updateStatuses() {
        let updatedDevices = provider.updateDeviceStatuses(current: devices)
        let currentDevicesById = Dictionary(uniqueKeysWithValues: devices.map { ($0.id, $0) })
        let now = Date()
        
        var isLowBatteryDeviceFound = false
        var manuallyChangedIDs = manuallyToggledIDs
        var resultDevices: [Device] = []
        resultDevices.reserveCapacity(updatedDevices.count)
        
        updatedDevices.forEach { updatedDevice in
            var device = updatedDevice
            
            if manuallyChangedIDs.contains(device.id),
               let currentDevice = currentDevicesById[device.id] {
                device.isOnline = currentDevice.isOnline
                device.lastSeen = currentDevice.lastSeen
            }
            
            let (processedDevice, newIDs) = applyZeroBattery(
                for: device,
                now: now,
                manuallyChangedIDs: manuallyChangedIDs
            )
            device = processedDevice
            manuallyChangedIDs = newIDs
            
            if device.batteryLevel < 20 {
                isLowBatteryDeviceFound = true
            }
            
            resultDevices.append(device)
        }
        
        devices = resultDevices
        manuallyToggledIDs = manuallyChangedIDs
        showBatteryAlert = isLowBatteryDeviceFound
    }
    
    private func applyZeroBattery(
        for device: Device,
        now: Date,
        manuallyChangedIDs: Set<UUID>
    ) -> (Device, Set<UUID>) {
        guard device.batteryLevel <= 0 else {
            return (device, manuallyChangedIDs)
        }
        
        var updatedDevice = device
        updatedDevice.batteryLevel = 0
        if updatedDevice.isOnline {
            updatedDevice.isOnline = false
            updatedDevice.lastSeen = now
        }
        
        var updatedIDs = manuallyChangedIDs
        updatedIDs.remove(updatedDevice.id)
        
        return (updatedDevice, updatedIDs)
    }
    
    
    func toggleStatus(for device: Device) {
        guard let index = devices.firstIndex(where: { $0.id == device.id }) else { return }
        
        if devices[index].batteryLevel == 0, devices[index].isOnline == false {
            return
        }
        
        devices[index].isOnline.toggle()
        if !devices[index].isOnline {
            devices[index].lastSeen = Date()
        }
        manuallyToggledIDs.insert(device.id)
    }
    
    func statusText(for device: Device) -> String {
        if device.isOnline {
            return "Online".localized()
        } else {
            formatter.unitsStyle = .short
            return "Last seen: \(formatter.localizedString(for: device.lastSeen, relativeTo: Date()))"
        }
    }
    
    deinit {
        timerCancellable?.cancel()
    }
}

#if DEBUG
extension DeviceListViewModel {
    func test_updateStatuses() { updateStatuses() }
}
#endif
