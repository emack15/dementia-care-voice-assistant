import Foundation
import Combine

import Foundation
import Combine

/*
 ****** NOTE ******
 RIGHT now this is calling the meta llm as sample
 TODO: change to LLM specific to this project (meeting with Mercy) 
 */

struct APIRequest: Codable {
    let model: String
    let messages: [Message]
    let responseFormat: ResponseFormat
    let temperature: Double
    let maxTokens: Int
    let stream: Bool

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case responseFormat = "response_format"
        case temperature
        case maxTokens = "max_tokens"
        case stream
    }
}

struct Message: Codable {
    let role: String
    let content: String
}

struct ResponseFormat: Codable {
    let type: String
    let jsonSchema: JSONSchema

    enum CodingKeys: String, CodingKey {
        case type
        case jsonSchema = "json_schema"
    }
}

struct JSONSchema: Codable {
    let name: String
    let strict: String
    let schema: Schema
}

struct Schema: Codable {
    let type: String
    let properties: [String: Property]
    let required: [String]
}

struct Property: Codable {
    let type: String
}


// API Client to handle the network call
class APIClient: ObservableObject {
    @Published var responseText: String?

    static let shared = APIClient()

    private init() {}

    private let baseURL = "http://127.0.0.1:1234" // API endpoint -> change based on local

    // Inside APIClient class

    func sendPrompt(prompt: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "http://localhost:1234/v1/chat/completions") else { // change based on local
            print("Invalid URL")
            completion(nil) // Call completion with nil if URL is invalid
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody = APIRequest(
            model: "lmstudio-community/Meta-Llama-3.1-8B-Instruct-GGUF/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf",
            messages: [
                Message(role: "system", content: "You are a helpful assistant."),
                Message(role: "user", content: prompt)
            ],
            responseFormat: ResponseFormat(
                type: "json_schema",
                jsonSchema: JSONSchema(
                    name: "response_schema",
                    strict: "true",
                    schema: Schema(
                        type: "object",
                        properties: ["answer": Property(type: "string")],
                        required: ["answer"]
                    )
                )
            ),
            temperature: 0.7,
            maxTokens: 1000,
            stream: false
        )


        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            print("Failed to encode request body: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Request error: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                // Decode the JSON response
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    // Now the content field contains another JSON string, so we need to decode it again
                    if let contentData = content.data(using: .utf8),
                       let innerJson = try JSONSerialization.jsonObject(with: contentData, options: []) as? [String: String],
                       let answer = innerJson["answer"] {
                        // Update the UI with the extracted answer
                        DispatchQueue.main.async {
                            completion(answer) // Call completion with the answer ---- CRUCIAL SO EVERYTHING DISPLAYS IN ORDER
                        }
                    } else {
                        print("Failed to parse the inner JSON from content")
                    }
                } else {
                    print("Failed to extract content from the choices")
                }
            } catch {
                print("Failed to decode response: \(error)")
            }
        }.resume()
    }

}

