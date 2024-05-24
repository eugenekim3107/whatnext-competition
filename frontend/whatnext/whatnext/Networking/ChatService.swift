//
//  ChatService.swift
//  whatnext
//
//  Created by Eugene Kim on 2/10/24.
//

import Foundation

enum DecodedMessage {
    case regular(Message)
    case secondary(MessageSecondary)
}

struct GenericMessageResponse: Decodable {
    let chat_type: String
}

class ChatService {
    static let shared = ChatService()

    private init() {}

    func postMessage(latitude: Double,
                     longitude: Double,
                     userId: String,
                     sessionId: String?,
                     message: String,
                     completion: @escaping (DecodedMessage?, Error?) -> Void) {
        
        guard let url = URL(string: "https://api.whatnext.live/chatgpt_response") else { return }

        
        var requestBody: [String: Any] = [
            "user_id": userId,
            "message": message,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        if let sessionId = sessionId {
            requestBody["session_id"] = sessionId
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("whatnext", forHTTPHeaderField: "whatnext_token")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                guard let data = data else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                }
                
                let genericDecoder = JSONDecoder()
                let genericResponse = try genericDecoder.decode(GenericMessageResponse.self, from: data)
                
                if genericResponse.chat_type == "regular" {
                    let messageResponse = try genericDecoder.decode(Message.self, from: data)
                    DispatchQueue.main.async {
                        completion(.regular(messageResponse), nil)
                    }
                } else {
                    let messageSecondaryResponse = try genericDecoder.decode(MessageSecondary.self, from: data)
                    DispatchQueue.main.async {
                        completion(.secondary(messageSecondaryResponse), nil)
                    }
                }
            } catch {
                let errorMessageResponse = Message(
                    session_id: "",
                    user_id: userId,
                    content: "An error has occurred. Please try again. Thank you!",
                    chat_type: "regular",
                    is_user_message: "false"
                )
                DispatchQueue.main.async {
                    completion(.regular(errorMessageResponse), nil)
                }
            }
        }.resume()
    }
}

struct Message: Hashable, Decodable, Identifiable {
    let id: UUID
    let session_id: String?
    let user_id: String
    let content: String
    let chat_type: String
    let is_user_message: String

    enum CodingKeys: String, CodingKey {
        case session_id, user_id, content, chat_type, is_user_message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        session_id = try container.decodeIfPresent(String.self, forKey: .session_id)
        user_id = try container.decode(String.self, forKey: .user_id)
        content = try container.decode(String.self, forKey: .content)
        chat_type = try container.decode(String.self, forKey: .chat_type)
        is_user_message = try container.decode(String.self, forKey: .is_user_message)
    }

    init(session_id: String?, user_id: String, content: String, chat_type: String, is_user_message: String) {
        self.id = UUID()
        self.session_id = session_id
        self.user_id = user_id
        self.content = content
        self.chat_type = chat_type
        self.is_user_message = is_user_message
    }
}

struct MessageSecondary: Hashable, Decodable {
    let session_id: String?
    let user_id: String
    let content: [Location]
    let chat_type: String
    let is_user_message: String
}
