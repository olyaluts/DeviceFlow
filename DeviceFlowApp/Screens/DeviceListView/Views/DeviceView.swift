import SwiftUI

import SwiftUI

struct DeviceView: View {
    let name: String
    let isOnline: Bool
    let batteryLevel: Int
    let lastSeenStatus: String

    var body: some View {
        HStack {
            Circle()
                .fill(isOnline ? .green : .red)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)

                Text("Battery: \(batteryLevel)%")
                    .font(.subheadline)

                Text(lastSeenStatus)
                    .font(.caption)
                    .foregroundColor(.gray)
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
