//
//  ContentView.swift
//  ChatGPTSwiftUI
//
//  Created by Xcode Developer on 11/28/23.
//

import SwiftUI
import CryptoKit

func sha256() -> String {
    let hash = SHA256.hash(data: String(Date().timeIntervalSince1970).data(using: .utf8)!)
    return hash.compactMap { String(format: "%02x", $0) }.joined()
}

enum MessageType {
    case prompt
    case response
}

struct Message: Identifiable, Equatable, Hashable {
    let id: String
    let text: String
    let type: MessageType
}

struct Completion: Identifiable, Equatable, Hashable {
    let id: String
    var messages: [Message] = [Message]()
}


struct ContentView: View {
    @State private var senderMessage: String = ""
    @State private var receiverMessage: String = ""
    @State private var isTaskRunning = false
    @State private var completions: [Completion] = [Completion]()
    
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                VStack {
                    List {
                        ForEach(completions) { completion in
                            Section {
                                ForEach(completion.messages) { message in
                                    VStack {
                                        Section {
                                            Text(message.text)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .cornerRadius(10, antialiased: true)
                                                .foregroundColor(Color.primary)
                                        } header: {
                                            Text((message.type == MessageType.prompt) ? "Prompt" : "Response")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .cornerRadius(10, antialiased: true)
                                                .listRowSeparator(.hidden)
                                                .foregroundColor(Color.secondary)
                                        }
                                        .listSectionSeparator(.hidden)
                                        .preferredColorScheme(.dark)
                                        .padding(.horizontal)
                                        
                                    }
                                    .frame(width: geometry.size.width , alignment: .leading)
                                    .padding(.horizontal)
                                }
                                .frame(width: geometry.size.width, alignment: .leading)
                                .padding(.horizontal)
                            }
                        }
                    }
                    HStack {
                        TextEditor(text: $senderMessage)
                            .multilineTextAlignment(.leading)
                            .border(Color.secondary, width: 3.0)
                            .onKeyPress(.return, action: {
                                sendMessage(senderMessage)
                                return .handled
                            })
                        Button(action: {
                            sendMessage(senderMessage)
                            self.isTaskRunning.toggle()
                        }) {
                            Image(systemName: self.isTaskRunning ? "play.fill" : "play")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .symbolRenderingMode(.monochrome)
                                .fontWeight(.thin)
                                .foregroundStyle(Color.secondary)
                        }
                        .border(Color.secondary, width: 3.0)
                    }
                    .frame(height: geometry.size.height * 0.0625, alignment: .leading)
                }
            }
            .preferredColorScheme(.dark)
        })
    }
    
    //        GeometryReader(content: { geometry in
    //            VStack {
    //                VStack {
    //                    Group {
    //
    //                        List(messages) { message in
    //                            Section {
    //                                Text(message.text)
    //                                    .frame(maxWidth: .infinity, alignment: .leading)
    //                                    .cornerRadius(10, antialiased: true)
    //                                    .foregroundColor(Color.primary)
    //                            } header: {
    //                                Text((message.type == .prompt) ? "Prompt" : "Response")
    //                                    .frame(maxWidth: .infinity, alignment: .leading)
    //                                    .cornerRadius(10, antialiased: true)
    //                                    .listRowSeparator(.hidden)
    //                                    .foregroundColor(Color.secondary)
    //                            }
    //                            .listSectionSeparator(.hidden)
    //                        }
    //                        .listStyle(.insetGrouped)
    //                        .preferredColorScheme(.dark)
    //                    }
    //                }
    //                .border(Color.secondary, width: 3.0)
    //
    //                HStack {
    //                    TextEditor(text: $senderMessage)
    //                        .multilineTextAlignment(.leading)
    //                        .border(Color.secondary, width: 3.0)
    //                        .onKeyPress(.return, action: {
    //                            sendMessage(senderMessage)
    //                            return .handled
    //                        })
    //                    Button(action: {
    //                        sendMessage(senderMessage)
    //                    }) {
    //                        Image(systemName: "play")
    //                            .resizable()
    //                            .aspectRatio(contentMode: .fit)
    //                            .symbolRenderingMode(.monochrome)
    //                            .fontWeight(.thin)
    //                            .foregroundStyle(Color.secondary)
    //                    }
    //                    .border(Color.secondary, width: 3.0)
    //                }
    //                .frame(height: geometry.size.height * 0.0625, alignment: .leading)
    //            }
    //        })
    //    }
    
    //    private func addMessage(completion: inout Completion, text: String, type: MessageType) {
    //        guard !text.isEmpty else { return }
    //        let newMessage = Message(idtext: text, type: type)
    ////        var newChat = Completion()
    //        let index = (completion.messages.count != 0) ? completion.messages.count - 1 : 0
    //        completion.messages[index] = newMessage //.append(newMessage)
    ////        completions.append(newChat)
    //    }
    
    private func sendMessage(_ message: String) {
        let tidyMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer ", forHTTPHeaderField: "Authorization")
        
        request.addValue("org-jGOqXYFRJHKlnkff8K836fK2", forHTTPHeaderField: "OpenAI-Organization")
        
        let payload: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "user", "content": tidyMessage]
            ],
            "temperature": 1,
            "max_tokens": 256,
            "top_p": 1,
            "frequency_penalty": 0,
            "presence_penalty": 0
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: payload, options: [])
        
        request.httpBody = jsonData
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                var completion: Completion = Completion(id: sha256(), messages: [Message]())
                completion.messages.append(Message(id: sha256(), text: tidyMessage, type: MessageType.prompt))
                senderMessage = ""
                if (data != nil) {
//                    completion.messages.append(Message(id: sha256(), text: String(data: data!, encoding: .utf8)!, type: MessageType.prompt))
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                           let choices = jsonResponse["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let messageContent = firstChoice["message"] as? [String: Any],
                           let content = messageContent["content"] as? String {
                            completion.messages.append(Message(id: sha256(), text: content, type: MessageType.response))
                        }
                    } catch {
                        completion.messages.append(Message(id: sha256(), text: "JSON parsing error: \(error.localizedDescription)", type: MessageType.response))
                    }
                }
                if (response != nil) {
//                    completion.messages.append(Message(id: sha256(), text: "respond", type: MessageType.response))
                }
                if (error != nil) {
                    completion.messages.append(Message(id: sha256(), text: "Error: \(error!.localizedDescription)", type: MessageType.response))
                }
                print(completion)
                completions.append(completion)
            }
        }
            task.resume()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            switch task.state {
            case .running:
                print("Task is still running...")
            case .completed:
                print("Task completed")
                self.isTaskRunning.toggle()
                timer.invalidate()
            case .canceling:
                print("Task is canceling")
                self.isTaskRunning.toggle()
                timer.invalidate()
            case .suspended:
                print("Task is suspended")
                self.isTaskRunning.toggle()
                timer.invalidate()
            @unknown default:
                print("Unknown state")
                self.isTaskRunning.toggle()
                timer.invalidate()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
