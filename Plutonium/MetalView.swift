//
//  MetalView.swift
//  Plutonium
//
//  Created by Joey Shapiro on 10/14/24.
//

import SwiftUI
import MetalKit

struct MetalView: NSViewRepresentable {
    @Binding var map: [[Int]]
    @Binding var pos: CGPoint
    private var coordinator: Coordinator
    
    init(map: Binding<[[Int]]>, pos: Binding<CGPoint>) {
        _map = map
        let device = MTLCreateSystemDefaultDevice()!
        self.coordinator = Coordinator(device: device)
        self._pos = pos
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        // idk, have to do this and set renderer as non null otherwise idk
        // metal view is created twice. first gets update, second gets draw
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.delegate = context.coordinator
        mtkView.colorPixelFormat = .bgra8Unorm
//        mtkView.preferredFramesPerSecond = 60
//        mtkView.enableSetNeedsDisplay = false
        
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        self.coordinator.update(pos: self.pos) // todo update scale and size
    }
    
    func makeCoordinator() -> Coordinator {
        return self.coordinator
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var renderer: Renderer
        
        init(device: MTLDevice) {
            renderer = Renderer(device: device)
            
//            super.init()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            renderer.mtkView(view, drawableSizeWillChange: size)
        }
        
        func update(pos: CGPoint) {
            renderer.update(pos: pos)
        }
        
        func draw(in view: MTKView) {
            renderer.draw(in: view)
        }
    }
}
