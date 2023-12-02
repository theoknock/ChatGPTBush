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
    let date: String
    var messages: [Message] = [Message]()
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

//struct ContentView: View {
//    @State private var text: String = ""
//    @FocusState private var isTextEditorFocused: Bool
//    
//    var body: some View {
//        TextEditor(text: $text)
//            .focused($isTextEditorFocused)
//            .onAppear {
//                // This will set the focus on the TextEditor when the view appears
//                isTextEditorFocused = true
//            }
//    }
//}


struct ContentView: View {
    @State private var senderMessage: String = ""
    @State private var receiverMessage: String = ""
    @State private var isTaskRunning = false
    @FocusState private var isTextEditorFocused: Bool
    @State var height: CGFloat = 20
    @State private var completions: [Completion] = [Completion]()
    
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                List {
                    ForEach(completions) { completion in
                        Section {
                            ForEach(completion.messages) { message in
                                Section {
                                    Text(message.text)
                                        .foregroundColor(Color.primary)
                                } header: {
                                    Text((message.type == MessageType.prompt) ? "Prompt" : "Response")
                                        .listRowSeparator(.hidden)
                                        .foregroundColor(Color.secondary)
                                }
                            }
                        } header: {
                            Text(completion.date)
                        }
                    }
                }
                
                HStack {
                                        ZStack(alignment: .leading) {
                                            Text(senderMessage)
                                                .lineLimit(3)
                                                .font(.callout)
                                                .padding(8)
                                                .background(GeometryReader {
                                                    Color.clear.preference(key: ViewHeightKey.self,
                                                                           value: $0.frame(in: .local).size.height)
                                                })
                                                .hidden()
                                            TextEditor(text: $senderMessage)
                                                .font(.callout)
                                                .frame(height: max(38,height))
                                                .padding(.horizontal, 3)
                                                .border(Color.primary, width: 1.0)
                                                .lineLimit(3)
                                        }
                                        .background(Color.secondary.opacity(0.3))
                                        .cornerRadius(8)
                                        .onPreferenceChange(ViewHeightKey.self) { height = $0 }
                                                            .padding()
                    
                    //                        HStack {
//                    TextEditor(text: $senderMessage)
//                        .autocorrectionDisabled(true)
//                        .multilineTextAlignment(.leading)
//                        .border(Color.secondary, width: 0.08125)
//                        .onKeyPress(.return, action: {
//                            sendMessage(senderMessage)
//                            return .handled
//                        })
//                        .focused($isTextEditorFocused)
//                        .onAppear {
//                            // This will set the focus on the TextEditor when the view appears
//                            isTextEditorFocused = true
//                        }
                    Button(action: {
                        sendMessage(senderMessage)
                    }) {
                        Image(systemName: self.isTaskRunning ? "play.fill" : "play")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .symbolRenderingMode(.monochrome)
                            .fontWeight(.thin)
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(height: geometry.size.height * 0.05, alignment: .center)
                }
                .preferredColorScheme(.dark)
            }
        })
    }
    
    private func sendMessage(_ message: String) {
        let tidyMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        senderMessage = ""
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
                var completion: Completion = Completion(id: sha256(), date: Date().description, messages: [Message]())
                completion.messages.append(Message(id: sha256(), text: tidyMessage, type: MessageType.prompt))
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
                    //                    completion.messages.append(Message(id: sha256(), text: "\(response)", type: MessageType.response))
                }
                if (error != nil) {
                    completion.messages.append(Message(id: sha256(), text: "Error: \(error!.localizedDescription)", type: MessageType.response))
                }
                //                print(completion)
                completions.append(completion)
            }
        }
        task.resume()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            switch task.state {
            case .running:
                print("Task is still running...")
                self.isTaskRunning = true
            case .completed:
                print("Task completed")
                self.isTaskRunning = false
                timer.invalidate()
            case .canceling:
                print("Task is canceling")
                self.isTaskRunning = false
                timer.invalidate()
            case .suspended:
                print("Task is suspended")
                self.isTaskRunning = false
                timer.invalidate()
            @unknown default:
                print("Unknown state")
                self.isTaskRunning = false
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

//struct P239_DynamicTextEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        P239_DynamicTextEditor()
//    }
//}
