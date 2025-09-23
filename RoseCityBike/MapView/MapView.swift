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
    case "SR_LT", "SR": return .blue        // Shared Roadway / Sharrows
    case "MUP", "MUP_P", "TRL": return .purple // Multi-use path / Trail
    case "DC": return .red                  // Difficult/Discontinuous/Construction
    case "NG": return .green                // Neighborhood Greenway
    default: return .gray
    }
}

// MARK: - Main Map View
struct MapView: View {
    private var laneSettings = LaneVisibilitySettings()
    private var zoneSettings = ZoneSettings()
    private var zoomSettings = ZoomSettings()

    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5152, longitude: -122.6784),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    ))
    @State private var segments: [CleanBikeSegment] = []
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var cameraDistance: CLLocationDistance = 0

    // If farther than this, draw nothing
    private let maxDrawDistance: CLLocationDistance = 15000 // 15 km (tune as needed)

    private var zoneSelectionKey: String {
        "\(zoneSettings.zoneNW.wrappedValue ? 1 : 0)-\(zoneSettings.zoneNE.wrappedValue ? 1 : 0)-\(zoneSettings.zoneSE.wrappedValue ? 1 : 0)-\(zoneSettings.zoneSW.wrappedValue ? 1 : 0)"
    }

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(filteredVisibleSegments) { segment in
                MapPolyline(coordinates: segment.coordinates)
                    .stroke(color(forConnectionType: segment.connectionType), lineWidth: 3)
            }
        }
        // load zones when toggles change
        .task(id: zoneSelectionKey) {
            segments = await loadSegmentsFromBundleAsync()
            print("✅ Loaded \(segments.count) segments for zones: \(zoneSelectionKey)")
        }
        // update region & zoom
        .onMapCameraChange(frequency: .onEnd) { ctx in
            visibleRegion = ctx.region
            cameraDistance = ctx.camera.distance
//            print("📷 Distance: \(Int(cameraDistance)) m")
        }
        .ignoresSafeArea()
    }

    // Apply lane visibility, zoom threshold, and region filtering
    private var filteredVisibleSegments: [CleanBikeSegment] {
        // If zoomed out too far → nothing (unless user overrides)
        if !zoomSettings.overrideZoomLimit.wrappedValue {
            guard cameraDistance <= maxDrawDistance else { return [] }
        }
        guard let region = visibleRegion else { return [] }

        let visibleRect = MKMapRect(region)

        return segments.filter { segment in
            // filter by lane visibility toggles
            let laneVisible: Bool = {
                switch color(forConnectionType: segment.connectionType) {
                case .green: return laneSettings.showGreen.wrappedValue
                case .blue: return laneSettings.showBlue.wrappedValue
                case .red: return laneSettings.showRed.wrappedValue
                case .purple: return laneSettings.showPurple.wrappedValue
                case .gray: return laneSettings.showGray.wrappedValue
                default: return true
                }
            }()
            guard laneVisible else { return false }

            // compute bounding box for segment
            var rect = MKMapRect.null
            for coord in segment.coordinates {
                let point = MKMapPoint(coord)
                rect = rect.union(MKMapRect(x: point.x, y: point.y, width: 0.1, height: 0.1))
            }
            return rect.intersects(visibleRect)
        }
    }
}

// MARK: - MKMapRect convenience init
extension MKMapRect {
    init(_ region: MKCoordinateRegion) {
        let topLeft = CLLocationCoordinate2D(
            latitude: region.center.latitude + region.span.latitudeDelta/2,
            longitude: region.center.longitude - region.span.longitudeDelta/2
        )
        let bottomRight = CLLocationCoordinate2D(
            latitude: region.center.latitude - region.span.latitudeDelta/2,
            longitude: region.center.longitude + region.span.longitudeDelta/2
        )

        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)

        self = MKMapRect(
            x: min(a.x, b.x),
            y: min(a.y, b.y),
            width: abs(a.x - b.x),
            height: abs(a.y - b.y)
        )
    }
}

#Preview {
    MapView()
}
