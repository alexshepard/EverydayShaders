//
//  Shaders.metal
//  Day-2
//
//  Created by Alex Shepard on 12/21/24.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position;
    float3 color;
};

struct VertexOut {
    float4 position [[ position ]];
    float3 color;
};

vertex VertexOut vertex_main(uint vertex_id [[ vertex_id ]], constant Vertex *vertices [[ buffer(0) ]]) {
    
    VertexOut out;
    out.position = float4(vertices[vertex_id].position, 0.0, 1.0);
    out.color = vertices[vertex_id].color;
    
    return out;
}

fragment float4 fragment_main(VertexOut in [[ stage_in ]]) {
    return float4(in.color, 1.0);
}
