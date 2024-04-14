import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    // Accumulates full lines
    @State private var text = ""
    @State private var isSpeaking = false
    @State private var isSpeakVisible = false
    // Accumulates current line until '\n'
    @State private var currentLine = "Once upon a time "
    @State private var errorText = ""
    @State private var statusText = ""
    @State private var showToast = false;
    @State private var scrollTarget: UUID? = nil
    @State private var textSegments = [(id: UUID, text: String)]()
    @StateObject var downloader = Downloader()

    let synthesizer = SpeechSynthesizer()
    private static var tokenCount = 0
    private static var startTime = Date()

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: { print("hamburger") }) {
                        Image(systemName: "line.horizontal.3")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                            .padding(.leading, 4)
                    }
                    .frame(alignment: .topLeading)
                    .buttonStyle(PlainButtonStyle())
                    Text(statusText)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                if downloader.downloading {
                    ProgressView(value: downloader.progress).padding()
                }
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(textSegments, id: \.id) { segment in
                                Text(segment.text)
                                    .font(.system(size: 18, weight: .medium, design: .default))
                                    .foregroundColor(foregroundColor(for: segment.id))
                            }
                        }
                    }
                    .padding()
                    .onChange(of: scrollTarget, initial: false) { old, target in
                        withAnimation {
                            proxy.scrollTo(target, anchor: .bottom)
                        }
                    }
                }
                Spacer() // Pushes the button to the bottom
                if isSpeakVisible {
                    Button(action: {
                        isSpeaking.toggle()
                        isSpeakVisible = false
                        if isSpeaking {
                            for segment in textSegments {
                                synthesizer.enqueue(segment.text)
                            }
                        } else {
                            synthesizer.cancel()
                        }
                    })
                    {
                        Text("\u{1F5E3}\u{1F4AC}") // Unicode for speech bubble emoji
                            .font(.largeTitle) // You can adjust the font size as needed
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Toast(message: errorText, isError: true, isVisible: $showToast)
            .onTapGesture { withAnimation { showToast = false } }
        }
        .onAppear {
            if downloader.needsDownload() {
                statusText = "Downloading"
                downloader.startDownload() { r in
                    statusText = ""
                    print("done downloading \(r)")
                    if (r == 200) {
                        downloaded()
                    }
                }
            } else {
                downloaded()
            }
        }
        .onDisappear() {
            synthesizer.cancel()
            synthesizer.done()
        }
    }
    
    private func foregroundColor(for segmentId: UUID) -> Color {
        if segmentId == textSegments.last?.id {
            return colorScheme == .dark ? .white : .black  // Default color for the last segment
        } else {
            let baseColor: Color = colorScheme == .dark ? .white : .black
            return baseColor.opacity(0.75)  // 75% opacity for all other segments
        }
    }
    
    func token(_ token: String) {
        currentLine += token
        if token.contains("\n") {
            // Split the currentLine around the newline, just in case multiple or partial lines have been received
            let lines = currentLine.split(separator: "\n", omittingEmptySubsequences: false)
            for line in lines.dropLast() {
                let trimmedLine = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
                let newSegment = (id: UUID(), text: trimmedLine + " ")
                textSegments.append(newSegment)
                if isSpeaking {
                    synthesizer.enqueue(trimmedLine)
                }
            }
            currentLine = String(lines.last ?? "")  // Start the new line with what's after the last newline
            scrollTarget = textSegments.last?.id
        }
        text += " " + token
        ContentView.tokenCount += 1
        updateTokensPerSecond()
    }
    
    private func updateTokensPerSecond() {
        if ContentView.tokenCount % 10 == 0 {
            let elapsed = Date().timeIntervalSince(ContentView.startTime)
            if elapsed > 0 { // tokens per second
                let tps = Double(ContentView.tokenCount) / elapsed
                statusText = String(format: "Generating: %.1f t/s", tps)
            }
        }
    }

    func downloaded() {
        statusText = ""
        Service.ini()
        Service.load(file: downloader.destination().path()) { err, text in
            DispatchQueue.main.async {
                if err == 0 {
                    loaded()
                } else {
                    print("Download error: \(text)")
                }
            }
        }
        
    }
    
    func loaded() {
        let ix = Int.random(in: 0..<stories_with_description.count)
        let prompt = gen_prompt.replacingOccurrences(of: "[story]", 
                                    with: stories_with_description[ix])
        Service.generate(prompt: prompt,
             token: { text in DispatchQueue.main.async { token(text) } },
             done: { DispatchQueue.main.async { done() } })
    }

    func done() {
        statusText = ""
        isSpeakVisible = true
    }
}

struct ContentView_Previews: SwiftUI.PreviewProvider {
    static var previews: some SwiftUI.View {
        ContentView()
    }
}

