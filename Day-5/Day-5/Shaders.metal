//
//  Shaders.metal
//  Day-5
//
//  Created by Alex Shepard on 12/26/24.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position [[ attribute(0) ]];
};

struct VertexOut {
    float4 position [[ position ]];
};

struct FragUniforms {
    float timer;
};

vertex VertexOut vertex_main(Vertex in [[ stage_in ]]) {
    VertexOut out;
    out.position = float4(in.position, 0.0, 1.0);
    return out;
}

fragment float4 fragment_main(VertexOut in [[ stage_in ]], constant FragUniforms &uniforms [[ buffer(13) ]])
{
    float blue = (sin(uniforms.timer) + 1.0) * 0.5;
    return float4(0.2, 0.2, blue, 1.0);
}


