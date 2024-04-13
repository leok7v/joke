import SwiftUI

struct Toast: View {
    let message: String
    let isError: Bool
    @Binding var isVisible: Bool

    var body: some View {
        GeometryReader { gr in
            VStack {
                if isVisible {
                    let h = titleBarHeight(for: gr)
                    Text(isError ? "💣 \(message)" : message)
                        .foregroundColor(isError ? Color.red : Color.green)
                        .padding(4) // Reduced padding
                        .background(isError ? Color.red.opacity(0.1) :
                                              Color.green.opacity(0.1))
                        .cornerRadius(5)
                        .transition(.move(edge: .top))
                        .zIndex(1)
                        .padding(.top, isVisible ? -gr.size.height / 2 - h : -100)
                        .animation(.easeInOut, value: isVisible)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear { isVisible = true }
                        .onDisappear() { isVisible = false }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func titleBarHeight(for geometry: GeometryProxy) -> CGFloat {
        // Runtime check for iOS:
        if let _ = NSClassFromString("UIDevice") {
            return 0 // No title bar on iOS
        } else {
            return geometry.safeAreaInsets.top
        }
    }
}
