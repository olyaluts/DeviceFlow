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

final class MockDevicesService: DevicesProvider {
    private let initialDevices: [Device]
    
    init(initialDevices: [Device]) {
        self.initialDevices = initialDevices
    }

    func fetchInitialDevices() -> [Device] {
        initialDevices
    }

    func updateDeviceStatuses(current: [Device]) -> [Device] {
        return current.map {
            var updated = $0
            updated.batteryLevel = max(0, updated.batteryLevel - 1)
            return updated
        }
    }
}
