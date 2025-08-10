import XCTest
import Foundation
@testable import DeviceFlowApp

@MainActor
final class DeviceListViewModelTests: XCTestCase {
    
    // MARK: - Helpers
    
    private func buildViewModel(initial: [Device]) -> DeviceListViewModel {
        let provider = MockDevicesService(initialDevices: initial)
        let viewModel = DeviceListViewModel(provider: provider)
        viewModel.loadInitialData()
        return viewModel
    }
    
    // MARK: - Tests
    
    func testManualToggleIsAfterProviderUpdate() {
        // Given
        let id = UUID()
        let lastSeen = Date().addingTimeInterval(-3600)
        let initial = [
            Device(
                id: id,
                name: "iPhone",
                isOnline: true,
                batteryLevel: 80,
                lastSeen: lastSeen
            )
        ]
        let viewModel = buildViewModel(initial: initial)
        
        viewModel.toggleStatus(for: viewModel.devices[0])
        XCTAssertFalse(viewModel.devices[0].isOnline)
        
        viewModel.test_updateStatuses()
        
        // Then
        XCTAssertEqual(viewModel.devices[0].batteryLevel, 79)
        XCTAssertFalse(viewModel.devices[0].isOnline, "Manual toggle must be preserved after update")
    }
    
    func testZeroBattery() {
        // Given
        let id = UUID()
        let oldLastSeen = Date().addingTimeInterval(-7200)
        let initial = [
            Device(
                id: id,
                name: "iPad",
                isOnline: true,
                batteryLevel: 1,
                lastSeen: oldLastSeen
            )
        ]
        let viewModel = buildViewModel(initial: initial)
        
        viewModel.toggleStatus(for: viewModel.devices[0])
        viewModel.toggleStatus(for: viewModel.devices[0])
        
        // When
        let before = Date()
        viewModel.test_updateStatuses()
        let after = Date()
        
        // Then
        let device = viewModel.devices[0]
        XCTAssertEqual(device.batteryLevel, 0)
        XCTAssertFalse(device.isOnline, "Device must be forced offline at 0% battery")
        XCTAssert(device.lastSeen >= before && device.lastSeen <= after,
                  "lastSeen should be set to 'now' when forced offline at 0%")
    }
    
    func testShowBatteryAlert() {
        // Given
        let dev1 = Device(
            id: UUID(),
            name: "iPhone",
            isOnline: true,
            batteryLevel: 100,
            lastSeen: Date()
        )
        let dev2 = Device(
            id: UUID(),
            name: "Watch",
            isOnline: true,
            batteryLevel: 19,
            lastSeen: Date()
        )
        let vm = buildViewModel(initial: [dev1, dev2])
        
        // When
        vm.test_updateStatuses()
        
        // Then
        XCTAssertTrue(vm.showBatteryAlert, "showBatteryAlert should be true if any device < 20%")
    }
    
    func test_ToggleBlocked_WhenBatteryIsZero() {
        // Given
        let id = UUID()
        let initial = [
            Device(id: id, name: "Sensor", isOnline: false, batteryLevel: 0, lastSeen: Date())
        ]
        let viewModel = buildViewModel(initial: initial)
        
        viewModel.toggleStatus(for: viewModel.devices[0])
        
        // Then
        XCTAssertFalse(viewModel.devices[0].isOnline, "Toggle should be blocked when battery is 0%")
        XCTAssertEqual(viewModel.devices[0].batteryLevel, 0)
    }
    
    func test_Refresh_ResetsManualSet() async {
        // Given
        let id = UUID()
        let initial = [
            Device(id: id, name: "Phone", isOnline: true, batteryLevel: 50, lastSeen: Date())
        ]
        let viewModel = buildViewModel(initial: initial)
        
        viewModel.toggleStatus(for: viewModel.devices[0])
        XCTAssertFalse(viewModel.devices[0].isOnline)
        
        // When
        await viewModel.refresh()
        
        XCTAssertTrue(viewModel.devices[0].isOnline, "Manual toggles must be cleared after refresh()")
        XCTAssertEqual(viewModel.devices[0].batteryLevel, 50)
    }
    
    func testStatusTex() {
        // Given
        let now = Date()
        let past = now.addingTimeInterval(-120)
        let online = Device(
            id: UUID(),
            name: "iPhone",
            isOnline: true,
            batteryLevel: 80,
            lastSeen: past
        )
        let offline = Device(
            id: UUID(),
            name: "iPad",
            isOnline: false,
            batteryLevel: 40,
            lastSeen: past
        )
        let viewModel = buildViewModel(initial: [online, offline])
        
        // When
        let onlineText = viewModel.statusText(for: viewModel.devices[0])
        let offlineText = viewModel.statusText(for: viewModel.devices[1])
        
        // Then
        XCTAssertTrue(onlineText.localizedCaseInsensitiveContains("online"))
        XCTAssertTrue(offlineText.localizedCaseInsensitiveContains("last seen"))
    }
}
