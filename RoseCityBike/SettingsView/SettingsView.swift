import SwiftUI

struct SettingsView: View {
    private var laneSettings = LaneVisibilitySettings()
    private var zoneSettings = ZoneSettings()

    var body: some View {
        NavigationStack {
            Form {
                Section("Bike Lane Visibility") {
                    colorToggle(title: "Green", color: .green, isOn: laneSettings.showGreen)
                    colorToggle(title: "Blue", color: .blue, isOn: laneSettings.showBlue)
                    colorToggle(title: "Red", color: .red, isOn: laneSettings.showRed)
                    colorToggle(title: "Yellow", color: .yellow, isOn: laneSettings.showYellow)
                    colorToggle(title: "Purple", color: .purple, isOn: laneSettings.showPurple)
                    colorToggle(title: "Gray", color: .gray, isOn: laneSettings.showGray)
                }
                Section("City Zones") {
                    Toggle(isOn: zoneSettings.zoneNW) {
                        Label("Northwest (NW)", systemImage: "square.grid.2x2")
                    }
                    Toggle(isOn: zoneSettings.zoneNE) {
                        Label("Northeast (NE)", systemImage: "square.grid.2x2")
                    }
                    Toggle(isOn: zoneSettings.zoneSE) {
                        Label("Southeast (SE)", systemImage: "square.grid.2x2")
                    }
                    Toggle(isOn: zoneSettings.zoneSW) {
                        Label("Southwest (SW)", systemImage: "square.grid.2x2")
                    }
                    Text("Turn ON to load data for the selected zones.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
