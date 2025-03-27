//
//  DayPassApp.swift
//  DayPass
//
//  Created by Abdullah Alqallaf on 3/19/25.
//

import SwiftUI
import Firebase

@main
struct DayPassApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
