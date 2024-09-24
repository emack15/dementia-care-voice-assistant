//
//  DemCareVoiceApp.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 9/13/24.
//

import SwiftUI

@main
struct DemCareVoiceApp: App {
    // Initialize the APIClient as a StateObject to ensure it's managed properly
    @StateObject private var apiClient = APIClient.shared

    var body: some Scene {
        WindowGroup {
            // Provide the APIClient to the ContentView using the environmentObject modifier
            ContentView()
                .environmentObject(apiClient)
        }
    }
}
