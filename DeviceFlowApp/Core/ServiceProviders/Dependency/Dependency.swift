import Foundation
import SwiftUI

struct DependencyContainer {
    let devicesProvider: DevicesProvider
    static let `default` = DependencyContainer(devicesProvider: DevicesService())
}

private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: DependencyContainer = .default
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}
