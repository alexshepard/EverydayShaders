//
//  Renderer.swift
//  Day-3
//
//  Created by Alex Shepard on 12/23/24.
//

import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var cmdQ: MTLCommandQueue!
    static var lib: MTLLibrary!
    
    var vertexBuf: MTLBuffer!
    var indexBuf: MTLBuffer!
    var pipeState: MTLRenderPipelineState!
    var vertexDescriptor: MTLVertexDescriptor!
    
    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let cmdQ = device.makeCommandQueue()
        else { fatalError("Couldn't create Metal device") }
        
        Self.device = device
        Self.cmdQ = cmdQ
        metalView.device = device
        
        vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.layouts[30].stride = MemoryLayout<Vertex>.stride
        vertexDescriptor.layouts[30].stepRate = 1
        vertexDescriptor.layouts[30].stepFunction = .perVertex
        
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].offset = MemoryLayout.offset(of: \Vertex.position)!
        vertexDescriptor.attributes[0].bufferIndex = 30
        
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = MemoryLayout.offset(of: \Vertex.color)!
        vertexDescriptor.attributes[1].bufferIndex = 30
        
        
        let lib = device.makeDefaultLibrary()
        Self.lib = lib
        let vertexFn = lib?.makeFunction(name: "vertex_main")
        let fragFn = lib?.makeFunction(name: "fragment_main")
        
        let pipeDesc = MTLRenderPipelineDescriptor()
        pipeDesc.vertexFunction = vertexFn
        pipeDesc.fragmentFunction = fragFn
        pipeDesc.vertexDescriptor = vertexDescriptor
        pipeDesc.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        let indices: [ushort] = [
            0, 1, 2,
            0, 2, 3,
        ]
        let vertices: [Vertex] = [
            Vertex(position: simd_float2(-0.5, -0.5), color: simd_float3(1.0, 0.0, 0.0)),
            Vertex(position: simd_float2( 0.5, -0.5), color: simd_float3(0.0, 1.0, 0.0)),
            Vertex(position: simd_float2( 0.5,  0.5), color: simd_float3(0.0, 0.0, 1.0)),
            Vertex(position: simd_float2(-0.5,  0.5), color: simd_float3(1.0, 0.0, 1.0)),
        ]
        
        self.indexBuf = device.makeBuffer(
            bytes: indices,
            length: indices.count * MemoryLayout<ushort>.stride,
            options: .storageModeShared
        )
        
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
            red: 0.8,
            green: 0.85,
            blue: 0.69,
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
            let renderEnc = cmdBuf.makeRenderCommandEncoder(descriptor: desc)
        else { return }

        renderEnc.setRenderPipelineState(self.pipeState)
        renderEnc.setVertexBuffer(
            self.vertexBuf,
            offset: 0,
            index: 30
        )
        renderEnc.drawIndexedPrimitives(
            type: .triangle,
            indexCount: 6,
            indexType: .uint16,
            indexBuffer: indexBuf,
            indexBufferOffset: 0
        )
        renderEnc.endEncoding()
        
        guard let drawable = view.currentDrawable else { return }
        cmdBuf.present(drawable)
        cmdBuf.commit()
    }
}
