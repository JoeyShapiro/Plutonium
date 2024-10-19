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
    private var uuid: UUID = UUID()
    
    init(map: Binding<[[Int]]>, pos: Binding<CGPoint>) {
        _map = map
        _pos = pos
        coordinator = Coordinator(device: MTLCreateSystemDefaultDevice()!)
        print("metal view init")
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        // idk, have to do this and set renderer as non null otherwise idk
        // metal view is created twice. first gets update, second gets draw
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = true
        
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        print(pos)
        self.coordinator.update(pos: pos) // todo update scale and size
        print("mv update", self.uuid)
    }
    
    func makeCoordinator() -> Coordinator {
        self.coordinator
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var renderer: Renderer
        var uuid: UUID = UUID()
        
        init(device: MTLDevice) {
            renderer = Renderer(device: device)
            
            super.init()
            print("coordinator init", self.uuid)
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            renderer.mtkView(view, drawableSizeWillChange: size)
        }
        
        func update(pos: CGPoint) {
            print("coordinator update", self.uuid)
            renderer.update(pos: pos)
        }
        
        func draw(in view: MTKView) {
            print("coordinator draw", self.uuid)
            renderer.draw(in: view)
        }
    }
}
