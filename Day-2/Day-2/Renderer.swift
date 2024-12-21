//
//  Renderer.swift
//  Day-2
//
//  Created by Alex Shepard on 12/21/24.
//

import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var cmdQ: MTLCommandQueue!
    static var lib: MTLLibrary!
    
    var vertexBuf: MTLBuffer!
    var pipeState: MTLRenderPipelineState!
    
    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let cmdQ = device.makeCommandQueue() else
        {
            fatalError("GPU not available")
        }
        
        Self.device = device
        Self.cmdQ = cmdQ
        metalView.device = device
        
        let lib = device.makeDefaultLibrary()
        Self.lib = lib
        let vertexFn = lib?.makeFunction(name: "vertex_main")
        let fragFn = lib?.makeFunction(name: "fragment_main")
        
        let pipeDesc = MTLRenderPipelineDescriptor()
        pipeDesc.vertexFunction = vertexFn
        pipeDesc.fragmentFunction = fragFn
        pipeDesc.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        let vertices: [Vertex] = [
            Vertex(position: simd_float2(-0.5, -0.5), color: simd_float3(0.8, 0.1, 0.1)),
            Vertex(position: simd_float2( 0.5, -0.5), color: simd_float3(0.1, 0.8, 0.1)),
            Vertex(position: simd_float2( 0.0,  0.5), color: simd_float3(0.1, 0.1, 0.8)),
        ]
        
        self.vertexBuf = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: .storageModeShared
        )
        
        do {
            pipeState = try device.makeRenderPipelineState(descriptor: pipeDesc)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        super.init()
        
        metalView.clearColor = MTLClearColor(
            red: 0.9,
            green: 0.9,
            blue: 0.7,
            alpha: 1.0
        )
        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    func draw(in view: MTKView) {
        guard
            let cmdBuf = Self.cmdQ.makeCommandBuffer(),
            let desc = view.currentRenderPassDescriptor,
            let renderEnc = cmdBuf.makeRenderCommandEncoder(descriptor: desc) else
        {
            return
        }
        
        renderEnc.setRenderPipelineState(self.pipeState)
        renderEnc.setVertexBuffer(
            self.vertexBuf,
            offset: 0,
            index: 0
        )
        renderEnc.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: 3
        )
        renderEnc.endEncoding()
        
        guard let drawable = view.currentDrawable else { return }
        cmdBuf.present(drawable)
        cmdBuf.commit()
    }
}

