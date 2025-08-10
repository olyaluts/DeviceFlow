import SwiftUI

struct DeviceView: View {
    struct DeviceViewConfiguration {
        let onlineColor: Color
        let offlineColor: Color
        let foregroundTextColor: Color
        
        init() {
            onlineColor = Color("OnlineGreen")
            offlineColor = Color("OfflineRed")
            foregroundTextColor = Color("CustomGray")
        }
    }
    
    let name: String
    let isOnline: Bool
    let batteryLevel: Int
    let lastSeenStatus: String
    let configuration: DeviceViewConfiguration = .init()

    var body: some View {
        HStack {
            Circle()
                .fill(
                    isOnline ? configuration.onlineColor : configuration.offlineColor
                )
                .frame(width: 12, height: 12)

            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)

                Text("Battery: \(batteryLevel)%")
                    .font(.subheadline)

                Text(lastSeenStatus)
                    .font(.caption)
                    .foregroundColor(configuration.foregroundTextColor)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceView(
            name: "Preview Device",
            isOnline: false,
            batteryLevel: 12,
            lastSeenStatus: "Last seen: 5 min ago"
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
