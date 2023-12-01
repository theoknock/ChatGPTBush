//
//  ViewController.swift
//  curlTest
//
//  Created by Xcode Developer on 11/27/23.
//

import SwiftUI
import Foundation



class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    class MessageCell: UICollectionViewCell {
        // Customize this cell to look like a message bubble
    }
    
    var collectionView: UICollectionView!
    var senderTextField: UITextField!
    var receiverTextField: UITextField!
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        setupCollectionView()
        setupTextFields()
        
        fetchData(from: URL(string: "https://example.com")!) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let dataString):
                    print("Received data: \(dataString)")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        // Customize the layout as needed
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: "MessageCell")
        collectionView.backgroundColor = .black
        view.addSubview(collectionView)
    }
    
    func setupTextFields() {
        senderTextField = UITextField(frame: CGRect(x: 10, y: view.bounds.height - 60, width: view.bounds.width / 2 - 15, height: 50))
        senderTextField.borderStyle = .roundedRect
        senderTextField.placeholder = "Sender message..."
        senderTextField.delegate = self
        senderTextField.returnKeyType = .send
        view.addSubview(senderTextField)
        
        receiverTextField = UITextField(frame: CGRect(x: view.bounds.width / 2 + 5, y: view.bounds.height - 60, width: view.bounds.width / 2 - 15, height: 50))
        receiverTextField.borderStyle = .roundedRect
        receiverTextField.placeholder = "Receiver message..."
        receiverTextField.delegate = self
        receiverTextField.returnKeyType = .send
        view.addSubview(receiverTextField)
    }
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MessageCell", for: indexPath) as! MessageCell
        // Configure the cell with message data
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the size of each cell
        return CGSize(width: collectionView.bounds.width, height: 100) // Example size
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == senderTextField {
            addMessage(text: "Test" /*textField.text!*/, isSender: true)
        } else if textField == receiverTextField {
            addMessage(text: "Test" /*textField.text!*/, isSender: false)
        }
//        textField.text = ""
        textField.resignFirstResponder()
        return true
    }
    
    func addMessage(text: String, isSender: Bool) {
        guard !text.isEmpty else { return }
        let newMessage = Message(text: text, isSender: isSender)
        messages.append(newMessage)
        collectionView.reloadData()
        scrollToBottom()
    }
    
    func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let lastItemIndex = IndexPath(item: messages.count - 1, section: 0)
        collectionView.scrollToItem(at: lastItemIndex, at: .bottom, animated: true)
    }
    
    func fetchData(from url: URL, completion: @escaping (Result<String, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            // Check and process data
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                completion(.success(dataString))
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            }
        }.resume()
    }
}
