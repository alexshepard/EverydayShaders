//
//  VertexDescriptor.swift
//  EverydayShaders
//
//  Created by Alex Shepard on 12/19/24.
//

import MetalKit

extension MTLVertexDescriptor {
    static var defaultLayout: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        let stride = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.layouts[0].stride = stride
        return vertexDescriptor
    }
}
