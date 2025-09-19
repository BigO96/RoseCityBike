import SwiftUI

struct SettingsView: View {
    // Persisted preferences for lane visibility by color
    @AppStorage("showGreenLanes") private var showGreenLanes: Bool = true
    @AppStorage("showBlueLanes") private var showBlueLanes: Bool = true
    @AppStorage("showRedLanes") private var showRedLanes: Bool = true
    @AppStorage("showYellowLanes") private var showYellowLanes: Bool = true
    @AppStorage("showPurpleLanes") private var showPurpleLanes: Bool = true
    @AppStorage("showGrayLanes") private var showGrayLanes: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Bike Lane Visibility") {
                    colorToggle(title: "Green", color: .green, isOn: $showGreenLanes)
                    colorToggle(title: "Blue", color: .blue, isOn: $showBlueLanes)
                    colorToggle(title: "Red", color: .red, isOn: $showRedLanes)
                    colorToggle(title: "Yellow", color: .yellow, isOn: $showYellowLanes)
                    colorToggle(title: "Purple", color: .purple, isOn: $showPurpleLanes)
                    colorToggle(title: "Gray", color: .gray, isOn: $showGrayLanes)
                }
            }
            .navigationTitle("Settings")
        }
    }

    @ViewBuilder
    private func colorToggle(title: String, color: Color, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 12) {
                Circle()
                    .fill(color)
                    .frame(width: 16, height: 16)
                    .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 0.5))
                Text("Show \(title) Lanes")
            }
        }
    }
}

#Preview {
    SettingsView()
}

