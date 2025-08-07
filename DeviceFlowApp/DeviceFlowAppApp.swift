import SwiftUI

@main
struct DeviceFlowAppApp: App {
    let container = DependencyContainer.default
    
    var body: some Scene {
        WindowGroup {
            DeviceListView()
                .environment(\.dependencies, container)
        }
    }
}
