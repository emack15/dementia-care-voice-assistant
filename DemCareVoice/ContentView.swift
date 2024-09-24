//
//  ContentView.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 9/13/24.
//

import SwiftUI
import SwiftData
import Combine
import Foundation


struct ContentView: View {
    @State private var prompt: String = ""
    @ObservedObject var apiClient = APIClient.shared // Observe changes to the API Client
    @ObservedObject var speechRecognizer = SpeechRecognizer() // Create instance of SpeechRecognizer
    @State private var isRecording = false // Track whether we are currently recording
    @State private var textBubbles: [TextBubble] = []

    
    var body: some View {
        NavigationView { // TODO: Make different views based on what should be loaded (settings, chatbox, etc.)
            VStack {
                // Button to start/stop recording
                //            Button(action: {
                //                if self.isRecording {
                //                    self.speechRecognizer.stopRecording()
                //                    apiClient.sendPrompt(prompt: prompt) // Call the API when the button is pressed
                //                } else {
                //                    self.speechRecognizer.startRecording()
                //                }
                //                self.isRecording.toggle()
                //            })
                //            {
                //                Text(isRecording ? "Stop Recording" : "Start Recording")
                //                    .foregroundColor(.white)
                //                    .padding()
                //                    .background(isRecording ? Color.red : Color.blue)
                //                    .cornerRadius(10)
                //            }
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        ForEach(textBubbles) { bubble in
                            HStack {
                                if bubble.origin == "user" {
                                    Spacer()
                                }
                                Text(bubble.textContent)
                                    .font(.headline)
                                    .foregroundColor(bubble.foregroundColor)
                                    .padding()
                                    .background(bubble.backgroundColor)
                                    .cornerRadius(10)
                                if bubble.origin == "llm" {
                                    Spacer()
                                }
                            }
                        }
                        
                    }
                    // TODO: Update .onChange -> deprecated in iOS 18
                    .onChange(of: textBubbles) { newBubble in
                        if let lastBubble = newBubble.last {
                            scrollViewProxy.scrollTo(lastBubble.id, anchor: .bottom)
                        }
                    }
                }
                Spacer()
                HStack {
                    TextField("Begin typing here", text: $prompt)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        let newBubble = TextBubble(origin: "user", textContent: prompt)
                        textBubbles.append(newBubble)
                        apiClient.sendPrompt(prompt: prompt) { response in
                            if let responseText = response {
                                let responseBubble = TextBubble(origin: "llm", textContent: responseText)
                                textBubbles.append(responseBubble)
                            }
                        }
                        prompt = ""
                    }) {
                        Text("Send") // TODO: change to icon
                    }
                    .padding()
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Chat") { // TODO: change to icon
                        // TODO: add functionality
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") { // TODO: change to icon
                        // TODO: add functionality -> sidebar
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("New Chat") // TODO: set this to be named based on topic?
                        .font(.headline)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
