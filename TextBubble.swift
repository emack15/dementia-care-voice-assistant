//
//  TextBubble.swift
//  DemCareVoice
//
//  Created by Emily Centeno on 9/23/24.
//

import Foundation
import SwiftUI

class TextBubble: Identifiable, Equatable {
    let id = UUID()
    let origin: String
    let backgroundColor: Color
    let foregroundColor: Color
    let textContent: String
    
    init(origin: String, textContent: String) {
        self.origin = origin
        self.textContent = textContent
        if origin == "user" {
            self.backgroundColor = .blue.opacity(0.8)
            self.foregroundColor = .white
        }
        else {
            self.backgroundColor = .gray.opacity(0.15)
            self.foregroundColor = .black
        }
    }
    static func == (lhs: TextBubble, rhs: TextBubble) -> Bool {
        return lhs.origin == rhs.origin && lhs.textContent == rhs.textContent
    }
}
