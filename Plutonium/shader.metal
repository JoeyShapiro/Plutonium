//
//  shader.metal
//  Plutonium
//
//  Created by Joey Shapiro on 10/14/24.
//


#include <metal_stdlib>
using namespace metal;

struct Uniforms {
    float2 resolution;
    float2 scale;
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                              constant float2 *vertices [[buffer(0)]]) {
    VertexOut out;
    out.position = float4(vertices[vertexID], 0.0, 1.0);
//    out.uv = (vertices[vertexID].xy + 1.0) * 0.5;
    out.uv = vertices[vertexID].xy;
    
    return out;
}

float sdBox( float3 p, float3 b )
{
    float3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float map(float3 p, float2 uv) {
//    p.x = p.x+0.5;
    float out = sdBox(         p-float3(1.5,0,0.5), float3(1,0,0.5) );
    out = min(out, sdBox(         p-float3(0.5,0,0.5), float3(1,0,0.5) ));
    out = min(out, sdBox(         p-float3(-1.5,0,0.5), float3(1,0,0.5) ));
    // just care about x and z
    // dont need to test all of this
    // want to figure out rotation, but i just need x+z
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               constant Uniforms &uniforms [[buffer(0)]]) {
    // downscale uv space
    float2 uv = floor(in.uv * uniforms.scale) / uniforms.scale;
    uv = in.uv;
    
    float3 ro = float3(0, 0, -3);
    float3 rd = normalize(float3(uv.x, 0, 1));
    float3 color = float3(0);
    float t = 0;
    
    for (int i=0; i<80; i++) {
        float3 p = ro + rd * t;
        float d = map(p, uv);
        t += d;
        
//        color = float3(i) / 80;
//        color = p;
        if (d < 0.001 || t > 100) break;
    }
    
    color = float3(t * 0.1);
    if (abs(uv.y) > t*0.1) color = 0;
    
    return float4(color, 1);
}
