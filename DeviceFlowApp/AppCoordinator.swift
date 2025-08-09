import Foundation
import SwiftUI

@MainActor
final class AppCoordinator {
    private let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func start() -> some View {
        DeviceListViewBuilder.make(with: container)
    }
}

