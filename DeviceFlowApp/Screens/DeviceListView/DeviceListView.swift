import Foundation
import SwiftUI

import SwiftUI

struct DeviceListView: View {
    @StateObject private var viewModel = DeviceListViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.devices) { device in
                    DeviceView(
                        name: device.name,
                        isOnline: device.isOnline,
                        batteryLevel: device.batteryLevel,
                        lastSeenStatus: device.isOnline
                            ? "Online".localized()
                            : "Last seen: \(relativeTime(from: device.lastSeen))"
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.toggleStatus(for: device)
                    }
                }
            }
            .refreshable {
                viewModel.resetDevices()
            }
            .navigationTitle("Devices")
            .alert("Low Battery!", isPresented: $viewModel.showBatteryAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }

    private func relativeTime(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}


struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView()
    }
}
