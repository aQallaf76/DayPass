//
//  ContentView.swift
//  DayPass
//
//  Created by Abdullah Alqallaf on 3/19/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = UserAuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                OnboardingView()
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            authViewModel.checkAuthState()
        }
    }
}

#Preview {
    ContentView()
}
