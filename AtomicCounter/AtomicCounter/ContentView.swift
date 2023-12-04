//
//  ContentView.swift
//  AtomicCounter
//
//  Created by Xcode Developer on 12/2/23.
//

import SwiftUI
import Atomics
import Dispatch

let counter = ManagedAtomic<Int>(0)

func atomicWrappingCounter(count: Int, iterations: Int) -> Void {
    DispatchQueue.concurrentPerform(iterations: count) { _ in
        for _ in 0 ..< iterations {
            counter.wrappingIncrement(ordering: .relaxed)
            print("\(counter.load(ordering: .relaxed))")
        }
    }
    counter.load(ordering: .relaxed)
}

struct ContentView: View {
    @State private var numberString = ""
    
    var body: some View {
        HStack {
            Button("", systemImage: "goforward.plus") {
                atomicWrappingCounter(count: 10, iterations: 10)
            }
            .aspectRatio(contentMode: .fill)
        }
        .padding()
    }
    
    private var numberBinding: Binding<String> {
        Binding(
            get: { self.numberString },
            set: {
                if $0.allSatisfy({ $0.isNumber }) {
                    self.numberString = $0
                }
            }
        )
    }
}

#Preview {
    ContentView()
}
