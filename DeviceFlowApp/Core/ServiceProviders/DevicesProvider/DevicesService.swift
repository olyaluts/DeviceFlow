import Foundation

final class DevicesService: ObservableObject, DevicesProvider {
    func fetchInitialDevices() -> [Device] {
        (1...10).map {
            Device(id: UUID(), name: "Device \($0)", isOnline: true, batteryLevel: 100, lastSeen: Date())
        }
    }

    func updateDeviceStatuses(current: [Device]) -> [Device] {
        current.map { device in
            var updated = device
            updated.updateStatus()
            return updated
        }
    }
}
