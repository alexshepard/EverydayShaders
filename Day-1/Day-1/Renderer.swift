//
//  Renderer.swift
//  Day-1
//
//  Created by Alex Shepard on 12/20/24.
//


//
//  Renderer.swift
//  EverydayShaders
//
//  Created by Alex Shepard on 12/19/24.
//

import MetalKit

// swiftlint:disable implicitly_unwrapped_optional

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
            
    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Self.device = device
        Self.commandQueue = commandQueue
        metalView.device = device
        
        let library = device.makeDefaultLibrary()
        Self.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
                
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        let vertices: [Float] = [
            -0.5, -0.5,
             0.5, -0.5,
             0.0,  0.5,
        ]
        self.vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout.stride(ofValue: vertices[0]),
            options: MTLResourceOptions.storageModeShared
        )

        do {
            pipelineState =
            try device.makeRenderPipelineState(
                descriptor: pipelineDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        super.init()
        metalView.clearColor = MTLClearColor(
            red: 1.0,
            green: 1.0,
            blue: 0.8,
            alpha: 1.0)
        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
    }
    
    func draw(in view: MTKView) {
        guard
            let cmdBuf = Self.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder =
                cmdBuf.makeRenderCommandEncoder(
                    descriptor: descriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: 3
        )

        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        cmdBuf.present(drawable)
        cmdBuf.commit()
    }
}

