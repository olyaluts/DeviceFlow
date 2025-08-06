import Foundation

protocol DevicesProvider: AnyObject {
    func fetchInitialDevices() -> [Device]
    func updateDeviceStatuses(current: [Device]) -> [Device]
}

