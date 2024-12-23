//
//  MetalView.swift
//  Day-3
//
//  Created by Alex Shepard on 12/23/24.
//

import SwiftUI
import MetalKit

struct MetalView: View {
    @State private var metalView = MTKView()
    @State private var renderer: Renderer?
    var body: some View {
        MetalViewRepresentable(metalView: $metalView)
            .onAppear {
                renderer = Renderer(metalView: metalView)
            }
    }
}

struct MetalViewRepresentable: NSViewRepresentable {
    @Binding var metalView: MTKView
    
    func makeNSView(context: Context) -> some NSView {
        metalView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) { }
}

#Preview {
    MetalView()
}