//
//  ViewController.swift
//  URLSessionTest
//
//  Created by Xcode Developer on 11/20/23.
//

import UIKit
import Foundation

struct ChatResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let role: String
    let content: String
}


class ViewController: UIViewController {
    
    @IBOutlet weak var logTextField: UITextView!
    
    enum Role {
        case prompt
        case response
    }
    
    var logger: (UITextView) -> (String, Role) -> Void = { textView in
        return { entry, role in
            DispatchQueue.main.async {
                var attributedString = NSMutableAttributedString(string: entry, attributes:
                                                                    [NSAttributedString.Key.font :
                                                                        UIFont.monospacedSystemFont(ofSize: 15.0, weight: UIFont.Weight.regular),
                                                                     NSAttributedString.Key.foregroundColor :
                                                                        UIColor.lightGray])
                
                var composition = NSMutableAttributedString(attributedString: textView.attributedText)
                composition.append(attributedString)
                
                DispatchQueue.main.async {
                    textView.attributedText = composition
                }
            }
        }
    }
    
    func getEnvironmentVar(name: String, text_view_logger: ((String, Role) -> Void)?) -> String? {
        let rawValue = getenv(name)
        guard rawValue != nil else { return nil }
        let env_var_value = String(cString: rawValue!, encoding: .utf8) ?? "\n---\nValue for key: \(name) not found\n---\n"
        (text_view_logger ?? logger(self.logTextField))(env_var_value, Role.response)
        
        return String(cString: rawValue!, encoding: .utf8)
    }
    
    func env_var_values() -> () {
        let key_vals: Dictionary<String, String> = ProcessInfo.processInfo.environment
        for key_val in key_vals {
            print(key_val)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textViewLogger = logger(self.logTextField)
        getEnvironmentVar(name: "OS_ACTIVITY_TOOLS_OVERSIZE", text_view_logger: textViewLogger)
        print("\n---\n")
        
        func models() {
            let urlString = "https://api.openai.com/v1/models"
            if let url = URL(string: urlString) {
                var request = URLRequest(url: url)
                request.httpMethod = "GET" // or "POST"
                request.addValue("Bearer ", forHTTPHeaderField: "Authorization")
                request.addValue("org-jGOqXYFRJHKlnkff8K836fK2", forHTTPHeaderField: "OpenAI-Organization")
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        textViewLogger("Error: \(error)", Role.response)
                        return
                    }
                    
                    if let response = response as? HTTPURLResponse {
                        textViewLogger("Response: \(response)", Role.response)
                    }
                    
                    if let data = data {
                        if let dataString = String(data: data, encoding: .utf8) {
                            textViewLogger("Data: \(dataString)", Role.response)
                        }
                    }
                }
                
                task.resume()
            }
        }
        
        //        models()
        
        
        struct ChatGPTResponse: Codable {
            var message: String
        }
        
        var encoded_data: Data?
        
        func completions() {
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer ", forHTTPHeaderField: "Authorization")
            
            request.addValue("org-jGOqXYFRJHKlnkff8K836fK2", forHTTPHeaderField: "OpenAI-Organization")
            
            let payload: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [
                    ["role": "user", "content": "Why is the sky blue?"]
                ],
                "temperature": 1,
                "max_tokens": 256,
                "top_p": 1,
                "frequency_penalty": 0,
                "presence_penalty": 0
            ]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: payload, options: [])
            
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    //                    textViewLogger("Error: \(error)", Role.response)
                    return
                }
                
                // Print response and data if available
                if let response = response as? HTTPURLResponse {
                    //                    textViewLogger("Response: \(response)", Role.response)
                }
                
                if let data = data {
                    // Convert data to a String and print it
                    if let dataString = String(data: data, encoding: .utf8) {
                        if let jsonData = dataString.data(using: .utf8) {
                            do {
                                let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: jsonData)
                                if let firstChoice = chatResponse.choices.first {
                                    textViewLogger(firstChoice.message.content, Role.response)
                                }
                            } catch {
                                
                            }
                        }
                        //                        textViewLogger("Data: \(dataString)", Role.response)
                    }
                }
            }
            
            task.resume()
        }
        
        completions()
        
        
    }
    
    
}

