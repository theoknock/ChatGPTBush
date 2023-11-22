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


class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var logTextField: UITextView!
    @IBOutlet weak var taskStatusImageView: UIImageView!
    @IBOutlet weak var promptTextField: UITextField!
    

    enum Role {
        case prompt
        case response
    }
    
    let prompt_attr = [NSAttributedString.Key.font :
                        UIFont.monospacedSystemFont(ofSize: 15.0, weight: UIFont.Weight.regular),
                       NSAttributedString.Key.foregroundColor :
                        UIColor.lightGray]
    
    let response_attr = [NSAttributedString.Key.font :
                            UIFont.monospacedSystemFont(ofSize: 17.0, weight: UIFont.Weight.bold),
                         NSAttributedString.Key.foregroundColor :
                            UIColor.white]
    
    var logger: (UITextView) -> (String, String, Role) -> Void = { textView in
        return { prompt, response, role in
            DispatchQueue.main.async {
                var prompt_string = NSMutableAttributedString(string: "\(prompt)\n", attributes: [NSAttributedString.Key.font :
                                                                                                    UIFont.monospacedSystemFont(ofSize: 17.0, weight: UIFont.Weight.bold),
                                                                                                  NSAttributedString.Key.foregroundColor :
                                                                                                    UIColor.white])
                var response_string = NSMutableAttributedString(string: "\(response)\n\n", attributes: [NSAttributedString.Key.font :
                                                                                                            UIFont.monospacedSystemFont(ofSize: 15.0, weight: UIFont.Weight.regular),
                                                                                                        NSAttributedString.Key.foregroundColor :
                                                                                                            UIColor.lightGray])
                
                var composition = NSMutableAttributedString(attributedString: textView.attributedText)
                composition.append(prompt_string)
                composition.append(response_string)
                
                DispatchQueue.main.async {
                    textView.attributedText = composition
                }
            }
            
        }
    }
    
    func getEnvironmentVar(name: String, text_view_logger: ((String, String, Role) -> Void)?) -> String? {
        let rawValue = getenv(name)
        guard rawValue != nil else { return nil }
        let env_var_value = String(cString: rawValue!, encoding: .utf8) ?? "\n---\nValue for key: \(name) not found\n---\n"
        (text_view_logger ?? logger(self.logTextField))(name, env_var_value, Role.response)
        
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
        
        self.logTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.logTextField.layer.borderWidth = 1.0
        
        self.promptTextField.delegate = self
        
        let textViewLogger = logger(self.logTextField)
        //        getEnvironmentVar(name: "OS_ACTIVITY_TOOLS_OVERSIZE", text_view_logger: textViewLogger)
        
        func models() {
            let urlString = "https://api.openai.com/v1/models"
            if let url = URL(string: urlString) {
                var request = URLRequest(url: url)
                request.httpMethod = "GET" // or "POST"
                request.addValue("Bearer ", forHTTPHeaderField: "Authorization")
                request.addValue("org-jGOqXYFRJHKlnkff8K836fK2", forHTTPHeaderField: "OpenAI-Organization")
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        textViewLogger("Error: \(request)\n", "\(error)", Role.response)
                        return
                    }
                    
                    if let response = response as? HTTPURLResponse {
                        textViewLogger("Response:  \(request)\n", "\(response)", Role.response)
                    }
                    
                    if let data = data {
                        if let dataString = String(data: data, encoding: .utf8) {
                            textViewLogger("Data:  \(request)\n", "\(dataString)", Role.response)
                        }
                    }
                }
                
                task.resume()
            }
        }
        
        //                models()
        
        
        
    
        
    }
    
    func completions(prompt: String) -> Int {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer ", forHTTPHeaderField: "Authorization")
        
        request.addValue("org-jGOqXYFRJHKlnkff8K836fK2", forHTTPHeaderField: "OpenAI-Organization")
        
        let payload: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 1,
            "max_tokens": 256,
            "top_p": 1,
            "frequency_penalty": 0,
            "presence_penalty": 0
        ]
        //
        //            if let messages = payload["messages"] as? [[String: String]],
        //               let firstMessage = messages.first,
        //               let content = firstMessage["content"] {
        //            textViewLogger("\(payload)", "\(prompt)\n\n", Role.prompt)
        //            } else {
        //                print("Content not found")
        //            }
        
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
                                self.logger(self.logTextField)("\(prompt)\n", "\(firstChoice.message.content)\n\n", Role.response)
                            }
                        } catch {
                            
                        }
                    }
                    //                        textViewLogger("Data: \(dataString)", Role.response)
                }
            }
        }
        
        task.resume()
        
        // Create a repeating timer
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            switch task.state {
            case .running:
                self.taskStatusImageView.tintColor = .systemGreen
                self.taskStatusImageView.isHidden = !self.taskStatusImageView.isHidden
                print("Task is still running...")
            case .completed:
                self.taskStatusImageView.isHidden = false
                self.taskStatusImageView.tintColor = .systemBlue
                print("Task completed")
                timer.invalidate()
            case .canceling:
                self.taskStatusImageView.tintColor = .systemYellow
                self.taskStatusImageView.isHidden = !self.taskStatusImageView.isHidden
                print("Task is canceling")
                timer.invalidate()
            case .suspended:
                self.taskStatusImageView.isHidden = false
                self.taskStatusImageView.tintColor = .systemRed
                print("Task is suspended")
                timer.invalidate()
            @unknown default:
                self.taskStatusImageView.isHidden = false
                self.taskStatusImageView.tintColor = .systemRed
                print("Unknown state")
                timer.invalidate()
            }
        }
        
        return 1;
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
     print("textFieldShouldBeginEditing")
       return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        if completions(prompt: self.promptTextField.text!) == 1 {
            self.logger(self.logTextField)("\(self.promptTextField.text!)", "", Role.prompt)
        }
            // You might want to dismiss the keyboard
            textField.resignFirstResponder()

            // Return true to indicate you've handled this event
            return true
        }
}

