import SwiftUI

struct SettingsView: View {
    private var laneSettings = LaneVisibilitySettings()
    private var zoneSettings = ZoneSettings()

    var body: some View {
        NavigationStack {
            Form {
                Section("Bike Lane Visibility") {
                    colorToggle(title: "Neighborhood Greenways", description: "Lower-traffic neighborhood streets with markings and wayfinding for cyclists.", color: .green, isOn: laneSettings.showGreen)
                    colorToggle(title: "Bike Lanes", description: "On-street bike lanes (protected, buffered, or standard) and shared roadways.", color: .blue, isOn: laneSettings.showBlue)
                    colorToggle(title: "Difficult Connection", description: "Higher speeds/volumes, narrow lanes, or other challenges.", color: .red, isOn: laneSettings.showRed)
                    colorToggle(title: "Multi-use path", description: "Off-street path closed to motor vehicles. Go slowly, yield to pedestrians.", color: .purple, isOn: laneSettings.showPurple)
                    colorToggle(title: "Unknown", description: "Uncategorized segment.", color: .gray, isOn: laneSettings.showGray)
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
                    Text("Warning, selecting mutipile zones may impact preformace.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }

    @ViewBuilder
    private func colorToggle(title: String, description: String, color: Color, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(color)
                        .frame(width: 16, height: 16)
                        .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 0.5))
                    Text(title)
                }
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
}
