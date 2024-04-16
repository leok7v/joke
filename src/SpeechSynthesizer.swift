import AVFoundation
import Foundation

class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var speechQueue = [AVSpeechUtterance]()
    private let queueAccessQueue = DispatchQueue(label: "speechQueueAccess", attributes: .concurrent)
    private let group = DispatchGroup()

    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }
    
    func enqueue(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        // AVSpeechUtteranceDefaultSpeechRate 0.5
        utterance.rate = 0.15
        utterance.pitchMultiplier = 0.1
        utterance.volume = 0.4
        queueAccessQueue.async(flags: .barrier) {
            self.speechQueue.append(utterance)
            self.group.enter()
            if !self.speechSynthesizer.isSpeaking {
                self.speakNextUtterance()
            }
        }
    }

    private func speakNextUtterance() {
        queueAccessQueue.async {
            guard !self.speechQueue.isEmpty else { return }
            let utterance = self.speechQueue.removeFirst()
            DispatchQueue.main.async {
                self.speechSynthesizer.speak(utterance)
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, 
                           didFinish utterance: AVSpeechUtterance,
                           successfully flag: Bool) {
        group.leave()
        speakNextUtterance()
    }
    
    func cancel() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        queueAccessQueue.async(flags: .barrier) {
            self.speechQueue.removeAll()
        }
    }
    
    func done() {
        group.wait()
    }
}

/*
 init() {
     listVoices()
 }
 
 func listVoices() {
     let voices = AVSpeechSynthesisVoice.speechVoices()
     for voice in voices {
         print("Language: \(voice.language), Name: \(voice.name), Identifier: \(voice.identifier), Quality: \(voice.quality.rawValue)")
     }
     print("done")
 }
*/


/*
 MacOS:
 
 Language: en-GB, Name: Rocko, Identifier: com.apple.eloquence.en-GB.Rocko, Quality: 1
 Language: en-GB, Name: Shelley, Identifier: com.apple.eloquence.en-GB.Shelley, Quality: 1
 Language: en-GB, Name: Daniel, Identifier: com.apple.voice.compact.en-GB.Daniel, Quality: 1
 Language: en-GB, Name: Martha, Identifier: com.apple.ttsbundle.siri_Martha_en-GB_compact, Quality: 1
 Language: en-GB, Name: Grandma, Identifier: com.apple.eloquence.en-GB.Grandma, Quality: 1
 Language: en-GB, Name: Grandpa, Identifier: com.apple.eloquence.en-GB.Grandpa, Quality: 1
 Language: en-GB, Name: Flo, Identifier: com.apple.eloquence.en-GB.Flo, Quality: 1
 Language: en-GB, Name: Eddy, Identifier: com.apple.eloquence.en-GB.Eddy, Quality: 1
 Language: en-GB, Name: Reed, Identifier: com.apple.eloquence.en-GB.Reed, Quality: 1
 Language: en-GB, Name: Sandy, Identifier: com.apple.eloquence.en-GB.Sandy, Quality: 1
 Language: en-GB, Name: Arthur, Identifier: com.apple.ttsbundle.siri_Arthur_en-GB_compact, Quality: 1

 Language: en-US, Name: Flo, Identifier: com.apple.eloquence.en-US.Flo, Quality: 1
 Language: en-US, Name: Bahh, Identifier: com.apple.speech.synthesis.voice.Bahh, Quality: 1
 Language: en-US, Name: Albert, Identifier: com.apple.speech.synthesis.voice.Albert, Quality: 1
 Language: en-US, Name: Fred, Identifier: com.apple.speech.synthesis.voice.Fred, Quality: 1
 Language: en-US, Name: Jester, Identifier: com.apple.speech.synthesis.voice.Hysterical, Quality: 1
 Language: en-US, Name: Organ, Identifier: com.apple.speech.synthesis.voice.Organ, Quality: 1
 Language: en-US, Name: Cellos, Identifier: com.apple.speech.synthesis.voice.Cellos, Quality: 1
 Language: en-US, Name: Zarvox, Identifier: com.apple.speech.synthesis.voice.Zarvox, Quality: 1
 Language: en-US, Name: Rocko, Identifier: com.apple.eloquence.en-US.Rocko, Quality: 1
 Language: en-US, Name: Shelley, Identifier: com.apple.eloquence.en-US.Shelley, Quality: 1
 Language: en-US, Name: Superstar, Identifier: com.apple.speech.synthesis.voice.Princess, Quality: 1
 Language: en-US, Name: Grandma, Identifier: com.apple.eloquence.en-US.Grandma, Quality: 1
 Language: en-US, Name: Eddy, Identifier: com.apple.eloquence.en-US.Eddy, Quality: 1
 Language: en-US, Name: Bells, Identifier: com.apple.speech.synthesis.voice.Bells, Quality: 1
 Language: en-US, Name: Grandpa, Identifier: com.apple.eloquence.en-US.Grandpa, Quality: 1
 Language: en-US, Name: Trinoids, Identifier: com.apple.speech.synthesis.voice.Trinoids, Quality: 1
 Language: en-US, Name: Kathy, Identifier: com.apple.speech.synthesis.voice.Kathy, Quality: 1
 Language: en-US, Name: Reed, Identifier: com.apple.eloquence.en-US.Reed, Quality: 1
 Language: en-US, Name: Boing, Identifier: com.apple.speech.synthesis.voice.Boing, Quality: 1
 Language: en-US, Name: Whisper, Identifier: com.apple.speech.synthesis.voice.Whisper, Quality: 1
 Language: en-US, Name: Wobble, Identifier: com.apple.speech.synthesis.voice.Deranged, Quality: 1
 Language: en-US, Name: Good News, Identifier: com.apple.speech.synthesis.voice.GoodNews, Quality: 1
 Language: en-US, Name: Nicky, Identifier: com.apple.ttsbundle.siri_Nicky_en-US_compact, Quality: 1
 Language: en-US, Name: Bad News, Identifier: com.apple.speech.synthesis.voice.BadNews, Quality: 1
 Language: en-US, Name: Aaron, Identifier: com.apple.ttsbundle.siri_Aaron_en-US_compact, Quality: 1
 Language: en-US, Name: Bubbles, Identifier: com.apple.speech.synthesis.voice.Bubbles, Quality: 1
 Language: en-US, Name: Samantha, Identifier: com.apple.voice.compact.en-US.Samantha, Quality: 1
 Language: en-US, Name: Sandy, Identifier: com.apple.eloquence.en-US.Sandy, Quality: 1
 Language: en-US, Name: Junior, Identifier: com.apple.speech.synthesis.voice.Junior, Quality: 1
 Language: en-US, Name: Ralph, Identifier: com.apple.speech.synthesis.voice.Ralph, Quality: 1
*/

/*
iOS:
 Language: en-AU, Name: Gordon, Identifier: com.apple.ttsbundle.siri_Gordon_en-AU_compact, Quality: 1
 Language: en-AU, Name: Karen, Identifier: com.apple.voice.compact.en-AU.Karen, Quality: 1
 Language: en-AU, Name: Catherine, Identifier: com.apple.ttsbundle.siri_Catherine_en-AU_compact, Quality: 1

 Language: en-GB, Name: Rocko, Identifier: com.apple.eloquence.en-GB.Rocko, Quality: 1
 Language: en-GB, Name: Shelley, Identifier: com.apple.eloquence.en-GB.Shelley, Quality: 1
 Language: en-GB, Name: Daniel, Identifier: com.apple.voice.compact.en-GB.Daniel, Quality: 1
 Language: en-GB, Name: Martha, Identifier: com.apple.ttsbundle.siri_Martha_en-GB_compact, Quality: 1
 Language: en-GB, Name: Grandma, Identifier: com.apple.eloquence.en-GB.Grandma, Quality: 1
 Language: en-GB, Name: Grandpa, Identifier: com.apple.eloquence.en-GB.Grandpa, Quality: 1
 Language: en-GB, Name: Flo, Identifier: com.apple.eloquence.en-GB.Flo, Quality: 1
 Language: en-GB, Name: Eddy, Identifier: com.apple.eloquence.en-GB.Eddy, Quality: 1
 Language: en-GB, Name: Reed, Identifier: com.apple.eloquence.en-GB.Reed, Quality: 1
 Language: en-GB, Name: Sandy, Identifier: com.apple.eloquence.en-GB.Sandy, Quality: 1
 Language: en-GB, Name: Arthur, Identifier: com.apple.ttsbundle.siri_Arthur_en-GB_compact, Quality: 1

 Language: en-IE, Name: Moira, Identifier: com.apple.voice.compact.en-IE.Moira, Quality: 1
 Language: en-IN, Name: Rishi, Identifier: com.apple.voice.compact.en-IN.Rishi, Quality: 1

 Language: en-US, Name: Evan (Enhanced), Identifier: com.apple.voice.enhanced.en-US.Evan, Quality: 2
 Language: en-US, Name: Ava (Enhanced), Identifier: com.apple.voice.enhanced.en-US.Ava, Quality: 2
 Language: en-US, Name: Allison (Enhanced), Identifier: com.apple.voice.enhanced.en-US.Allison, Quality: 2
 Language: en-US, Name: Agnes (Enhanced), Identifier: com.apple.speech.synthesis.voice.Agnes, Quality: 2
 Language: en-US, Name: Noelle (Enhanced), Identifier: com.apple.voice.enhanced.en-US.Noelle, Quality: 2
 Language: en-US, Name: Flo, Identifier: com.apple.eloquence.en-US.Flo, Quality: 1
 Language: en-US, Name: Bahh, Identifier: com.apple.speech.synthesis.voice.Bahh, Quality: 1
 Language: en-US, Name: Albert, Identifier: com.apple.speech.synthesis.voice.Albert, Quality: 1
 Language: en-US, Name: Fred, Identifier: com.apple.speech.synthesis.voice.Fred, Quality: 1
 Language: en-US, Name: Jester, Identifier: com.apple.speech.synthesis.voice.Hysterical, Quality: 1
 Language: en-US, Name: Organ, Identifier: com.apple.speech.synthesis.voice.Organ, Quality: 1
 Language: en-US, Name: Cellos, Identifier: com.apple.speech.synthesis.voice.Cellos, Quality: 1
 Language: en-US, Name: Evan, Identifier: com.apple.voice.compact.en-US.Evan, Quality: 1
 Language: en-US, Name: Zarvox, Identifier: com.apple.speech.synthesis.voice.Zarvox, Quality: 1
 Language: en-US, Name: Rocko, Identifier: com.apple.eloquence.en-US.Rocko, Quality: 1
 Language: en-US, Name: Shelley, Identifier: com.apple.eloquence.en-US.Shelley, Quality: 1
 Language: en-US, Name: Superstar, Identifier: com.apple.speech.synthesis.voice.Princess, Quality: 1
 Language: en-US, Name: Grandma, Identifier: com.apple.eloquence.en-US.Grandma, Quality: 1
 Language: en-US, Name: Eddy, Identifier: com.apple.eloquence.en-US.Eddy, Quality: 1
 Language: en-US, Name: Bells, Identifier: com.apple.speech.synthesis.voice.Bells, Quality: 1
 Language: en-US, Name: Grandpa, Identifier: com.apple.eloquence.en-US.Grandpa, Quality: 1
 Language: en-US, Name: Trinoids, Identifier: com.apple.speech.synthesis.voice.Trinoids, Quality: 1
 Language: en-US, Name: Kathy, Identifier: com.apple.speech.synthesis.voice.Kathy, Quality: 1
 Language: en-US, Name: Reed, Identifier: com.apple.eloquence.en-US.Reed, Quality: 1
 Language: en-US, Name: Boing, Identifier: com.apple.speech.synthesis.voice.Boing, Quality: 1
 Language: en-US, Name: Whisper, Identifier: com.apple.speech.synthesis.voice.Whisper, Quality: 1
 Language: en-US, Name: Wobble, Identifier: com.apple.speech.synthesis.voice.Deranged, Quality: 1
 Language: en-US, Name: Good News, Identifier: com.apple.speech.synthesis.voice.GoodNews, Quality: 1
 Language: en-US, Name: Nicky, Identifier: com.apple.ttsbundle.siri_Nicky_en-US_compact, Quality: 1
 Language: en-US, Name: Bad News, Identifier: com.apple.speech.synthesis.voice.BadNews, Quality: 1
 Language: en-US, Name: Aaron, Identifier: com.apple.ttsbundle.siri_Aaron_en-US_compact, Quality: 1
 Language: en-US, Name: Bubbles, Identifier: com.apple.speech.synthesis.voice.Bubbles, Quality: 1
 Language: en-US, Name: Samantha, Identifier: com.apple.voice.compact.en-US.Samantha, Quality: 1
 Language: en-US, Name: Sandy, Identifier: com.apple.eloquence.en-US.Sandy, Quality: 1
 Language: en-US, Name: Junior, Identifier: com.apple.speech.synthesis.voice.Junior, Quality: 1
 Language: en-US, Name: Ralph, Identifier: com.apple.speech.synthesis.voice.Ralph, Quality: 1

 Language: en-ZA, Name: Tessa, Identifier: com.apple.voice.compact.en-ZA.Tessa, Quality: 1
 Language: en-US, Name: Alex (Enhanced), Identifier: com.apple.speech.synthesis.voice.Alex, Quality: 2
 
 */
