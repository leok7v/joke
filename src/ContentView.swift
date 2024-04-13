import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    // Accumulates full lines
    @State private var displayText = ""
    // Accumulates current line until '\n'
    @State private var currentLine = "Once upon a time "
    @State private var errorText = ""
    @State private var statusText = ""
    @State private var showToast = false;
    @State private var scrollTarget: UUID? = nil
    @State private var textSegments = [(id: UUID, text: String)]()
    @StateObject var downloader = Downloader()
    
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
                /*
                Text(displayText)
                    .padding()
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .topLeading) // Aligns the text to the top leading
                    .multilineTextAlignment(.leading)
                */
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(textSegments, id: \.id) { segment in
                                Text(segment.text)
//                                  .font(.headline)
//                                  .fontWeight(.bold)
                                    .font(.system(size: 18, weight: .medium, design: .default))
                                    .foregroundColor(foregroundColor(for: segment.id))
//                                  .foregroundColor(.white) // White text for karaoke effect
//                                  .padding(.vertical, 4) // vertical spacing between lines
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
                Button(action: {
                    print("Speech action triggered")
                }) {
                    Text("\u{1F5E3}\u{1F4AC}") // Unicode for speech bubble emoji
                        .font(.largeTitle) // You can adjust the font size as needed
                }
                .padding()
/*
                Button("Mirror") {
                    let r = Service.mirror(input: displayText)
                    if r.err == 0 {
                        displayText = r.output
                    } else {
                        errorText = r.error
                        if (!showToast) {
                            withAnimation { 
                                showToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation { showToast = false }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .padding()
*/
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
                displayText += newSegment.text  // Optional: Accumulate all text
            }
            currentLine = String(lines.last ?? "")  // Start the new line with what's after the last newline
            scrollTarget = textSegments.last?.id
        }
        displayText += " " + token
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
        Service.generate(prompt: gen_prompt,
             token: { text in DispatchQueue.main.async { token(text) } },
             done: { DispatchQueue.main.async { done() } })
    }

    func done() {
        print("done")
        displayText += " done."
    }
}

struct ContentView_Previews: SwiftUI.PreviewProvider {
    static var previews: some SwiftUI.View {
        ContentView()
    }
}

