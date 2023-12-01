//
//  ViewController.swift
//  URLSessionTest
//
//  Created by Xcode Developer on 11/20/23.
//

import UIKit
import Foundation
import CurlDSL



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

struct ThreadResponse: Codable {
    let id: String
}


class ViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var taskStatusImageView: UIImageView!
    @IBOutlet weak var promptTextView: UITextView!
    
    let prompt_attr = [NSAttributedString.Key.font :
                        UIFont.monospacedSystemFont(ofSize: 17.0, weight: UIFont.Weight.heavy),
                       NSAttributedString.Key.foregroundColor :
                        UIColor.white]
    
    let response_attr = [NSAttributedString.Key.font :
                            UIFont.monospacedSystemFont(ofSize: 17.0, weight: UIFont.Weight.light),
                         NSAttributedString.Key.foregroundColor :
                            UIColor.lightGray]
    
    //    var logger: (UITextView) -> (String, Role) -> Void = { textView in
    //        return { content, role in
    //            DispatchQueue.main.async {
    //                var prompt_string = NSMutableAttributedString(string: "\(content)\n", attributes: [NSAttributedString.Key.font :
    //                                                                                                    UIFont.monospacedSystemFont(ofSize: 17.0, weight: UIFont.Weight.bold),
    //                                                                                                   NSAttributedString.Key.foregroundColor :
    //                                                                                                    UIColor.lightGray])
    //                var response_string = NSMutableAttributedString(string: "\(content)\n\n", attributes: [NSAttributedString.Key.font :
    //                                                                                                        UIFont.monospacedSystemFont(ofSize: 17.0, weight: UIFont.Weight.regular),
    //                                                                                                       NSAttributedString.Key.foregroundColor :
    //                                                                                                        UIColor.lightGray])
    //
    //                var composition = NSMutableAttributedString(attributedString: textView.attributedText)
    //                composition.append((role == .prompt) ? prompt_string : response_string)
    //
    //                DispatchQueue.main.async {
    //                    textView.attributedText = composition
    //                }
    //            }
    //
    //        }
    //    }
    
    func getEnvironmentVar(name: String) -> () {
        let rawValue = getenv(name)
        guard rawValue != nil else { return }
        let env_var_value = String(cString: rawValue!, encoding: .utf8) ?? "\n---\nValue for key: \(name) not found\n---\n"
        self.logTextView.logChat(message: "\(name)\t\(env_var_value)", role: .response)
    }
    
    func env_var_values() -> () {
        let key_vals: Dictionary<String, String> = ProcessInfo.processInfo.environment
        for key_val in key_vals {
            self.logTextView.logChat(message: "\(key_val.key)\t\(key_val.value)", role: .response)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.logTextView.layer.borderWidth = 1.0
        
        self.logTextView.delegate = self
        
        self.promptTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.promptTextView.layer.borderWidth = 1.0
        
        self.promptTextView.delegate = self
        
        var thread: String = "123"
        /*
         Data: {
         "id": "thread_4EMuuKU5WkfGxyPYjkPoyAXX",
         "object": "thread",
         "created_at": 1700901942,
         "metadata": {}
         }
         */
        
        var assistant: () -> String = {
            var jsonString = """
                            curl "https://api.openai.com/v1/assistants" \
                                -H "Content-Type: application/json" \
                                -H "Authorization: Bearer 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" \
                                -H "OpenAI-Beta: assistants=v1" \
                                -d '{
                                 "instructions": "You are a personal math tutor. Write and run code to answer math questions.",
                                 "name": "Math Tutor",
                                 "tools": [{"type": "code_interpreter"}],
                                 "model": "gpt-4"
                                }'
                        """
            return jsonString
        }
        
        func thread_url(thread: String) -> String {
            let curls: [String] = Array(arrayLiteral:
                                            /* Step 1: Create an Assistant */
                        """
                            curl "https://api.openai.com/v1/assistants" \
                                -H "Content-Type: application/json" \
                                -H "Authorization: Bearer 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" \
                                -H "OpenAI-Beta: assistants=v1" \
                                -d '{
                                 "instructions": "You are a personal math tutor. Write and run code to answer math questions.",
                                 "name": "Math Tutor",
                                 "tools": [{"type": "code_interpreter"}],
                                 "model": "gpt-4"
                                }'
                        """,
                                        
                                        /* Step 2: Create a Thread */
                        """
                            curl https://api.openai.com/v1/threads \
                                -H "Content-Type: application/json" \
                                -H "Authorization: Bearer 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" \
                                -H "OpenAI-Beta: assistants=v1" \
                                -d ''
                        """,
                                        
                                        /* Step 3a: Add a Message to a Thread */
                        """
                            curl https://api.openai.com/v1/threads/\(thread)/messages \
                                -H "Content-Type: application/json" \
                                -H "Authorization: Bearer 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" \
                                -H "OpenAI-Beta: assistants=v1" \
                                -d '{
                                "role": "user",
                                "content": "I need to solve the equation `3x + 11 = 14`. Can you help me?"
                                }'
                        """,
                                        
                                        /* Step 3b: List the Messages in a Thread */
                        """
                            curl https://api.openai.com/v1/threads/\(thread)/messages \
                              -H "Content-Type: application/json" \
                              -H "Authorization: Bearer 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" \
                              -H "OpenAI-Beta: assistants=v1"
                        """)
            return String()
        }
        
        let curls: [String] = Array(arrayLiteral:
                                        /* Step 1: Create an Assistant */
                    """
                        curl "https://api.openai.com/v1/assistants" \
                            -H "Content-Type: application/json" \
                            -H "Authorization: Bearer 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" \
                            -H "OpenAI-Beta: assistants=v1" \
                            -d '{
                             "instructions": "You are a personal math tutor. Write and run code to answer math questions.",
                             "name": "Math Tutor",
                             "tools": [{"type": "code_interpreter"}],
                             "model": "gpt-4"
                            }'
                    """,
                                    
                                    /* Step 2: Create a Thread */
                    """
                        curl https://api.openai.com/v1/threads \
                            -H "Content-Type: application/json" \
                            -H "Authorization: Bearer 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" \
                            -H "OpenAI-Beta: assistants=v1" \
                            -d ''
                    """,
                                    
                                    /* Step 3a: Add a Message to a Thread */
                    """
                        curl https://api.openai.com/v1/threads/\(thread)/messages \
                            -H "Content-Type: application/json" \
                            -H "Authorization: Bearer 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" \
                            -H "OpenAI-Beta: assistants=v1" \
                            -d '{
                            "role": "user",
                            "content": "I need to solve the equation `3x + 11 = 14`. Can you help me?"
                            }'
                    """,
                                    
                                    /* Step 3b: List the Messages in a Thread */
                    """
                        curl https://api.openai.com/v1/threads/\(thread)/messages \
                          -H "Content-Type: application/json" \
                          -H "Authorization: Bearer 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" \
                          -H "OpenAI-Beta: assistants=v1"
                    """)
        var curl_iterator = curls.makeIterator()
        
        func curl_dsl(curl: String) {
            do {
                // try CURL("curl -X GET https://httpbin.org/json")
                try CURL(curl).run { data, response, error in
                    if let error = error {
                        self.logTextView.logChat(message: "Error: \(error)", role: .response)
                        return
                    }
                    
                    if let response = response as? HTTPURLResponse {
                        self.logTextView.logChat(message: "Response: \(response)", role: .response)
                    }
                    
                    if let data = data {
                        if let dataString = String(data: data, encoding: .utf8) {
                            self.logTextView.logChat(message: "Data: \(dataString)", role: .response)
                            if let next_curl = curl_iterator.next() {
                                curl_dsl(curl: next_curl)
                            }
                        }
                    }
                }
            } catch {
                self.logTextView.logChat(message: "Exception: curl_dsl()", role: .response)
            }
        }
        
        //        if let next_curl = curl_iterator.next() {
        //            curl_dsl(curl: next_curl)
        //        }
        
        func curl_task(curl: String) {
            var request = try? CURL(curl).buildRequest()
            let task = URLSession.shared.dataTask(with: request!) { (data, response, error) in
                if let error = error {
                    self.logTextView.logChat(message: "Error: \(error)", role: .response)
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    self.logTextView.logChat(message: "Response: \(response)", role: .response)
                }
                
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(ThreadResponse.self, from: data)
                        
                        // Access the thread ID
                        thread = "\(response.id)"
                        if let dataString = String(data: data, encoding: .utf8) {
                            self.logTextView.logChat(message: "Data: \(response.id) \(dataString)", role: .response)
                        }
                    } catch {
                        if thread != "123" {
                            print("Thread ID: \(thread)")
                        }
                    }
                    
                }
            }
            
            task.resume()
            
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
                    if let next_curl = curl_iterator.next() {
                        curl_task(curl: next_curl)
                    } else {
                        timer.invalidate()
                    }
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
        }
        
//        if let next_curl = curl_iterator.next() {
//            curl_task(curl: next_curl)
//        }
        
        func models() {
            let urlString = "https://api.openai.com/v1/models"
            if let url = URL(string: urlString) {
                var request = URLRequest(url: url)
                request.httpMethod = "GET" // or "POST"
                request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
                request.addValue("org-jGOqXYFRJHKlnkff8K836fK2", forHTTPHeaderField: "OpenAI-Organization")
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        self.logTextView.logChat(message: "Error: \(error)", role: .response)
                        return
                    }
                    
                    if let response = response as? HTTPURLResponse {
                        self.logTextView.logChat(message: "Response: \(response)", role: .response)
                    }
                    
                    if let data = data {
                        if let dataString = String(data: data, encoding: .utf8) {
                            self.logTextView.logChat(message: "Data: \(dataString)", role: .response)
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
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        
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
        
        let jsonData = try! JSONSerialization.data(withJSONObject: payload, options: [])
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return
            }
            
            if let response = response as? HTTPURLResponse {
                
            }
            
            if let data = data {
                if let dataString = String(data: data, encoding: .utf8) {
                    if let jsonData = dataString.data(using: .utf8) {
                        do {
                            let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: jsonData)
                            if let firstChoice = chatResponse.choices.first {
                                self.logTextView.logChat(message: "\(firstChoice.message.content)", role: .response)
                            }
                        } catch {
                            
                        }
                    }
                }
            }
        }
        
        task.resume()
        
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if completions(prompt: textView.text!) == 1 {
                textView.logChat(message: "\(textView.text!)", role: .prompt)
                textView.text = ""
            }
            textView.resignFirstResponder()
            
            return false
        }
        
        return true
    }
}

extension UITextView {
    private static var key: Void?
    
    enum Role {
        case prompt
        case response
    }
    
    typealias ChatLogger = (String, Role) -> Void
    
    var chatLogger: ChatLogger? {
        get {
            return objc_getAssociatedObject(self, &UITextView.key) as? UITextView.ChatLogger
        }
        set {
            objc_setAssociatedObject(self, &UITextView.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func logChat(message: String, role: Role) -> Void {
        DispatchQueue.main.async {
            let prompt_string = NSMutableAttributedString(string: "\(message)\n", attributes: [NSAttributedString.Key.font :
                                                                                                UIFont.monospacedSystemFont(ofSize: 17.0, weight: UIFont.Weight.bold),
                                                                                               NSAttributedString.Key.foregroundColor :
                                                                                                UIColor.lightGray])
            let response_string = NSMutableAttributedString(string: "\(message)\n\n", attributes: [NSAttributedString.Key.font :
                                                                                                    UIFont.monospacedSystemFont(ofSize: 17.0, weight: UIFont.Weight.regular),
                                                                                                   NSAttributedString.Key.foregroundColor :
                                                                                                    UIColor.lightGray])
            
            let composition = NSMutableAttributedString(attributedString: self.attributedText)
            composition.append((role == .prompt) ? prompt_string : response_string)
            
            DispatchQueue.main.async {
                self.attributedText = composition
            }
        }
    }
}
