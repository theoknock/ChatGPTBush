//
//  ViewController.swift
//  ChatGPTBush
//
//  Created by Xcode Developer on 11/19/23.
//

import UIKit
import OpenAI
import OpenAIKit


class ViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var chatButton: UIButton!
    
    var logger: (UITextView) -> (String) -> Void = { textView in
        return { entry in
            DispatchQueue.main.async {
                var composition = NSMutableAttributedString(attributedString: textView.attributedText)
                //                composition = composition.stringByStrippingExtraSpacesAndBlankLines() as! NSMutableAttributedString
                let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.lightGray]
                composition.append(NSAttributedString(string: entry, attributes: attributes))
                textView.attributedText = composition
            }
        }
    }
    
    // "OPENAI_API_KEY_SWIFT"
    // "OPENAI_ORGANIZATION"
    
//    func environment_variable_value(environment_variable: String) -> () {
//        let environment_variable_value: Dictionary<String, String> = Dictionary<String, String>(ProcessInfo.processInfo.environment[environment_variable]!)
//    }
    
    func env_var_value(key: String) -> () {
        var key_vals: Dictionary<String, String> = ProcessInfo.processInfo.environment
        for key_val in key_vals {
            print(key_val)
        }
    }
    
    func openai_configuration(token: String, organization: String) -> (OpenAI.Configuration) -> (Void) -> (OpenAI) {
        let configuration: OpenAI.Configuration = OpenAI.Configuration.init(token: api_key)
        var storedValue: OpenAI = OpenAI.init(configuration: OpenAI.Configuration)
        
        func makePersistentProperty() -> (Int32) -> Int32 {
            var storedValue: Int32 = Int32.zero
            
            return { newValue in
                storedValue = newValue
                return storedValue
            }
        }
        
        return { newValue in
            storedValue = newValue
            return storedValue
        }
    }
    
    var configuration: OpenAI.Configuration
    
    var openAI: OpenAI
    
    lazy var gradient: CAGradientLayer  = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        let clearer: UIColor = UIColor.init(white: 0.0, alpha: 0.1)
        gradient.colors = [
            UIColor.white.withAlphaComponent(0.15).cgColor,
            clearer.cgColor,
            clearer.cgColor,
            UIColor.white.withAlphaComponent(0.15).cgColor
        ]
        gradient.locations = [0.0, 0.25, 0.75, 1.0]
        return gradient
    }()
    
    // Define the enum
    enum ChatButtonState: UInt {
        case ChatButtonStateNormal
        case ChatButtonStateSelected
        case ChatButtonStateHighlighted
    }
    
    // Define the block as a closure
    let ChatButtonSymbolImageConfiguration: (ChatButtonState) -> UIImage.SymbolConfiguration = { state in
        let symbolPointSizeWeight = UIImage.SymbolConfiguration(pointSize: 42.0, weight: .ultraLight)
        
        switch state {
        case ChatButtonState.ChatButtonStateNormal:
            let symbolColor = UIImage.SymbolConfiguration(hierarchicalColor: UIColor.systemIndigo)
            return symbolColor.applying(symbolPointSizeWeight)
            
        case .ChatButtonStateSelected:
            let symbolColor = UIImage.SymbolConfiguration(hierarchicalColor: UIColor.systemYellow)
            return symbolColor.applying(symbolPointSizeWeight)
            
        case .ChatButtonStateHighlighted:
            let symbolColor = UIImage.SymbolConfiguration(hierarchicalColor: UIColor.systemRed)
            return symbolColor.applying(symbolPointSizeWeight)
            
        default:
            let symbolColor = UIImage.SymbolConfiguration(hierarchicalColor: UIColor.systemYellow)
            return symbolColor.applying(symbolPointSizeWeight)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var asdf: (OpenAI.Configuration) -> (OpenAI) -> OpenAI = { configuration in
            return { conf in
                return OpenAI.init(configuration: conf) .init(configuration: conf)
            }
        }
        
        
        var openA I: (String, String) -> (OpenAI.Configuration) -> (OpenAI) = { api_key, organization in
            var configuration: OpenAI.Configuration = OpenAI.Configuration(token: api_key?, organizationIdentifier: organization?, timeoutInterval: 60.0)
            return { configuration in
                var openAI: OpenAI = OpenAI(configuration: configuration)
                return openAI
            }
        }
        
        gradient.frame = self.view.bounds
        self.view.layer.addSublayer(gradient)
        
        
        // Get the system image with the specified configuration
        self.chatButton.setImage(UIImage(systemName: "text.bubble.fill"), for: .selected)
        self.chatButton.setImage(UIImage(systemName: "text.bubble"), for: .normal)
        
        self.chatTextView.delegate = self
        self.chatTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.chatTextView.layer.borderWidth = 0.25
    }
    
    // Example of a delegate method
    func textViewDidChange(_ textView: UITextView) {
        // This method is called every time the text in the textView changes
        print("Text changed to: \(textView.text!)")
    }
    
    @IBAction func chat(_ sender: UIButton) {
        DispatchQueue.main.async {
            sender.isSelected = true
        }
        
        let query = CompletionsQuery(model: .textDavinci_003, prompt: "Why is the sky blue?", temperature: 0, maxTokens: 100, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
        
        do {
            openAI.completions(query: query) { completion in
                var logEntry = self.logger(self.chatTextView)
                switch completion {
                case .success(let response):
                    // Print the response from GPT
                    DispatchQueue.main.async {
                        logEntry("\(response.choices[0].text)")
                    }
                    
                case .failure(let error):
                    // Handle any errors
                    DispatchQueue.main.async {
                        logEntry("Error: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            
        }
        
//        DispatchQueue.main.async {
//            sender.isSelected = false
//        }
    }
}

extension NSMutableAttributedString {
    func stringByStrippingExtraSpacesAndBlankLines() -> NSAttributedString {
        var mutableAttributedString = NSMutableAttributedString(attributedString: self)

        // Regular expression to match extra spaces (more than one space)
        let spaceRegex = try! NSRegularExpression(pattern: "[ ]{2,}", options: [])
        spaceRegex.replaceMatches(in: mutableAttributedString.mutableString, options: [], range: NSRange(location: 0, length: mutableAttributedString.length), withTemplate: " ")

        // Regular expression to match blank lines
        let newlineRegex = try! NSRegularExpression(pattern: "\\n\\s*\\n", options: [])
        newlineRegex.replaceMatches(in: mutableAttributedString.mutableString, options: [], range: NSRange(location: 0, length: mutableAttributedString.length), withTemplate: "\n")

        return NSMutableAttributedString(attributedString: mutableAttributedString)
    }
}
