import Foundation
import Combine

final class DeviceListViewModel: ObservableObject {
    @Published var devices: [Device] = []
    @Published var showBatteryAlert = false

    private var timer: AnyCancellable?
    private let updateInterval = Double.random(in: 3...5)

    init() {
        resetDevices()
        startTimer()
    }

    func resetDevices() {
        devices = (1...10).map {
            Device(id: UUID(), name: "Device \($0)", isOnline: true, batteryLevel: 100, lastSeen: Date())
        }
    }

    func toggleStatus(for device: Device) {
        if let index = devices.firstIndex(where: { $0.id == device.id }) {
            devices[index].isOnline.toggle()
            if !devices[index].isOnline {
                devices[index].lastSeen = Date()
            }
        }
    }

    func startTimer() {
        timer = Timer.publish(every: updateInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                for i in devices.indices {
                    devices[i].updateStatus()
                }

                if devices.contains(where: { $0.batteryLevel < 20 }) {
                    showBatteryAlert = true
                }
            }
    }

    func stopTimer() {
        timer?.cancel()
    }

    deinit {
        stopTimer()
    }
}
