//
//  ObjectTrackingDemoApp.swift
//  ObjectTrackingDemo
//
//  Created by Uladzislau Volchyk on 27/10/2022.
//

import SwiftUI

@main
struct ObjectTrackingDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StartScreen()
                    .preferredColorScheme(.light)
            }
        }
    }
}
