//
//  ContentView.swift
//  Day-2
//
//  Created by Alex Shepard on 12/21/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            MetalView()
            Text("Hello, triangle with colors")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
