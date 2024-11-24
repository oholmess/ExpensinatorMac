//
//  ShimmerEffect.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/24/24.
//

import SwiftUI
struct ShimmerEffect: ViewModifier {
    var isLoading: Bool
    var darkColor = Color.primary.opacity(0.9)
    var lightColor = Color.primary.opacity(0.01)

    func body(content: Content) -> some View {
        content
            .opacity(isLoading ? 0 : 1) // Hide content when loading
            .overlay(
                Group {
                    if isLoading {
                        ZStack {
                            Rectangle()
                                .foregroundStyle(Color.black.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                          
                            Rectangle()
                                .fill(
                                    LinearGradient(gradient: Gradient(colors: [darkColor, darkColor, darkColor]), startPoint: .leading, endPoint: .trailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .shimmering()
                        }
                    }
                }
            )
    }
}

extension View {
    func shimmerEffect(isLoading: Bool) -> some View {
        self.modifier(ShimmerEffect(isLoading: isLoading))
    }

    func shimmering() -> some View {
        self.modifier(Shimmering())
    }
}

struct Shimmering: ViewModifier {
    @State private var start = false

    func body(content: Content) -> some View {
        content
            .mask(
                Rectangle()
                    .fill(
                        LinearGradient(gradient: Gradient(colors: [.clear, .white.opacity(0.2), .clear]), startPoint: .leading, endPoint: .trailing)
                    )
                    .offset(x: start ? NSScreen.main?.visibleFrame.size.width ?? 200 : -(NSScreen.main?.visibleFrame.size.width ?? -200))
                    .animation(Animation.linear(duration: 1.4).repeatForever(autoreverses: false), value: start)
            )
            .onAppear {
                start = true
            }
    }
}

// Example usage
struct ObjectLoadingContentView: View {
    @State private var isLoading = true

    var body: some View {
        VStack {
            Text("Hello")
            Text("World")
            Text("Shimmering Effect")
        }
        .shimmerEffect(isLoading: isLoading)
        .frame(width: 300, height: 200) // Set the frame as needed
    }
}


#Preview {
    ObjectLoadingContentView()
}
