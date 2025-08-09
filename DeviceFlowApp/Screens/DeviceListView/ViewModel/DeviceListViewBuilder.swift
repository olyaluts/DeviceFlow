import Foundation
import SwiftUI

struct DeviceListViewBuilder {
    @MainActor static func make(with container: DependencyContainer) -> some View {
        let viewModel = DeviceListViewModel(provider: container.devicesProvider)
        return DeviceListView(viewModel: viewModel)
    }
}
