import SwiftUI

/// Centralized access to lane visibility preferences backed by @AppStorage.
/// Use this in views to avoid redeclaring the same keys over and over.
struct LaneVisibilitySettings {
    // Keys
    private enum Key: String {
        case showGreenLanes
        case showBlueLanes
        case showRedLanes
        case showYellowLanes
        case showPurpleLanes
        case showGrayLanes
    }

    // One source of truth for default values
    private static let defaultValue: Bool = true

    // Backing storage wrappers. These are initialized with default values and keys.
    // Using private(set) to prevent external mutation of wrappers; mutate via the bindings.
    @AppStorage(Key.showGreenLanes.rawValue) private var green: Bool = defaultValue
    @AppStorage(Key.showBlueLanes.rawValue)  private var blue: Bool  = defaultValue
    @AppStorage(Key.showRedLanes.rawValue)   private var red: Bool   = defaultValue
    @AppStorage(Key.showYellowLanes.rawValue) private var yellow: Bool = defaultValue
    @AppStorage(Key.showPurpleLanes.rawValue) private var purple: Bool = defaultValue
    @AppStorage(Key.showGrayLanes.rawValue)   private var gray: Bool   = defaultValue

    init() {}

    // Convenience accessors
    var showGreen: Binding<Bool> { Binding(get: { green }, set: { green = $0 }) }
    var showBlue: Binding<Bool>  { Binding(get: { blue },  set: { blue  = $0 }) }
    var showRed: Binding<Bool>   { Binding(get: { red },   set: { red   = $0 }) }
    var showYellow: Binding<Bool> { Binding(get: { yellow }, set: { yellow = $0 }) }
    var showPurple: Binding<Bool> { Binding(get: { purple }, set: { purple = $0 }) }
    var showGray: Binding<Bool>   { Binding(get: { gray },   set: { gray   = $0 }) }
}
