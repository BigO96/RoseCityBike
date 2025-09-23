import SwiftUI

/// Centralized access to zoom/visibility preferences backed by @AppStorage.
/// Use this to allow users to override the zoom-based rendering limit.
struct ZoomSettings {
    // Keys for @AppStorage
    private enum Key: String {
        case overrideZoomLimit
    }

    // Backing storage
    @AppStorage(Key.overrideZoomLimit.rawValue) private var override: Bool = false

    init() {}

    // Binding for SwiftUI
    var overrideZoomLimit: Binding<Bool> { Binding(get: { override }, set: { override = $0 }) }
}
