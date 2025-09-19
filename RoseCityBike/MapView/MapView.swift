import SwiftUI
import MapKit
import Foundation

// Represents a cleaned, drawable bike segment from the GeoJSON
struct CleanBikeSegment: Identifiable {
    let id: Int
    let streetName: String
    let connectionType: String
    let coordinates: [CLLocationCoordinate2D]
}

// MARK: - Load all JSON files from bundle root
private func loadSegmentsFromBundle() -> [CleanBikeSegment] {
    // Attempt to load a single bundled file named "MapData.json" (or "MapData" without extension)
    let possibleURLs: [URL?] = [
        Bundle.main.url(forResource: "MapData", withExtension: "json"),
        Bundle.main.url(forResource: "MapData", withExtension: nil)
    ]

    guard let fileURL = possibleURLs.compactMap({ $0 }).first,
          let data = try? Data(contentsOf: fileURL),
          let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
        print("⚠️ Could not find or parse MapData in app bundle.")
        return []
    }

    var cleaned: [CleanBikeSegment] = []
    cleaned.reserveCapacity(items.count)

    for item in items {
        // id can be Int or String
        let id = (item["id"] as? Int)
            ?? Int((item["id"] as? String) ?? "")
            ?? cleaned.count + 1

        let streetName = (item["street_name"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "Unnamed"
        let connectionType = (item["connection_type"] as? String)?.uppercased() ?? "UNKNOWN"

        guard let coordsAny = item["coordinates"] as? [[Any]] else { continue }

        var coords: [CLLocationCoordinate2D] = []
        coords.reserveCapacity(coordsAny.count)
        for pair in coordsAny {
            if pair.count >= 2,
               let lon = (pair[0] as? NSNumber)?.doubleValue ?? Double("\(pair[0])"),
               let lat = (pair[1] as? NSNumber)?.doubleValue ?? Double("\(pair[1])"),
               lon.isFinite, lat.isFinite {
                coords.append(.init(latitude: lat, longitude: lon))
            }
        }
        guard coords.count >= 2 else { continue }

        cleaned.append(.init(id: id, streetName: streetName, connectionType: connectionType, coordinates: coords))
    }

    return cleaned
}

// Async wrapper
private func loadSegmentsFromBundleAsync() async -> [CleanBikeSegment] {
    await withCheckedContinuation { continuation in
        DispatchQueue.global(qos: .userInitiated).async {
            continuation.resume(returning: loadSegmentsFromBundle())
        }
    }
}

// MARK: - Connection type color mapping
private func color(forConnectionType code: String) -> Color {
    switch code.uppercased() {
    case "BL": return .blue                 // Bike Lane
    case "BBL": return .blue                // Buffered Bike Lane
    case "BBBL": return .blue             // Bike Lane Buffered by Bus Lane
    case "PBL": return .blue                // Protected Bike Lane
    case "SR_LT", "SR": return .orange     // Shared Roadway / Sharrows
    case "MUP", "MUP_P", "TRL": return .purple // Multi-use path / Trail
    case "DC": return .red                  // Difficult/Discontinuous/Construction
    case "NG": return .green                // Neighborhood Greenway
    default: return .gray
    }
}

// MARK: - Main Map View
struct MapView: View {
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5152, longitude: -122.6784),
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    ))
    @State private var segments: [CleanBikeSegment] = []

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(segments) { segment in
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
}

#Preview() {
    MapView()
}
