import SwiftUI




struct ContentView: View {
    
    @State private var displayText = "Hello, world!"
    @State private var errorText = ""
    @State private var statusText = ""
    @State private var showToast = false;
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
                Text(displayText)
                    .padding()
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .topLeading) // Aligns the text to the top leading
                    .multilineTextAlignment(.leading)
                Spacer() // Pushes the button to the bottom
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

    func downloaded() {
        print("Download successful")
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
        print("Load successful")
        Service.generate(prompt: "foo bar",
             token: { text in DispatchQueue.main.async { token(text) } },
             done: { DispatchQueue.main.async { done() } })
    }

    func token(_ token: String) {
        displayText += " " + token
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

