import SwiftUI

@main
struct DeviceFlowAppApp: App {
    let container = DependencyContainer.default
    let coordinator: AppCoordinator

    init() {
        self.coordinator = AppCoordinator(container: container)
    }

    var body: some Scene {
        WindowGroup {
            coordinator.start()
                .environment(\.dependencies, container)
        }
    }
}
