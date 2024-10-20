//
//  PlutoniumApp.swift
//  Plutonium
//
//  Created by Joey Shapiro on 10/14/24.
//

import SwiftUI
import SwiftData

@main
struct PlutoniumApp: App {
    @State private var map: [[Int]] = [[1, 0, 0]]
    @State private var pos: CGPoint = .zero
    @FocusState private var focused: Bool

    var body: some Scene {
        WindowGroup {
//            ContentView()
            // idk, have to do this and set renderer as non null otherwise idk
            // metal view is created twice. first gets update, second gets draw
            // apple should hire me, if this is in ContentView, it will create this issue
            HStack {
                VStack {
                    List {
                        Text("Hello, World!")
                        Text("Hello, World!")
                    }
                    .navigationBarBackButtonHidden(true)
                    Canvas(
                        opaque: true,
                        colorMode: .linear,
                        rendersAsynchronously: false
                    ) { context, size in
                        let rect = CGRect(origin: .zero, size: size)
                        
                        
                        let trianglePath = Path { path in
                            path.move(to: CGPoint(x: size.width * 0.2, y: size.width * 0.8))
                            path.addLine(to: CGPoint(x: size.width * 0.8, y: size.width * 0.8))
                            path.addLine(to: CGPoint(x: size.width * 0.5, y: size.width * 0.2))
                            path.closeSubpath()
                        }
                        //                    context.stroke(trianglePath, with: .color(.blue), lineWidth: 5)
                        context.fill(trianglePath, with: .color(.red))
                    }
                }
                MetalView(map: $map, pos: $pos)//.aspectRatio(1/1, contentMode: .fit)
            }
            .focusable()
            .focused($focused)
            .focusEffectDisabled()
            .onKeyPress(action: { keypress in
                //            print(keypress)
                switch keypress.characters {
                case "w":
                    pos.y += 1
                case "a":
                    pos.x -= 1
                case "s":
                    pos.y -= 1
                case "d":
                    pos.x += 1
                default:
                    print(pos)
                }
                return .handled
            })
        }
    }
}
