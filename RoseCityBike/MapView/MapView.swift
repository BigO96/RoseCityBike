import SwiftUI
import MapKit
import Foundation

// MARK: - Connection type color mapping
private func color(forConnectionType code: String) -> Color {
    switch code.uppercased() {
    case "BL": return .blue                 // Bike Lane
    case "BBL": return .blue                // Buffered Bike Lane
    case "BBBL": return .blue               // Bike Lane Buffered by Bus Lane
    case "PBL": return .blue                // Protected Bike Lane
    case "SR_LT", "SR": return .blue      // Shared Roadway / Sharrows
    case "MUP", "MUP_P", "TRL": return .purple // Multi-use path / Trail
    case "DC": return .red                  // Difficult/Discontinuous/Construction
    case "NG": return .green                // Neighborhood Greenway
    default: return .gray
    }
}

// MARK: - Main Map View
struct MapView: View {
    // Visibility preferences from SettingsView
    private var laneSettings = LaneVisibilitySettings()

    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5152, longitude: -122.6784),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    ))
    @State private var segments: [CleanBikeSegment] = []

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(filteredSegments) { segment in
                MapPolyline(coordinates: segment.coordinates)
                    .stroke(color(forConnectionType: segment.connectionType), lineWidth: 3)
            }
        }
        .task {
            let loaded = await loadSegmentsFromBundleAsync()
            segments = loaded
            print("✅ Loaded \(segments.count) segments from JSON files")
        }
        .ignoresSafeArea()
    }

    // Apply user preferences for lane visibility
    private var filteredSegments: [CleanBikeSegment] {
        segments.filter { segment in
            switch color(forConnectionType: segment.connectionType) {
            case .green: return laneSettings.showGreen.wrappedValue
            case .blue: return laneSettings.showBlue.wrappedValue
            case .red: return laneSettings.showRed.wrappedValue
            case .yellow: return laneSettings.showYellow.wrappedValue
            case .purple: return laneSettings.showPurple.wrappedValue
            case .gray: return laneSettings.showGray.wrappedValue
            default: return true
            }
        }
    }
}

#Preview {
    MapView()
}
