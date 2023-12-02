//
//  P57_TextField.swift
//  ChatGPTSwiftUI
//
//  Created by Xcode Developer on 12/2/23.
//

import Foundation
import SwiftUI

public struct P57_TextField: View {
    
    @State private var username: String = "dev.fabula@gmail.com"
    @State private var selectedTag: Int = 0
    
    var textField: some View {
        GroupBox {
            TextField("User name (email address)", text: $username)
                .padding(5)
                .disableAutocorrection(true)
                .background(Color.black.opacity(0.15))
        } label: {
            Text("Message ChatGTP...")
                .font(.caption)
                .opacity(0.5)
        }
    }
    
    public init() {}
    public var body: some View {
        VStack {
            VStack {
//                Text("")
//                    .foregroundColor(Color.primary)
//                
                Divider()
                    textField.textFieldStyle(RoundedBorderTextFieldStyle())
                
            }
            .padding()
            .background(Color.secondary.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
        }
    }
}

struct P57_TextField_Previews: PreviewProvider {
    static var previews: some View {
        P57_TextField()
            .background(Color.secondary)
            .preferredColorScheme(.dark)
    }
}
