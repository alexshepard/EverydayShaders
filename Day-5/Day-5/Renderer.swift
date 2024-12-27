//
//  Renderer.swift
//  Day-5
//
//  Created by Alex Shepard on 12/26/24.
//

import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var cmdQ: MTLCommandQueue!
    static var lib: MTLLibrary!
    
    var vertexBuf: MTLBuffer!
    var indexBuf: MTLBuffer!
    var fragUniformsBuf: MTLBuffer!
    
    var pipeState: MTLRenderPipelineState!
    var vertexDesc: MTLVertexDescriptor!
    
    var timer: Float = 0.0
    let gpuLock = DispatchSemaphore(value: 1)
    
    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let cmdQ = device.makeCommandQueue(),
            let lib = device.makeDefaultLibrary()
        else { fatalError("Can't find GPU") }
        
        Self.device = device
        Self.cmdQ = cmdQ
        Self.lib = lib
        metalView.device = device
        
        let vertexFn = lib.makeFunction(name: "vertex_main")
        let fragFn = lib.makeFunction(name: "fragment_main")
        
        vertexDesc = MTLVertexDescriptor()
        vertexDesc.layouts[30].stride = MemoryLayout<Vertex>.stride
        vertexDesc.layouts[30].stepRate = 1
        vertexDesc.layouts[30].stepFunction = .perVertex
        vertexDesc.attributes[0].format = .float2
        vertexDesc.attributes[0].offset = MemoryLayout.offset(of: \Vertex.position)!
        vertexDesc.attributes[0].bufferIndex = 30
        
        let pipeDesc = MTLRenderPipelineDescriptor()
        pipeDesc.vertexFunction = vertexFn
        pipeDesc.fragmentFunction = fragFn
        pipeDesc.vertexDescriptor = vertexDesc
        pipeDesc.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        let indices: [ushort] = [
            0, 1, 2,
            0, 2, 3
        ]
        self.indexBuf = device.makeBuffer(
            bytes: indices,
            length: indices.count * MemoryLayout<ushort>.stride,
            options: .storageModeShared
        )
        
        let vertices: [Vertex] = [
            Vertex(position: simd_float2(-0.5, -0.5)),
            Vertex(position: simd_float2( 0.5, -0.5)),
            Vertex(position: simd_float2( 0.5,  0.5)),
            Vertex(position: simd_float2(-0.5,  0.5)),
        ]
        self.vertexBuf = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Vertex>.stride,
            options: .storageModeShared
        )
        
        var initialFragUniforms = FragmentUniforms(timer: timer)
        self.fragUniformsBuf = device.makeBuffer(
            bytes: &initialFragUniforms,
            length: MemoryLayout<FragmentUniforms>.stride,
            options: .storageModeShared
        )
            
        do {
            pipeState = try device.makeRenderPipelineState(descriptor: pipeDesc)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        super.init()
        
        metalView.clearColor = MTLClearColorMake(0.3, 0.2, 0.7, 1.0)
        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange newSize: CGSize) { }
    
    func draw(in view: MTKView) {
        gpuLock.wait()
        
        guard
            let cmdBuf = Self.cmdQ.makeCommandBuffer(),
            let desc = view.currentRenderPassDescriptor,
            let renderEnc = cmdBuf.makeRenderCommandEncoder(descriptor: desc)
        else { return }
        
        renderEnc.setRenderPipelineState(self.pipeState)
        renderEnc.setVertexBuffer(self.vertexBuf, offset: 0, index: 30)
        
        let ptr = fragUniformsBuf.contents().bindMemory(
            to: FragmentUniforms.self,
            capacity: 1
        )
        ptr.pointee.timer = self.timer
        self.timer += 0.05
        
        renderEnc.setFragmentBuffer(
            fragUniformsBuf,
            offset: 0,
            index: 13
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
        cmdBuf.addCompletedHandler { _ in
            self.gpuLock.signal()
        }
        cmdBuf.commit()
    }
}
