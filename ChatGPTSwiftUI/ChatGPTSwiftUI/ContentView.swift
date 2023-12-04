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

struct SizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct MeasureSizeModifier: ViewModifier {
    @Binding var size: CGSize

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: SizeKey.self, value: geometry.size)
                }
            )
            .onPreferenceChange(SizeKey.self) { preferences in
                self.size = preferences
            }
    }
}

extension View {
    func measureSize(binding size: Binding<CGSize>) -> some View {
        self.modifier(MeasureSizeModifier(size: size))
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
    @State private var textSize: CGSize = .zero

    
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                List {
                    ForEach(completions) { completion in
                        Section {
                            ForEach(completion.messages) { message in
                                Section {
                                    GroupBox {
                                        HStack {
                                            Text(message.text)
                                                .foregroundColor(Color.primary)
                                                .listRowSeparator(.visible)
                                            Spacer()
                                        }
                                    } label: {
                                        HStack {
                                            Text((message.type == MessageType.prompt) ? "PROMPT" : "RESPONSE")
                                                .font(.caption)
                                                .opacity(0.5)
                                                .listRowSeparator(.hidden)
                                                
//                                            Spacer()
                                        }
                                    }
                                    
                                }
                                
                                
                            }
                        } header: {
                            Text(completion.date)
                                .font(.caption)
                                .opacity(0.5)
                                .frame(alignment: Alignment.trailing)
                            Spacer()
                        }
                        .scrollContentBackground(.visible)
                    }
                }
                .background(Color.primary.opacity(0.5))
                .listStyle(SidebarListStyle())
                .padding()
                
                HStack {
                    GroupBox {
                        HStack {
                            ZStack(alignment: .leading) {
                                Text(senderMessage)
                                    .lineLimit(3, reservesSpace: false)
                                    .background(GeometryReader {
                                        Color.clear.preference(key: ViewHeightKey.self,
                                                               value: $0.frame(in: .local).size.height)
                                    })
                                    .hidden()
                                    .font(.body)
                                    .measureSize(binding: $textSize)


                                TextEditor(text: $senderMessage)
                                    .font(.body)
                                    .cornerRadius(10.0)
                                    .frame(height: textSize.height * 1.5)
                                    .padding(.horizontal, 3)
                                    .lineLimit(3, reservesSpace: false)
                                    .autocorrectionDisabled(true)
                                    .multilineTextAlignment(.leading)
                                    .focused($isTextEditorFocused)
                                    .onAppear {
                                        isTextEditorFocused = true
                                    }
//                                    .onKeyPress(.return, action: {
//                                        if senderMessage != nil {
//                                            sendMessage(senderMessage)
//                                        }
//                                        return .handled
//                                    })
                            }
                            .onPreferenceChange(ViewHeightKey.self) { height = $0 }
                            
                            Button(action: {
                                if senderMessage != nil {
                                    sendMessage(senderMessage)
                                }
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
                    } label: {
                        Text("Message ChatGTP...")
                            .font(.caption)
                            .opacity(0.5)
                    }
                }
                .preferredColorScheme(.dark)
            }
        })
    }
    
    /// Processes the user prompt and submit
    /// - Parameter message: <#message description#>
    private func sendMessage(_ message: String) {
        let tidyMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        senderMessage = ""
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
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
                    //                                        completion.messages.append(Message(id: sha256(), text: String(data: data!, encoding: .utf8)!, type: MessageType.prompt))
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                           let choices = jsonResponse["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let messageContent = firstChoice["message"] as? [String: Any],
                           let content = messageContent["content"] as? String {
                            let tidyContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
                            completion.messages.append(Message(id: sha256(), text: tidyContent, type: MessageType.response))
                        }
                    } catch {
                        completion.messages.append(Message(id: sha256(), text: "JSON parsing error: \(error.localizedDescription)", type: MessageType.response))
                    }
                }
                if (response != nil) {
                    //                                        completion.messages.append(Message(id: sha256(), text: "\(response)", type: MessageType.response))
                }
                if (error != nil) {
                    //                    completion.messages.append(Message(id: sha256(), text: "Error: \(error!.localizedDescription)", type: MessageType.response))
                }
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
        P271_CollapsibleText()
        P57_TextField()
        P150_Section()
    }
}
