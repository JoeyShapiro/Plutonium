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

constant bool useConstants [[function_constant(0)]];

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

float map(float3 p, float2 pos) {
//    p.x = p.x+0.5;
    float out = sdBox(         p-float3(6,0,5), float3(5,0,5) );
//    out = min(out, sdBox(         p-float3(0,0,5), float3(1,0,5) ));
    out = min(out, sdBox(         p-float3(-6,0,10), float3(5,0,5) ));
    // just care about x and z
    // dont need to test all of this
    // want to figure out rotation, but i just need x+z
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               constant Uniforms &uniforms [[buffer(0)]],
                               constant float2 &pos [[buffer(1)]]) {
    // downscale uv space
    float2 uv = floor(in.uv * uniforms.scale) / uniforms.scale;
//    uv = in.uv;
    
    float3 ro = float3(0, 0, -3);
    float3 rd = normalize(float3(uv.x, 0, 1));
    float3 color = float3(0);
    float t = 0;
    
    for (int i=0; i<80; i++) {
        float3 p = ro + rd * t;
        p.xz += pos;
        
        float d = map(p, pos);
        t += d;
        
//        color = float3(i) / 80;
//        color = p;
        if (d < 0.001 || t > 10) break;
    }
    
    // sky to black, floor to greenish
    if (uv.y >= 0){
        color = float3(0);
    } else {
        color = float3(0, 0.5, 0);
    }
    
    // had to flip this for some magic
    // do the doom thing
    if (t*0.1 < 1-abs(uv.y)) {
        color = float3(t * 0.1);
    }
//    color = float3(1-abs(uv.y));
//    if (abs(uv.y) > t*0.1) color = 0;
    
    return float4(color, 1);
}
