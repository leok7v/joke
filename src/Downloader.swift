import Foundation

class Downloader: NSObject, ObservableObject, URLSessionDownloadDelegate {
    
    @Published var progress: Double = 0
    @Published var downloading = false
    var name: String = "tinyllama-1.1b-chat-v1.0.Q8_0.gguf"
//  var model: String = "https://github.com/leok7v/joker/releases/download/2024-04-08/"
//  var model: String = "https://github.com/leok7v/joke/releases/download/2024-04-12/"
    var model: String = "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/"
    var completion: ((Int) -> Void)?

    func destination() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, 
                                                     in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(name)
    }

    func needsDownload() -> Bool {
        let destination = self.destination()
        return !FileManager.default.fileExists(atPath: destination.path)
    }

    func done(_ r: Int) {
        DispatchQueue.main.async {
            self.completion?(r)
            self.completion = nil
            self.downloading = false
        }
    }

    func startDownload(completion: @escaping ((Int) -> Void)) {
        self.completion = completion
        downloading = true
        guard let url = URL(string: model + name) else {
//          print("Invalid URL")
            done(404)
            return
        }
        let session = URLSession(configuration: .default, delegate: self, 
                                 delegateQueue: OperationQueue())
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
    }
    
    // Delegate methods

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, 
                    didFinishDownloadingTo location: URL) {
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            done(404)
            return
        }
        do {
            let destinationURL = self.destination()
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.moveItem(at: location, to: destinationURL)
            done(200)
        } catch {
//          print("File move error: \(error.localizedDescription)")
            done(500)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, 
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            self.progress = Double(totalBytesWritten) / 
                            Double(totalBytesExpectedToWrite)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, 
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if response.statusCode == 302 { // redirect with a 302 status code.
            completionHandler(request)
        } else {
            completionHandler(nil)
            done(response.statusCode)
        }
    }
}
