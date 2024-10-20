//
//  ContentView.swift
//  Plutonium
//
//  Created by Joey Shapiro on 10/14/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var map: [[Int]] = [[1, 0, 0]]
    @State private var pos: CGPoint = .zero
    @FocusState private var focused: Bool

    var body: some View {
        HStack {
            VStack {
                List {
                    ForEach(items) { item in
                        Text(item.timestamp.description)
                    }
                    .onDelete(perform: deleteItems)
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
                pos.x += 1
            case "a":
                pos.y += 1
            case "s":
                pos.x -= 1
            case "d":
                pos.y -= 1
            default:
                print(pos)
            }
            return .handled
        })
//            .frame(width: 1280, height: 720)
            
    }
    
    

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}
