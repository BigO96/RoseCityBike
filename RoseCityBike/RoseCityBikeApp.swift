//
//  RoseCityBikeApp.swift
//  RoseCityBike
//
//  Created by Oscar Epp on 9/18/25.
//

import SwiftUI
import Foundation

@main
struct RoseCityBikeApp: App {
    init() {
        Self.resetSettingsOnLaunch()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    private static func resetSettingsOnLaunch() {
        let defaults = UserDefaults.standard
        let keys = [
            "showGreenLanes",
            "showBlueLanes",
            "showRedLanes",
            "showPurpleLanes",
            "showGrayLanes",
            "zoneNWEnabled",
            "zoneNEEnabled",
            "zoneSEEnabled",
            "zoneSWEnabled"
        ]
        for key in keys {
            defaults.set(false, forKey: key)
        }
    }
}
