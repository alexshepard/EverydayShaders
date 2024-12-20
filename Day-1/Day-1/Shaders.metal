//
//  Shaders.metal
//  Day-1
//
//  Created by Alex Shepard on 12/20/24.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 vertex_main(
                          uint vertex_id [[vertex_id]],
                          constant float2* vertices [[buffer(0)]]
                          ) {
    return float4(vertices[vertex_id], 0.0, 1.0);
}

fragment float4 fragment_main() {
    return float4(0.1, 0.2, 0.6, 1.0);
}
