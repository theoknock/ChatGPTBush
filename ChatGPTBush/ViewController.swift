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
        //        var openAI = OpenAI(apiToken: "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")
        let configuration = OpenAI.Configuration(token: "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", organizationIdentifier: "org-jGOqXYFRJHKlnkff8K836fK2", timeoutInterval: 60.0)
        let openAI = OpenAI(configuration: configuration)
        
        // Create a prompt
        let query = CompletionsQuery(model: .textDavinci_003, prompt: "Why is the sky blue?", temperature: 0, maxTokens: 100, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
        
        do {
            openAI.completions(query: query) { completion in
                switch completion {
                case .success(let response):
                    // Print the response from GPT
                        DispatchQueue.main.async {
                            self.chatTextView.text = "Response: \(response.choices[0].text)"
                        }
                     
                case .failure(let error):
                    // Handle any errors
                    DispatchQueue.main.async {
                        self.chatTextView.text = "Error: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            
        }
    }
}
