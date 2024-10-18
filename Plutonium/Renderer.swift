//
//  Renderer.swift
//  Plutonium
//
//  Created by Joey Shapiro on 10/14/24.
//

import MetalKit

struct Uniforms {
    var resolution: SIMD2<Float>
    var scale: SIMD2<Float>
}

class Renderer: NSObject, MTKViewDelegate {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState
    var uniformsBuffer: MTLBuffer
    var uniforms: Uniforms
    
    let vertices: [Float] = [
        -1, -1,  // bottom left
         1, -1,  // bottom right
         -1,  1,  // top left
         1,  1,  // top right
    ]
    var vertexBuffer: MTLBuffer?
    
    init?(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            return nil
        }
        
        self.device = device
        self.commandQueue = commandQueue
        
        metalView.device = device
        
        uniforms = Uniforms(resolution: SIMD2<Float>(Float(metalView.drawableSize.width),
                                                     Float(metalView.drawableSize.height)),
                            scale: SIMD2<Float>(Float(metalView.drawableSize.width/16),
                                                Float(metalView.drawableSize.height/16)))
        uniformsBuffer = device.makeBuffer(bytes: &uniforms,
                                           length: MemoryLayout<Uniforms>.stride,
                                           options: [])!
        
        // Create the render pipeline
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: "fragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Unable to create render pipeline state: \(error)")
            return nil
        }
        
        super.init()
        
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.stride, options: [])
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        uniforms.resolution = SIMD2<Float>(Float(size.width), Float(size.height))
        memcpy(uniformsBuffer.contents(), &uniforms, MemoryLayout<Uniforms>.stride)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentBuffer(uniformsBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
