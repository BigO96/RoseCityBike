//
//  ZoneSettings.swift
//  RoseCityBike
//
//  Created by Assistant on 9/23/25.
//

import SwiftUI

/// Centralized access to zone loading preferences backed by @AppStorage.
/// Use this in Settings UI to toggle which city zones to load.
struct ZoneSettings {
    // Keys
    private enum Key: String {
        case zoneNWEnabled
        case zoneNEEnabled
        case zoneSEEnabled
        case zoneSWEnabled
    }

    // Default to OFF so users explicitly choose zones to load
    private static let defaultValue: Bool = false

    // Backing storage
    @AppStorage(Key.zoneNWEnabled.rawValue) private var nw: Bool = defaultValue
    @AppStorage(Key.zoneNEEnabled.rawValue) private var ne: Bool = defaultValue
    @AppStorage(Key.zoneSEEnabled.rawValue) private var se: Bool = defaultValue
    @AppStorage(Key.zoneSWEnabled.rawValue) private var sw: Bool = defaultValue

    init() {}

    // Bindings for SwiftUI
    var zoneNW: Binding<Bool> { Binding(get: { nw }, set: { nw = $0 }) }
    var zoneNE: Binding<Bool> { Binding(get: { ne }, set: { ne = $0 }) }
    var zoneSE: Binding<Bool> { Binding(get: { se }, set: { se = $0 }) }
    var zoneSW: Binding<Bool> { Binding(get: { sw }, set: { sw = $0 }) }
}
