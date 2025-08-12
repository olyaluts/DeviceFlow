import Foundation
import SwiftUI

struct DeviceListView: View {
    @Environment(\.dependencies) private var dependencies
    @StateObject private var viewModel: DeviceListViewModel

    init(viewModel: DeviceListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.devices) { device in
                    DeviceView(
                        name: device.name,
                        isOnline: device.isOnline,
                        batteryLevel: device.batteryLevel,
                        lastSeenStatus: viewModel.statusText(for: device)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.toggleStatus(for: device)
                    }
                }
            }
            .task {
                viewModel.loadInitialData()
            }
            .refreshable {
                await viewModel.refresh()
            }
            .alert(
                "Low Battery!".localized(),
                isPresented: Binding(
                    get: { viewModel.showBatteryAlert },
                    set: { viewModel.setShowBatteryAlert($0) }
                )
            ) {
                Button("OK".localized(), role: .cancel) { }
            }
            .navigationTitle("Devices".localized())
        }
    }
}

struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockDevices = [
            Device(id: UUID(), name: "iPhone 13", isOnline: true, batteryLevel: 87, lastSeen: Date()),
            Device(id: UUID(), name: "iPad Air", isOnline: false, batteryLevel: 15, lastSeen: Date().addingTimeInterval(-300)),
            Device(id: UUID(), name: "iPhone 14", isOnline: true, batteryLevel: 100, lastSeen: Date())
        ]
        
        let mockProvider = MockDevicesService(initialDevices: mockDevices)
        let mockViewModel = DeviceListViewModel(provider: mockProvider)
        
        return DeviceListView(viewModel: mockViewModel)
    }
}
