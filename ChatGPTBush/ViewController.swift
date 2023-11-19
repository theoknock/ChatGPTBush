//
//  ViewController.swift
//  ChatGPTBush
//
//  Created by Xcode Developer on 11/19/23.
//

import UIKit
import OpenAI
import OpenAIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var chatButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Call the async function
    }
    
    @IBAction func chatAction(_ sender: Any) {
        print("Task")
//        {
            // Configure the OpenAI API with your API key
            var openAI = OpenAI(apiToken: "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")

            // Create a prompt
            let query = CompletionsQuery(model: .gpt4_1106_preview, prompt: "Why is the sky blue?", temperature: 0, maxTokens: 100, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
            
            do {
                // Define the completion parameters
//                let result = try openAI.completions(query: ÷r)
                
                // Send the request to OpenAI's API
                openAI.completions(query: query, completion: { completion in
                    switch completion {
                    case .success(let response):
                        // Print the response from GPT
                        if let text = response.choices.first?.text {
                            print("Response: \(text)")
                        } else {
                            print("No text received in response.")
                        }
                    case .failure(let error):
                        // Handle any errors
                        DispatchQueue.main.async {
                            self.chatTextView.text = "Error: \(error.localizedDescription)"
                        }
                    }
                })
            } catch {
                
            }
//        }()
        
        //        Task {
        //            await chat
        //        }
    }
}
