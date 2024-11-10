//
//  PlutoniumApp.swift
//  Plutonium
//
//  Created by Joey Shapiro on 10/14/24.
//

import SwiftUI
import SwiftData
import Combine

@main
struct PlutoniumApp: App {
    @State private var map: [[Int]] = [[1, 0, 0]]
    @State private var pos: CGPoint = .zero
    @FocusState private var focused: Bool
    @State private var dir: CGPoint = .zero
    
    // jank, but dont want to make a game engine for tech demo

    var body: some Scene {
        WindowGroup {
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
            .onKeyPress(phases: .all, action: { keypress in
                let down = if keypress.phase == .up { false } else  { true }
                
                switch keypress.characters {
                case "w":
                    self.dir.y = down ? 0.1 : 0
                case "a":
                    self.dir.x = down ? -0.1 : 0
                case "s":
                    self.dir.y = down ? -0.1 : 0
                case "d":
                    self.dir.x = down ? 0.1 : 0
                default:
                    print(pos)
                }
                
                return .handled
            })
            .onTimer(interval: 1/60, isActive: true, runImmediately: true, { delta in
                // smooth movement is so cool
                pos.x += dir.x
                pos.y += dir.y
            })
        }
    }
}

// Timer modifier that can be attached to any view
extension View {
    public func onTimer(
        interval: TimeInterval,
        isActive: Bool = true,
        runImmediately: Bool = true,
        _ action: @escaping (_ delta: TimeInterval) -> Void
    ) -> some View {
        modifier(TimerModifier(
            interval: interval,
            isActive: isActive,
            runImmediately: runImmediately,
            action: action
        ))
    }
}

// Internal modifier that manages timer state
private struct TimerModifier: ViewModifier {
    let interval: TimeInterval
    let isActive: Bool
    let runImmediately: Bool
    let action: (_ delta: TimeInterval) -> Void
    
    @State private var timer: AnyCancellable?
    @State private var lastTime: TimeInterval?
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if runImmediately {
                    action(0)
                }
                
                guard isActive else { return }
                
                timer = Timer.publish(every: interval, on: .main, in: .common)
                    .autoconnect()
                    .sink { time in
                        let now = time.timeIntervalSince1970
                        action(now - (lastTime ?? 0))
                        lastTime = now
                    }
            }
            .onDisappear {
                timer?.cancel()
                timer = nil
            }
            .onChange(of: isActive) { newValue in
                if newValue {
                    timer = Timer.publish(every: interval, on: .main, in: .common)
                        .autoconnect()
                        .sink { time in
                            let now = time.timeIntervalSince1970
                            action(now - (lastTime ?? 0))
                            lastTime = now
                        }
                } else {
                    timer?.cancel()
                    timer = nil
                }
            }
    }
}
