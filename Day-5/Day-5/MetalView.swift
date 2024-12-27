//
//  MetalView.swift
//  Day-5
//
//  Created by Alex Shepard on 12/26/24.
//

import MetalKit
import SwiftUI

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
