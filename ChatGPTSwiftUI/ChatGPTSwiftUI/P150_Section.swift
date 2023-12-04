//
//  P150_Section.swift
//  ChatGPTSwiftUI
//
//  Created by Xcode Developer on 12/2/23.
//

import Foundation
import SwiftUI

public struct P150_Section: View {
    
    struct SectionHeader: View {
        let title: String
        var body: some View {
            Text(title)
        }
    }
    
    var footer: some View {
        Text("Footer Message...")
    }
    
    public init() {}
    public var body: some View {
        List {
            Section(header: SectionHeader(title: "Section 1")) {
                ForEach(0..<30, id: \.self) { index in
                    Text("Row \(index)")
                }
            }
            Section(header: SectionHeader(title: "Section 2"), footer: footer) {
                ForEach(0..<30, id: \.self) { index in
                    Text("Row \(index)")
                }
            }
        }
        .background(Color.primary.opacity(0.5))
        .listStyle(SidebarListStyle())
        .padding()
        .frame(maxWidth: 500)
    }
}

struct P150_Section_Previews: PreviewProvider {
    static var previews: some View {
        P150_Section()
    }
}
