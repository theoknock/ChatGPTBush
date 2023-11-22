//
//  ViewController.swift
//  ProcessInfoEnvironmentTest
//
//  Created by Xcode Developer on 11/20/23.
//

import UIKit
import Foundation


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func getEnvironmentVar(name: String) -> String? {
            let rawValue = getenv(name)
            guard rawValue != nil else { return nil }
            return String(cString: rawValue!, encoding: .utf8)
        }
        
        print(getEnvironmentVar(name: "DISPLAY"))
        
        func env_var_values() -> () {
            var key_vals: Dictionary<String, String> = ProcessInfo.processInfo.environment
            for key_val in key_vals {
                print(key_val)
            }
        }
        env_var_values()
    }
}

