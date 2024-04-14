import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        ZStack {
            mainContent
            Toast(message: viewModel.errorText, isError: true, isVisible: $viewModel.showToast)
                .onTapGesture { withAnimation { viewModel.showToast = false } }
        }
        .onAppear(perform: viewModel.onAppear)
        .onDisappear(perform: viewModel.onDisappear)
        .onChange(of: colorScheme, initial: true) { old, scheme in
            viewModel.colorScheme = scheme
        }
    }
    
    private var mainContent: some View {
        VStack {
            header
            if viewModel.downloader.downloading {
                ProgressView(value: viewModel.downloader.progress)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            storyScrollView
            speakButton
            stopButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var header: some View {
        HStack {
            hamburgerButton
            Text(viewModel.statusText)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    private var hamburgerButton: some View {
        Button(action: { print("hamburger") }) {
            Image(systemName: "line.horizontal.3")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .padding(.leading, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var storyScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.textSegments, id: \.id) { segment in
                        Text(segment.text)
                            .font(.system(size: 18, weight: .medium, design: .default))
                            .foregroundColor(viewModel.foregroundColor(for: segment.id))
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .onChange(of: viewModel.scrollTarget, initial: false) { old, target in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
//                      trace("target: \(target)")
                        proxy.scrollTo(target, anchor: .bottom)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    private var speakButton: some View {
        if viewModel.isSpeakVisible {
            return AnyView(Button(action: viewModel.toggleSpeaking) {
                Text("\u{1F5E3}\u{1F4AC}").font(.largeTitle)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            .transition(.opacity))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private var stopButton: some View {
        if viewModel.isSpeaking || viewModel.isGenerating {
            return AnyView(Button(action: viewModel.stop) {
                Text("\u{3264}").font(.largeTitle)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            .foregroundColor(.red).opacity(0.6)
            .transition(.opacity))
        } else {
            return AnyView(EmptyView())
        }
    }
}

extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}

// #Preview { ContentView() }
