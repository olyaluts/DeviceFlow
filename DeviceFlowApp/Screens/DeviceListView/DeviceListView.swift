import Foundation
import SwiftUI

import SwiftUI

struct DeviceListView: View {
    @Environment(\.dependencies) private var dependencies
    @StateObject private var viewModel: DeviceListViewModel

    init() {
        _viewModel = StateObject(wrappedValue: DeviceListViewModel(
            provider: DependencyContainer.default.devicesProvider
        ))
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
            .refreshable {
                viewModel.refresh()
            }
            .alert("Low Battery!", isPresented: $viewModel.showBatteryAlert) {
                Button("OK", role: .cancel) { }
            }
            .navigationTitle("Devices".localized())
        }
    }
}

struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView()
    }
}
