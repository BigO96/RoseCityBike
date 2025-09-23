//
//  MapDataLoad.swift
//  RoseCityBike
//
//  Created by Oscar Epp on 9/22/25.
//

import SwiftUI
import MapKit
import Foundation

// Represents the four city zones, matching JSON filenames
enum CityZone: String, CaseIterable {
    case NW, NE, SE, SW

    var fileName: String { rawValue } // e.g., "NW" -> NW.json
}

// Access enabled zones using @AppStorage keys defined in ZoneSettings
private struct EnabledZonesReader {
    @AppStorage("zoneNWEnabled") private var nw: Bool = false
    @AppStorage("zoneNEEnabled") private var ne: Bool = false
    @AppStorage("zoneSEEnabled") private var se: Bool = false
    @AppStorage("zoneSWEnabled") private var sw: Bool = false

    func enabledZones() -> [CityZone] {
        var zones: [CityZone] = []
        if nw { zones.append(.NW) }
        if ne { zones.append(.NE) }
        if se { zones.append(.SE) }
        if sw { zones.append(.SW) }
        return zones
    }
}

// Represents a cleaned, drawable bike segment from the GeoJSON
struct CleanBikeSegment: Identifiable {
    let id: Int
    let streetName: String
    let connectionType: String
    let coordinates: [CLLocationCoordinate2D]
}

// MARK: - Load all JSON files from bundle root
func loadSegmentsFromBundle() -> [CleanBikeSegment] {
    let reader = EnabledZonesReader()
    let zones = reader.enabledZones()

    var urls: [URL] = []

    if zones.isEmpty {
        // Fallback to original behavior: try MapData.json
        if let url = Bundle.main.url(forResource: "MapData", withExtension: "json") ?? Bundle.main.url(forResource: "MapData", withExtension: nil) {
            urls = [url]
        }
    } else {
        // Collect URLs for each enabled zone file (e.g., NW.json)
        for zone in zones {
            if let url = Bundle.main.url(forResource: zone.fileName, withExtension: "json") {
                urls.append(url)
            } else if let urlNoExt = Bundle.main.url(forResource: zone.fileName, withExtension: nil) {
                urls.append(urlNoExt)
            } else {
                print("⚠️ Missing JSON for zone: \(zone.rawValue)")
            }
        }
    }

    guard !urls.isEmpty else {
        print("⚠️ No JSON files found for selected zones and no MapData fallback.")
        return []
    }

    var cleaned: [CleanBikeSegment] = []
    var nextId = 1

    for fileURL in urls {
        guard let data = try? Data(contentsOf: fileURL),
              let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            print("⚠️ Could not parse JSON at: \(fileURL.lastPathComponent)")
            continue
        }

        for item in items {
            // id can be Int or String; otherwise assign sequential id to ensure uniqueness across files
            let id = (item["id"] as? Int)
                ?? Int((item["id"] as? String) ?? "")
                ?? { defer { nextId += 1 }; return nextId }()

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
    }

    return cleaned
}

// Async wrapper
func loadSegmentsFromBundleAsync() async -> [CleanBikeSegment] {
    await withCheckedContinuation { continuation in
        DispatchQueue.global(qos: .userInitiated).async {
            continuation.resume(returning: loadSegmentsFromBundle())
        }
    }
}

