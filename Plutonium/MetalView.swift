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
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalView
        var renderer: Renderer?
        
        init(_ parent: MetalView) {
            self.parent = parent
            super.init()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            renderer?.mtkView(view, drawableSizeWillChange: size)
        }
        
        func draw(in view: MTKView) {
            if renderer == nil {
                renderer = Renderer(metalView: view)
            }
            renderer?.draw(in: view)
        }
    }
}
