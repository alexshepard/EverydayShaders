//
//  ContentView.swift
//  Day-1
//
//  Created by Alex Shepard on 12/20/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            MetalView()
            Text("Hello, triangle!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
