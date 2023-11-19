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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var client: OpenAI = OpenAI(apiToken: "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")
        let query = CompletionsQuery(model: .textDavinci_003, prompt: "What is 42?", temperature: 0, maxTokens: 100, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
        
        do {
            client.completions(query: query) { result in
                //Handle result here
                result.map { comp in
                    print("\(comp.choices[0].text)")
                }
                
            }
        } catch {
            print("Error")
        }
        
            //or
     // try async client.completions(query: query)
            
            //        client.completions(query: <#T##CompletionsQuery#>, completion: <#T##(Result<CompletionsResult, Error>) -> Void#>)
            
            //        openai.ChatCompletion.create(
            //                # model="gpt-4-1106-preview",
            //                model="gpt-4",
            //                messages=[{"role": "user", "content": prompt}]
            //                )
        }
        
        
}

