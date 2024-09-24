//
//  SpeechRecognizer.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 9/14/24.
//

import Foundation
import Speech

class SpeechRecognizer: ObservableObject {
    @Published var recognizedText = "" // Holds the recognized text

    private var audioEngine = AVAudioEngine() // Handles audio input
    private var speechRecognizer = SFSpeechRecognizer() // Speech recognizer instance
    private var request = SFSpeechAudioBufferRecognitionRequest() // Handles audio data for recognition
    private var recognitionTask: SFSpeechRecognitionTask?

    // Request permission for speech recognition
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized.")
            case .denied, .restricted, .notDetermined:
                print("Speech recognition not authorized.")
            default:
                break
            }
        }
    }

    // Start listening and converting speech to text
    func startRecording() {
        // Make sure the audio engine is not already running
        if audioEngine.isRunning {
            stopRecording()
            return
        }

        // Setup the audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
        }

        // Prepare audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer) // Append audio buffer for recognition
        }

        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine could not start: \(error.localizedDescription)")
        }

        // Start speech recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString // Update the recognized text
                }
            }

            if let error = error {
                print("Speech recognition error: \(error.localizedDescription)")
                self.stopRecording()
            }
        }
    }

    // Stop recording and reset the task
    func stopRecording() {
        audioEngine.stop()
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    

}

