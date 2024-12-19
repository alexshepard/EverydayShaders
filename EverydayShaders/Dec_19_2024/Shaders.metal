#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float pointSize [[ point_size ]];
};

vertex VertexOut vertex_main(
    constant uint &count [[ buffer(0) ]],
    constant float &timer [[ buffer(11) ]],
    uint vertexID [[ vertex_id ]])
{
    float radius = 0.8;
    float pi = 3.14159;
    float current = (float(vertexID) / float(count)) + timer;
    float2 position;
    position.x = radius * cos(2 * pi * current);
    position.y = radius * sin(2 * pi * current);
    
    float blue = sin(pi * (float(vertexID) / float(count)));
    
    VertexOut out {
        .position = float4(position, 0, 1),
        .color = float4(0.8, 0.8, blue, 1),
        .pointSize = 20,
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[ stage_in ]]) {
    return in.color;
}
