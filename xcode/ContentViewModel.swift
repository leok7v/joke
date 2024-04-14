import SwiftUI
import Foundation

class ContentViewModel: ObservableObject {

    var colorScheme: ColorScheme = .light
    
    @Published var text = ""
    @Published var isSpeaking = false
    @Published var isSpeakVisible = false
    @Published var isGenerating = false
    @Published var isStopVisible = false
    @Published var currentLine = "Once upon a time "
    @Published var errorText = ""
    @Published var statusText = ""
    @Published var showToast = false
    @Published var scrollTarget: UUID? = nil
    @Published var textSegments = [(id: UUID, text: String)]()
    @Published var downloader = Downloader()
    
    static var tokenCount = 0
    static var startTime = Date()
    
    let synthesizer = SpeechSynthesizer()
    
    func onAppear() {
        if downloader.needsDownload() {
            statusText = "Downloading"
            downloader.startDownload { r in
                DispatchQueue.main.async {
                    self.statusText = ""
                    print("done downloading \(r)")
                    if r == 200 {
                        self.downloaded()
                    }
                }
            }
        } else {
            downloaded()
        }
    }
    
    func onDisappear() {
        synthesizer.cancel()
        synthesizer.done()
    }
    
    func toggleSpeaking() {
        isSpeaking.toggle()
        isSpeakVisible = false
        if isSpeaking {
            for segment in textSegments {
                synthesizer.enqueue(segment.text)
            }
        } else {
            synthesizer.cancel()
        }
    }

    func stop() {
        if isSpeaking {
            synthesizer.cancel()
            isSpeaking = false
            isSpeakVisible = true
        }
    }

    func foregroundColor(for segmentId: UUID) -> Color {
        if segmentId == textSegments.last?.id {
            return colorScheme == .dark ? .white : .black
        } else {
            let baseColor: Color = colorScheme == .dark ? .white : .black
            return baseColor.opacity(0.75)
        }
    }
        
    func token(_ token: String) {
        currentLine += token
        if token.contains("\n") {
            // Split the currentLine around the newline, 
            // just in case multiple or partial lines have been received
            let lines = currentLine.split(separator: "\n",
                                          omittingEmptySubsequences: false)
            for line in lines.dropLast() {
                let trimmedLine = String(line).trimmingCharacters(in: 
                        .whitespacesAndNewlines)
                let newSegment = (id: UUID(), text: trimmedLine + " ")
                textSegments.append(newSegment)
                if isSpeaking {
                    synthesizer.enqueue(trimmedLine)
                }
            }
            // Start the new line with what's after the last newline
            currentLine = String(lines.last ?? "")
            scrollTarget = textSegments.last?.id
//          trace("scrollTarget: \(scrollTarget)")
        }
        text += " " + token
        ContentViewModel.tokenCount += 1
        updateTokensPerSecond()
    }
    
    private func updateTokensPerSecond() {
        if ContentViewModel.tokenCount % 10 == 0 {
            let elapsed = Date().timeIntervalSince(ContentViewModel.startTime)
            if elapsed > 0 { // tokens per second
                let tps = Double(ContentViewModel.tokenCount) / elapsed
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
                    self.loaded()
                } else {
                    self.errorText = "Download error: \(text)"
                    self.showToast = true
                }
            }
        }
        
    }
    
    func loaded() {
        let ix = Int.random(in: 0..<stories_with_description.count)
        let prompt = gen_prompt.replacingOccurrences(of: "[story]",
                                with: stories_with_description[ix])
        isGenerating = true
        Service.generate(prompt: prompt,
                         token: { text in DispatchQueue.main.async {
                                    self.token(text)
                                }
                        },
                         done: { DispatchQueue.main.async { self.done() } })
    }
    
    func done() {
        statusText = ""
        isSpeakVisible = true
        isGenerating = false
    }
    
}
