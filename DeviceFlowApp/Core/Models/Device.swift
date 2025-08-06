import Foundation

struct Device: Codable, Identifiable {
    let id: UUID
    let name: String
    var isOnline: Bool
    var batteryLevel: Int
    var lastSeen: Date
    
    mutating func updateStatus() {
        isOnline = Bool.random(probability: 0.9)
        if isOnline {
            batteryLevel = max(batteryLevel - Int.random(in: 1...3), 0)
        } else {
            lastSeen = Date()
        }
    }
}

extension Bool {
    static func random(probability: Double) -> Bool {
        return Double.random(in: 0...1) < probability
    }
}
